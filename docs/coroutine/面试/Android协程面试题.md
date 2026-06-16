### Android 协程面试题

###### 内容概述

这里记录 Android 协程高频面试题，覆盖协程定位、作用域、调度器、启动方式、生命周期收集、结构化并发、异常处理、StateFlow / SharedFlow 和常见实践问题。

面试题导航：

- [协程和线程有什么区别](#协程和线程有什么区别)
- [Android 中为什么推荐使用 viewModelScope](#android-中为什么推荐使用-viewmodelscope)
- [viewModelScope 和 lifecycleScope 有什么区别](#viewmodelscope-和-lifecyclescope-有什么区别)
- [为什么不建议使用 GlobalScope](#为什么不建议使用-globalscope)
- [launch async withContext 有什么区别](#launch-async-withcontext-有什么区别)
- [Dispatchers Main IO Default 怎么选择](#dispatchers-main-io-default-怎么选择)
- [Fragment 收集 Flow 为什么推荐 repeatOnLifecycle](#fragment-收集-flow-为什么推荐-repeatonlifecycle)
- [什么是结构化并发](#什么是结构化并发)
- [协程取消为什么是协作式的](#协程取消为什么是协作式的)
- [launch 和 async 的异常传播有什么区别](#launch-和-async-的异常传播有什么区别)
- [为什么捕获异常时要注意 CancellationException](#为什么捕获异常时要注意-cancellationexception)
- [StateFlow 和 SharedFlow 有什么区别](#stateflow-和-sharedflow-有什么区别)
- [Android 协程常见使用方式是什么](#android-协程常见使用方式是什么)
- [协程相比 Thread Handler Executor 有什么优势](#协程相比-thread-handler-executor-有什么优势)
- [协程和 RxJava LiveData 怎么取舍](#协程和-rxjava-livedata-怎么取舍)
- [Android 项目里协程工程规范有哪些](#android-项目里协程工程规范有哪些)
- [Android 协程有哪些常见坑](#android-协程有哪些常见坑)

<a id="协程和线程有什么区别"></a>
###### 协程和线程有什么区别

答案：

**简答：** 线程是系统调度的执行资源，协程是运行在线程上的轻量级并发任务。协程本身不等于线程，协程在哪个线程执行由调度器决定。

**展开回答：** Android 中使用协程主要是为了让异步任务更容易编写、取消和组合。比如网络请求可以写成顺序代码，挂起时不会阻塞主线程；等结果回来后再恢复执行。线程更底层，直接手写线程需要自己处理切换、取消、异常和生命周期。

**易错点：** 挂起函数不一定自动切到后台线程，是否切线程要看内部实现或是否使用 `withContext(Dispatchers.IO)`。

**关联知识点：** [Android 协程 - 协程解决什么问题](../知识点梳理/Android协程.md#协程解决什么问题)

<a id="android-中为什么推荐使用-viewmodelscope"></a>
###### Android 中为什么推荐使用 viewModelScope

答案：

**简答：** `viewModelScope` 会跟随 ViewModel 生命周期自动取消，适合发起页面数据请求、业务组合和 UI 状态更新。

**展开回答：** ViewModel 通常承载页面状态，页面旋转时 ViewModel 可以保留，而页面真正结束时 ViewModel 会被清理。`viewModelScope` 在 `onCleared()` 时取消内部协程，能减少请求回调更新已销毁页面、任务泄漏和手动管理 Job 的复杂度。

**易错点：** `viewModelScope` 适合页面状态相关任务，不适合需要跨页面长期运行的全局任务。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="viewmodelscope-和-lifecyclescope-有什么区别"></a>
###### viewModelScope 和 lifecycleScope 有什么区别

答案：

**简答：** `viewModelScope` 绑定 ViewModel 生命周期，`lifecycleScope` 绑定 Activity 或 Fragment 的 Lifecycle。

**展开回答：** ViewModel 中的数据加载和状态管理一般放在 `viewModelScope`；Activity / Fragment 中和 UI 生命周期直接相关的任务可以用 `lifecycleScope`。Fragment 收集 UI 状态时，通常使用 `viewLifecycleOwner.lifecycleScope`，因为 Fragment 的 View 生命周期可能短于 Fragment 本身。

**易错点：** Fragment 中直接用 `fragment.lifecycleScope` 收集并访问 binding，可能在 View 销毁后继续访问旧 View。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="为什么不建议使用-globalscope"></a>
###### 为什么不建议使用 GlobalScope

答案：

**简答：** `GlobalScope` 不绑定页面、ViewModel 或业务对象生命周期，任务启动后容易变成无主任务，导致泄漏、重复请求或结果回调到错误页面。

**展开回答：** Android 任务大多数都和某个页面、业务流程或应用组件有关。使用 `viewModelScope`、`lifecycleScope` 或自定义可取消作用域，可以在生命周期结束时取消任务。`GlobalScope` 只有在极少数真正全局且可控的后台任务中才可能考虑，并且要有明确取消策略。

**易错点：** 用 `GlobalScope` 解决“作用域拿不到”的问题通常是设计问题，不是最佳实践。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="launch-async-withcontext-有什么区别"></a>
###### launch async withContext 有什么区别

答案：

**简答：** `launch` 启动不直接返回结果的协程，返回 `Job`；`async` 启动需要结果的协程，返回 `Deferred`，通过 `await()` 取结果；`withContext` 在当前协程中切换上下文并等待结果。

**展开回答：** Android 中常用 `launch` 发起 UI 状态更新流程；需要并发请求多个结果时可以用 `async`；需要把一段 IO 或计算切到指定线程时用 `withContext`。`withContext` 不会创建一个和当前流程无关的任务，它仍然属于当前结构化并发链路。

**易错点：** 不要用 `async` 但不 `await()`，这会让结果和异常都难以管理。

**关联知识点：** [Android 协程 - 调度器和线程切换](../知识点梳理/Android协程.md#调度器和线程切换)

<a id="dispatchers-main-io-default-怎么选择"></a>
###### Dispatchers Main IO Default 怎么选择

答案：

**简答：** `Main` 用于 UI，`IO` 用于网络、数据库、文件等阻塞 IO，`Default` 用于 CPU 密集计算。

**展开回答：** Android 主线程不能执行耗时阻塞任务，否则可能卡顿或 ANR。网络、数据库、文件读写通常放到 `Dispatchers.IO`；大量排序、加密、压缩、JSON 大量解析等 CPU 任务更适合 `Dispatchers.Default`。UI 更新必须回到主线程。

**易错点：** `Dispatchers.IO` 不是万能后台线程池，CPU 密集任务放到 IO 里会影响 IO 任务调度。

**关联知识点：** [Android 协程 - 调度器和线程切换](../知识点梳理/Android协程.md#调度器和线程切换)

<a id="fragment-收集-flow-为什么推荐-repeatonlifecycle"></a>
###### Fragment 收集 Flow 为什么推荐 repeatOnLifecycle

答案：

**简答：** 因为 `repeatOnLifecycle` 能在生命周期达到指定状态时收集，低于该状态时自动取消收集，避免页面不可见还持续更新 UI。

**展开回答：** Fragment 的 View 会创建和销毁多次，如果收集 Flow 的协程没有绑定 `viewLifecycleOwner`，就可能访问已经销毁的 binding。`repeatOnLifecycle(Lifecycle.State.STARTED)` 可以让页面可见时收集，不可见时停止，重新可见时再启动。

**易错点：** `launchWhenStarted` 这类旧写法容易让上游 Flow 仍然活跃，实际项目中更推荐 `repeatOnLifecycle`。

**关联知识点：** [Android 协程 - 生命周期感知收集 Flow](../知识点梳理/Android协程.md#生命周期感知收集-flow)

<a id="什么是结构化并发"></a>
###### 什么是结构化并发

答案：

**简答：** 结构化并发要求协程有明确父子关系，子协程属于父协程，父协程取消时子协程也会取消，父协程会等待子协程完成。

**展开回答：** 结构化并发让异步任务不再到处散落。比如 `viewModelScope.launch` 里启动的多个 `async` 子任务，都归属于这个父协程。页面结束或 ViewModel 清理时，整个任务树可以一起取消。

**易错点：** 逃离当前作用域的任务会破坏结构化并发，例如随意使用 `GlobalScope`。

**关联知识点：** [Android 协程 - 结构化并发和取消](../知识点梳理/Android协程.md#结构化并发和取消)

<a id="协程取消为什么是协作式的"></a>
###### 协程取消为什么是协作式的

答案：

**简答：** 协程取消不会强制杀死正在执行的代码，而是通过取消状态让协程在挂起点或主动检查时退出。

**展开回答：** 大多数挂起函数会检查取消状态，所以网络请求、delay、withContext 等通常能响应取消。但如果协程里是长时间 CPU 循环，就需要使用 `isActive`、`ensureActive()` 或 `yield()` 主动响应取消。

**易错点：** 捕获 `Exception` 后不重新抛出 `CancellationException`，可能导致协程无法正确取消。

**关联知识点：** [Android 协程 - 结构化并发和取消](../知识点梳理/Android协程.md#结构化并发和取消)

<a id="launch-和-async-的异常传播有什么区别"></a>
###### launch 和 async 的异常传播有什么区别

答案：

**简答：** `launch` 中未捕获异常会直接向父协程传播；`async` 的异常通常封装在 `Deferred` 中，在 `await()` 时重新抛出。

**展开回答：** 如果 `async` 启动后没有 `await()`，异常可能不会在你预期的位置暴露。实际项目中，使用 `async` 并发请求时要明确在哪里 `await()`，并在外层统一处理失败后的 UI 状态。

**易错点：** 以为 `CoroutineExceptionHandler` 能捕获所有 `async` 异常，这是不准确的；`async` 异常通常要通过 `await()` 处理。

**关联知识点：** [Android 协程 - 异常处理](../知识点梳理/Android协程.md#异常处理)

<a id="为什么捕获异常时要注意-cancellationexception"></a>
###### 为什么捕获异常时要注意 CancellationException

答案：

**简答：** `CancellationException` 是协程取消的正常信号，通常应该继续抛出，不应该当成普通业务错误吞掉。

**展开回答：** 很多代码会写 `catch (e: Exception)` 统一处理错误，但 `CancellationException` 也是异常的一种。如果把它吞掉，父子协程取消流程可能被破坏，任务可能继续执行清理之外的逻辑。

**易错点：** 正确写法通常是先 `catch (e: CancellationException) { throw e }`，再捕获普通 `Exception`。

**关联知识点：** [Android 协程 - 异常处理](../知识点梳理/Android协程.md#异常处理)

<a id="stateflow-和-sharedflow-有什么区别"></a>
###### StateFlow 和 SharedFlow 有什么区别

答案：

**简答：** `StateFlow` 表示状态，有当前值，新订阅者会立即收到最新值；`SharedFlow` 更适合事件，默认没有当前值，可配置 replay 和缓冲策略。

**展开回答：** 页面 loading、content、error、empty 这类状态适合用 `StateFlow`；Toast、导航、Snackbar 这类一次性事件更适合用 `SharedFlow`。把事件放进 `StateFlow` 容易在页面重建后重复消费。

**易错点：** `StateFlow` 不是事件总线，不能无脑承载所有 UI 通知。

**关联知识点：** [Android 协程 - StateFlow 和 SharedFlow 使用](../知识点梳理/Android协程.md#stateflow-和-sharedflow-使用)

<a id="android-协程常见使用方式是什么"></a>
###### Android 协程常见使用方式是什么

答案：

**简答：** ViewModel 用 `viewModelScope` 发起任务并更新 `StateFlow`，Repository 用 suspend 函数和 `withContext(Dispatchers.IO)` 处理数据，Fragment 用 `repeatOnLifecycle` 收集状态并渲染 UI。

**展开回答：** 常见分层是：UI 层只收集状态和触发事件；ViewModel 编排业务和维护状态；Repository 负责网络、数据库和缓存。这样可以减少 UI 层复杂度，也方便测试和复用。

**易错点：** 不要把网络请求、数据库写入和复杂业务都塞进 Fragment。

**关联知识点：** [Android 协程 - Android 常用使用方式](../知识点梳理/Android协程.md#android-常用使用方式)

<a id="协程相比-thread-handler-executor-有什么优势"></a>
###### 协程相比 Thread Handler Executor 有什么优势

答案：

**简答：** 协程能用顺序代码表达异步流程，并提供结构化并发、取消、异常传播、调度器切换和生命周期绑定；`Thread`、`Handler`、`Executor` 更底层，需要手动处理更多细节。

**展开回答：** `Thread` 直接对应系统线程，创建和管理成本高；`Handler` 适合消息队列和线程投递，但业务延迟任务需要手动移除；`Executor` 管线程池，但不直接管理父子任务、页面生命周期和挂起恢复。协程在 Android 中能结合 `viewModelScope`、`lifecycleScope`、`withContext`、`repeatOnLifecycle` 建立更完整的异步流程。

**易错点：** 协程不是完全替代传统工具。底层消息分发、精细线程池控制、老项目兼容场景仍可能保留 `Handler` 或 `Executor`。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md)

<a id="协程和-rxjava-livedata-怎么取舍"></a>
###### 协程和 RxJava LiveData 怎么取舍

答案：

**简答：** 单次异步任务优先用 `suspend`，连续数据流优先用 `Flow`；老项目已有复杂 RxJava 链可以渐进迁移；XML 老项目可继续用 `LiveData`，新 Kotlin 项目更常用 `StateFlow` / `SharedFlow`。

**展开回答：** RxJava 操作符强大，但学习和维护成本较高；协程和 Flow 与 ViewModel、Lifecycle、Room、Retrofit、Compose 生态结合更自然。LiveData 更偏 UI 层生命周期感知观察，Flow 更通用，适合从数据层到 ViewModel 做组合和转换。

**易错点：** LiveData 和协程不是完全同类；LiveData 主要是可观察数据容器，协程主要解决异步执行和并发组织。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和-rxjava-对比)

<a id="android-项目里协程工程规范有哪些"></a>
###### Android 项目里协程工程规范有哪些

答案：

**简答：** UI 层只触发事件和渲染状态，ViewModel 用 `viewModelScope` 编排业务并暴露只读状态，Repository 暴露 `suspend` 或 `Flow`，Dispatcher 可注入，Flow 收集绑定生命周期，错误统一转换成 UI 状态。

**展开回答：** 协程工程规范的重点是防止异步逻辑散落。Fragment 不应该直接写网络和数据库；Repository 不应该直接操作 UI；ViewModel 应该把数据结果转换成 `StateFlow` UI 状态；一次性事件用 `SharedFlow`；测试时通过注入 Dispatcher 替换线程策略。

**易错点：** 只要代码用了协程，不代表它就是规范的协程代码，还要看分层、作用域、调度器、异常和测试。

**关联知识点：** [Android 协程工程规范](../知识点梳理/Android协程工程规范.md)

<a id="android-协程有哪些常见坑"></a>
###### Android 协程有哪些常见坑

答案：

**简答：** 常见坑包括主线程阻塞、错误作用域、Flow 收集不绑定生命周期、异常未处理、吞掉取消异常、事件状态混用和滥用 `GlobalScope`。

**展开回答：** Android 协程问题大多不是语法问题，而是生命周期、线程和状态管理问题。排查时要看任务属于谁、什么时候取消、在哪个线程运行、异常在哪里处理、UI 是否可能重复消费事件。

**易错点：** 看到用了协程不代表异步和生命周期就自动正确，还要看作用域、调度器和收集方式。

**关联知识点：** [Android 协程 - 常见坑](../知识点梳理/Android协程.md#常见坑)
