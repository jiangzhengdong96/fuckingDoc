
###### 内容概述

本文件记录 Android 中使用 Kotlin 协程的核心知识，包括协程定位、常用依赖、作用域选择、启动方式、调度器切换、生命周期收集、异常处理、取消机制、常见使用方式和易错点。

###### 使用场景

- 在 ViewModel 中发起接口请求、数据库读写、业务组合和状态更新。
- 在 Activity / Fragment 中执行和界面生命周期绑定的短任务。
- 用 Flow、StateFlow、SharedFlow 驱动 UI 状态和一次性事件。
- 替代回调嵌套、手写线程和部分 Handler 切线程逻辑。

一级栏目导航：

- [协程解决什么问题](#协程解决什么问题)
- [Android 常用依赖](#android-常用依赖)
- [Android 常用作用域](#android-常用作用域)
- [Android 常用使用方式](#android-常用使用方式)
- [调度器和线程切换](#调度器和线程切换)
- [生命周期感知收集 Flow](#生命周期感知收集-flow)
- [结构化并发和取消](#结构化并发和取消)
- [异常处理](#异常处理)
- [StateFlow 和 SharedFlow 使用](#stateflow-和-sharedflow-使用)
- [常见坑](#常见坑)

<a id="协程解决什么问题"></a>
###### 协程解决什么问题

- 协程用于把异步代码写成接近同步的结构，减少回调嵌套。
- 协程不是线程。协程运行在线程之上，由调度器决定具体在哪个线程执行。
- 在 Android 中，协程常用来处理网络请求、数据库读写、复杂业务组合和 UI 状态更新。
- 协程的核心价值是：可取消、可组合、能切线程、能跟生命周期绑定。

示例：

```kotlin
viewModelScope.launch {
    val user = repository.loadUser()
    _uiState.value = UserUiState.Success(user)
}
```

这里 `launch` 启动一个协程，代码看起来是顺序执行，但 `loadUser()` 可以在内部挂起，不会阻塞主线程。

###### 面试可能怎么问

- 协程和线程有什么区别？
- Android 为什么推荐用协程处理异步任务？

<a id="android-常用依赖"></a>
###### Android 常用依赖

常见依赖：

```kotlin
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:<version>")
implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:<version>")
implementation("androidx.lifecycle:lifecycle-runtime-ktx:<version>")
```

说明：

- `kotlinx-coroutines-android` 提供 Android 主线程调度器 `Dispatchers.Main`。
- `lifecycle-viewmodel-ktx` 提供 `viewModelScope`。
- `lifecycle-runtime-ktx` 提供 `lifecycleScope`、`repeatOnLifecycle` 等生命周期扩展。
- 实际版本要和项目 Kotlin、AGP、Lifecycle 版本匹配，本文不固定具体版本。

###### 面试可能怎么问

- `Dispatchers.Main` 是哪个依赖提供的？

<a id="android-常用作用域"></a>
###### Android 常用作用域

| 作用域 | 生命周期 | 常用位置 | 适用场景 |
|---|---|---|---|
| `viewModelScope` | ViewModel 清除时取消 | ViewModel | 请求数据、保存状态、业务组合 |
| `lifecycleScope` | Lifecycle 销毁时取消 | Activity / Fragment | 和页面生命周期绑定的任务 |
| `rememberCoroutineScope` | Compose 组合离开时取消 | Compose | 响应点击、Snackbar、滚动等 UI 事件 |
| 自定义 `CoroutineScope` | 自己负责取消 | Repository / Manager | 长生命周期任务，必须明确释放 |

优先级：

- ViewModel 中优先用 `viewModelScope`。
- Activity / Fragment 中和 UI 生命周期相关的任务用 `lifecycleScope`。
- 不要在 Android 业务里随意使用 `GlobalScope`，它不会跟页面或 ViewModel 自动取消，容易泄漏或产生无主任务。

###### 面试可能怎么问

- `viewModelScope` 和 `lifecycleScope` 有什么区别？
- 为什么不建议在 Android 中使用 `GlobalScope`？

<a id="android-常用使用方式"></a>
###### Android 常用使用方式

ViewModel 请求数据：

```kotlin
class UserViewModel(
    private val repository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UserUiState>(UserUiState.Loading)
    val uiState: StateFlow<UserUiState> = _uiState

    fun loadUser(userId: String) {
        viewModelScope.launch {
            _uiState.value = UserUiState.Loading
            runCatching {
                repository.getUser(userId)
            }.onSuccess { user ->
                _uiState.value = UserUiState.Success(user)
            }.onFailure { error ->
                _uiState.value = UserUiState.Error(error.message ?: "加载失败")
            }
        }
    }
}
```

Repository 切到 IO：

```kotlin
class UserRepository(
    private val api: UserApi,
    private val dao: UserDao
) {
    suspend fun getUser(userId: String): User = withContext(Dispatchers.IO) {
        val remote = api.getUser(userId)
        dao.insert(remote)
        remote
    }
}
```

Fragment 收集状态：

```kotlin
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            render(state)
        }
    }
}
```

点击事件启动短任务：

```kotlin
binding.retryButton.setOnClickListener {
    viewModel.loadUser(userId)
}
```

使用建议：

- 网络、数据库和文件读写放到 Repository 或 UseCase，ViewModel 只负责编排和状态转换。
- ViewModel 对外暴露不可变的 `StateFlow`，内部使用 `MutableStateFlow`。
- UI 层负责收集状态并渲染，不直接在 UI 层写复杂业务逻辑。
- Fragment 中收集 Flow 时优先用 `viewLifecycleOwner`，避免 Fragment View 销毁后仍然更新旧 View。

###### 面试可能怎么问

- Android 中协程从 ViewModel 到 Repository 一般怎么分层使用？

<a id="调度器和线程切换"></a>
###### 调度器和线程切换

常用调度器：

| 调度器 | 适合场景 | 注意点 |
|---|---|---|
| `Dispatchers.Main` | 更新 UI、调用主线程 API | 不要执行耗时阻塞操作 |
| `Dispatchers.IO` | 网络、数据库、文件读写 | 适合阻塞 IO，不代表可以无限制堆任务 |
| `Dispatchers.Default` | JSON 大量解析、排序、计算等 CPU 密集任务 | 不适合阻塞 IO |
| `Dispatchers.Unconfined` | 特殊测试或底层场景 | Android 业务代码一般不用 |

切线程写法：

```kotlin
viewModelScope.launch {
    val result = withContext(Dispatchers.IO) {
        repository.loadFromDisk()
    }
    _uiState.value = UiState.Success(result)
}
```

关键点：

- `launch(Dispatchers.IO)` 是让整个协程默认在 IO 调度器执行。
- `withContext(Dispatchers.IO)` 是在当前协程里切一段代码到 IO，并等待结果返回。
- 挂起函数不等于一定切线程。是否切线程取决于函数内部有没有使用合适的调度器或异步 API。

###### 面试可能怎么问

- `Dispatchers.IO` 和 `Dispatchers.Default` 有什么区别？
- `withContext` 和 `launch` 有什么区别？

<a id="生命周期感知收集-flow"></a>
###### 生命周期感知收集 Flow

推荐写法：

```kotlin
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            render(state)
        }
    }
}
```

原因：

- `repeatOnLifecycle` 会在生命周期达到指定状态时启动收集，低于该状态时取消收集。
- 页面不可见时停止收集，可以减少无意义 UI 更新。
- Fragment 中使用 `viewLifecycleOwner` 可以让收集跟 View 生命周期绑定，避免访问已销毁的 View。

不推荐：

```kotlin
lifecycleScope.launch {
    viewModel.uiState.collect { render(it) }
}
```

问题：

- 这类写法可能在页面进入后台后仍持续收集。
- Fragment View 销毁后，如果还引用 binding，可能触发空指针或内存泄漏。

###### 面试可能怎么问

- 为什么收集 Flow 推荐使用 `repeatOnLifecycle`？
- Fragment 里为什么要用 `viewLifecycleOwner.lifecycleScope`？

<a id="结构化并发和取消"></a>
###### 结构化并发和取消

结构化并发的核心：

- 子协程属于父协程。
- 父协程取消时，子协程会一起取消。
- 父协程默认会等待子协程完成。
- 子协程异常通常会影响父协程，具体取决于作用域和 Job 类型。

示例：

```kotlin
viewModelScope.launch {
    val profile = async { repository.loadProfile() }
    val messages = async { repository.loadMessages() }

    _uiState.value = HomeUiState.Success(
        profile = profile.await(),
        messages = messages.await()
    )
}
```

取消注意点：

- 协程取消是协作式的。挂起函数通常会检查取消状态，但纯 CPU 循环需要主动检查。
- 捕获异常时不要吞掉 `CancellationException`，否则可能破坏取消流程。
- 页面销毁或 ViewModel 清除后，生命周期作用域会自动取消内部协程。

CPU 循环中检查取消：

```kotlin
while (isActive) {
    doSmallWork()
}
```

###### 面试可能怎么问

- 什么是结构化并发？
- 协程取消为什么说是协作式的？

<a id="异常处理"></a>
###### 异常处理

常见处理方式：

```kotlin
viewModelScope.launch {
    try {
        val data = repository.loadData()
        _uiState.value = UiState.Success(data)
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        _uiState.value = UiState.Error(e.message ?: "未知错误")
    }
}
```

要点：

- `try/catch` 适合在当前协程内部处理业务错误。
- `CoroutineExceptionHandler` 主要处理未捕获异常，不能替代业务层错误处理。
- `async` 的异常通常在 `await()` 时抛出。
- `CancellationException` 表示取消信号，通常应该继续抛出。
- 多个子任务互不影响时，可以考虑 `supervisorScope` 或 `SupervisorJob`，但要明确每个子任务失败后的 UI 策略。

`async` 示例：

```kotlin
viewModelScope.launch {
    try {
        val userDeferred = async { repository.loadUser() }
        val orderDeferred = async { repository.loadOrders() }
        render(userDeferred.await(), orderDeferred.await())
    } catch (e: Exception) {
        showError(e)
    }
}
```

###### 面试可能怎么问

- `launch` 和 `async` 的异常有什么区别？
- 为什么捕获异常时要注意 `CancellationException`？

<a id="stateflow-和-sharedflow-使用"></a>
###### StateFlow 和 SharedFlow 使用

`StateFlow` 适合表示 UI 状态：

```kotlin
private val _uiState = MutableStateFlow(LoginUiState())
val uiState: StateFlow<LoginUiState> = _uiState
```

特点：

- 总有一个当前值。
- 新收集者会立即收到当前值。
- 适合页面状态：loading、content、error、empty。

`SharedFlow` 适合表示事件：

```kotlin
private val _events = MutableSharedFlow<LoginEvent>()
val events: SharedFlow<LoginEvent> = _events

fun login() {
    viewModelScope.launch {
        _events.emit(LoginEvent.ShowToast("登录成功"))
    }
}
```

特点：

- 默认没有当前值。
- 适合一次性事件：Toast、导航、弹窗、Snackbar。
- 需要根据业务设置 `replay`、缓冲和丢弃策略。

###### 面试可能怎么问

- `StateFlow` 和 `SharedFlow` 分别适合什么场景？

<a id="常见坑"></a>
###### 常见坑

- 在主线程执行阻塞 IO，导致卡顿甚至 ANR。
- 在 Fragment 中用 `lifecycleScope` 持续收集并访问旧 binding。
- 用 `GlobalScope` 启动页面任务，页面销毁后任务仍然运行。
- 忘记处理异常，接口失败后协程直接取消，UI 没有错误态。
- 捕获所有异常时吞掉 `CancellationException`。
- 把一次性事件放进 `StateFlow`，导致页面重建后重复弹 Toast 或重复导航。
- 在 Repository 中返回 `LiveData`、`Flow`、回调和 suspend 混用过度，调用链难以维护。

###### 面试可能怎么问

- Android 协程使用中有哪些常见坑？
