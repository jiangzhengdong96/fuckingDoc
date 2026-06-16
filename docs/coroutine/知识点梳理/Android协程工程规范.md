### Android 协程工程规范

###### 内容概述

本文件记录 Android 项目中使用协程的工程规范，包括分层职责、作用域选择、Dispatcher 注入、UI 状态建模、错误处理、Flow 暴露、生命周期收集、测试和代码审查要点。

###### 使用场景

- 新项目制定协程使用规范。
- 老项目从回调、RxJava、Handler 或 Executor 迁移到协程。
- Code Review 时检查协程代码是否符合 Android 分层和生命周期要求。

一级栏目导航：

- [分层职责](#分层职责)
- [作用域选择](#作用域选择)
- [Dispatcher 注入](#dispatcher-注入)
- [Repository 暴露 suspend 还是 Flow](#repository-暴露-suspend-还是-flow)
- [UI 状态建模](#ui-状态建模)
- [事件处理](#事件处理)
- [错误处理](#错误处理)
- [生命周期收集](#生命周期收集)
- [测试规范](#测试规范)
- [Code Review 清单](#code-review-清单)

<a id="分层职责"></a>
###### 分层职责

推荐分层：

```text
UI(Activity/Fragment/Compose)
  -> ViewModel
  -> UseCase(optional)
  -> Repository
  -> DataSource(Api/Dao/File)
```

职责：

- UI 层：只触发用户意图、收集状态、渲染界面。
- ViewModel：启动页面相关协程、编排业务、维护 UI 状态。
- UseCase：承载可复用业务流程，适合多个 Repository 组合。
- Repository：提供数据能力，对外暴露 `suspend` 或 `Flow`。
- DataSource：处理 Retrofit、Room、文件、SDK 回调等具体数据来源。

不建议：

- 在 Fragment 里直接写网络请求和数据库逻辑。
- 在 Repository 中直接引用 View 或 Activity。
- 在 DataSource 里更新 UI 状态。

###### 面试可能怎么问

- Android 项目里协程应该放在哪一层使用？

<a id="作用域选择"></a>
###### 作用域选择

推荐：

- ViewModel 中使用 `viewModelScope`。
- Activity / Fragment 中使用 `lifecycleScope` 或 `viewLifecycleOwner.lifecycleScope`。
- Compose 中使用 `LaunchedEffect`、`rememberCoroutineScope`。
- Repository 默认不要随便创建长期作用域；如果确实需要，必须明确生命周期和取消时机。

示例：

```kotlin
class ProfileViewModel(
    private val repository: ProfileRepository
) : ViewModel() {

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = ProfileUiState.Loading
            _uiState.value = ProfileUiState.Content(repository.loadProfile())
        }
    }
}
```

不建议：

```kotlin
GlobalScope.launch {
    repository.sync()
}
```

原因：

- 任务没有明确 owner。
- 页面销毁后不会自动取消。
- 异常和结果回调难以追踪。

###### 面试可能怎么问

- Repository 里能不能直接创建 CoroutineScope？

<a id="dispatcher-注入"></a>
###### Dispatcher 注入

不要在所有代码里硬编码 Dispatcher：

```kotlin
class UserRepository {
    suspend fun loadUser(): User = withContext(Dispatchers.IO) {
        api.getUser()
    }
}
```

更推荐通过构造参数注入：

```kotlin
class AppDispatchers(
    val io: CoroutineDispatcher = Dispatchers.IO,
    val default: CoroutineDispatcher = Dispatchers.Default,
    val main: CoroutineDispatcher = Dispatchers.Main
)

class UserRepository(
    private val api: UserApi,
    private val dispatchers: AppDispatchers
) {
    suspend fun loadUser(): User = withContext(dispatchers.io) {
        api.getUser()
    }
}
```

好处：

- 测试时可以替换为 TestDispatcher。
- 线程策略集中管理。
- 更容易看出某段代码应该运行在哪类线程。

###### 面试可能怎么问

- 为什么建议注入 Dispatcher，而不是到处写 Dispatchers.IO？

<a id="repository-暴露-suspend-还是-flow"></a>
###### Repository 暴露 suspend 还是 Flow

选择规则：

| 返回类型 | 适合场景 |
|---|---|
| `suspend fun` | 单次请求、单次查询、提交表单、保存设置 |
| `Flow<T>` | 数据会持续变化，例如 Room 查询、订阅状态、搜索输入、分页数据流 |
| `StateFlow<T>` | 通常在 ViewModel 内部建模 UI 状态，不建议 Repository 随意暴露页面状态 |
| `SharedFlow<T>` | 页面事件通常由 ViewModel 暴露，不建议 Repository 直接控制 UI 事件 |

示例：

```kotlin
interface UserRepository {
    suspend fun refreshUser(id: String): User
    fun observeUser(id: String): Flow<User>
}
```

注意：

- Repository 负责领域数据，不负责 UI loading、Toast、导航。
- ViewModel 把 Repository 结果转换成 UI State。

###### 面试可能怎么问

- Repository 方法什么时候返回 suspend，什么时候返回 Flow？

<a id="ui-状态建模"></a>
###### UI 状态建模

推荐用 sealed interface 表达页面状态：

```kotlin
sealed interface UserUiState {
    data object Loading : UserUiState
    data class Content(val user: User) : UserUiState
    data class Error(val message: String) : UserUiState
}
```

ViewModel 内部可变，对外只读：

```kotlin
private val _uiState = MutableStateFlow<UserUiState>(UserUiState.Loading)
val uiState: StateFlow<UserUiState> = _uiState
```

好处：

- UI 渲染入口统一。
- loading、content、error、empty 不容易散落成多个 Boolean。
- 页面重建后能拿到最新状态。

不建议：

```kotlin
var loading = false
var error: String? = null
var user: User? = null
```

问题：

- 状态组合容易互相矛盾，例如同时 loading 和 error。
- 多个字段更新不是原子语义，UI 容易短暂看到中间态。

###### 面试可能怎么问

- 为什么 ViewModel 常用 StateFlow 表示 UI 状态？

<a id="事件处理"></a>
###### 事件处理

一次性事件不要直接塞进 `StateFlow` 状态里反复消费。

推荐：

```kotlin
sealed interface LoginEvent {
    data class Toast(val message: String) : LoginEvent
    data object NavigateHome : LoginEvent
}

private val _events = MutableSharedFlow<LoginEvent>()
val events: SharedFlow<LoginEvent> = _events

private suspend fun sendLoginSuccess() {
    _events.emit(LoginEvent.Toast("登录成功"))
    _events.emit(LoginEvent.NavigateHome)
}
```

适合 SharedFlow 的事件：

- Toast
- Snackbar
- 页面跳转
- 弹窗
- 震动或一次性动画

注意：

- 根据业务决定 `replay` 是否为 0。
- 页面重建后不应该重复执行的事件，不要做成粘性状态。

###### 面试可能怎么问

- Toast 和导航事件为什么不建议直接放进 StateFlow？

<a id="错误处理"></a>
###### 错误处理

推荐在 ViewModel 把异常转换为 UI 状态：

```kotlin
viewModelScope.launch {
    _uiState.value = UserUiState.Loading
    try {
        val user = repository.refreshUser(userId)
        _uiState.value = UserUiState.Content(user)
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        _uiState.value = UserUiState.Error(e.message ?: "加载失败")
    }
}
```

规范：

- 不要吞掉 `CancellationException`。
- Repository 可以把底层错误转换成领域错误，但不要直接弹 Toast。
- ViewModel 决定页面错误态和重试入口。
- 全局兜底日志可以有，但不能替代业务错误处理。

###### 面试可能怎么问

- 协程异常应该在哪一层转成 UI 错误态？

<a id="生命周期收集"></a>
###### 生命周期收集

Fragment 推荐：

```kotlin
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            render(state)
        }
    }
}
```

规范：

- Fragment 访问 View 时优先用 `viewLifecycleOwner.lifecycleScope`。
- 不要在 `onCreate()` 中收集并访问 binding。
- Flow 收集和页面可见性有关时，优先用 `repeatOnLifecycle`。
- Compose 中根据副作用类型选择 `LaunchedEffect`、`rememberCoroutineScope`、`collectAsStateWithLifecycle`。

###### 面试可能怎么问

- Fragment 中收集 StateFlow 为什么要绑定 viewLifecycleOwner？

<a id="测试规范"></a>
###### 测试规范

为了可测试：

- Dispatcher 通过构造参数注入。
- ViewModel 状态用 `StateFlow` 暴露。
- Repository 依赖接口而不是具体实现。
- 避免在业务代码中硬编码 `Dispatchers.Main` / `Dispatchers.IO`。

测试思路：

```kotlin
@Test
fun loadUser_success_updatesContentState() = runTest {
    val repository = FakeUserRepository()
    val viewModel = UserViewModel(repository, testDispatchers)

    viewModel.loadUser("1")

    assertEquals(UserUiState.Content(repository.user), viewModel.uiState.value)
}
```

注意：

- `runTest` 适合测试协程。
- Main Dispatcher 在单元测试中通常需要替换。
- Flow 的连续发射可以用 Turbine 或手动收集验证，具体工具按项目依赖决定。

###### 面试可能怎么问

- 协程代码怎么设计才方便单元测试？

<a id="code-review-清单"></a>
###### Code Review 清单

检查项：

- 是否使用了合适的作用域。
- 是否避免了 `GlobalScope`。
- 是否在 IO / Default / Main 之间正确切换。
- 是否吞掉了 `CancellationException`。
- Fragment 收集 Flow 是否使用 `viewLifecycleOwner` 和生命周期感知方式。
- ViewModel 是否只暴露只读 `StateFlow` / `SharedFlow`。
- 一次性事件是否避免放进粘性状态。
- Dispatcher 是否可测试、可替换。
- Repository 是否避免直接处理 UI。
- 是否有明确的 loading、error、empty、content 状态。

###### 面试可能怎么问

- Code Review Android 协程代码时重点看什么？
