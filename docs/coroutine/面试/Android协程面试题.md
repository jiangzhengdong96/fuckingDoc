### Android 协程面试题

<!-- page-toc:start -->
**目录**

- [内容概述](#section-内容概述)
- [协程和线程有什么区别](#协程和线程有什么区别)
- [协程核心对象之间是什么关系](#协程核心对象之间是什么关系)
- [CoroutineContext 里常见配置项有哪些](#coroutinecontext-里常见配置项有哪些)
- [suspend 函数底层为什么能挂起恢复](#suspend-函数底层为什么能挂起恢复)
- [Android 中为什么推荐使用 viewModelScope](#android-中为什么推荐使用-viewmodelscope)
- [Android 中各种级别作用域怎么选](#android-中各种级别作用域怎么选)
- [viewModelScope 和 lifecycleScope 有什么区别](#viewmodelscope-和-lifecyclescope-有什么区别)
- [为什么不建议使用 GlobalScope](#为什么不建议使用-globalscope)
- [launch async withContext 有什么区别](#launch-async-withcontext-有什么区别)
- [launch 的 context start block 参数分别是什么](#launch-的-context-start-block-参数分别是什么)
- [Dispatchers Main IO Default 怎么选择](#dispatchers-main-io-default-怎么选择)
- [Fragment 收集 Flow 为什么推荐 repeatOnLifecycle](#fragment-收集-flow-为什么推荐-repeatonlifecycle)
- [什么是结构化并发](#什么是结构化并发)
- [协程取消为什么是协作式的](#协程取消为什么是协作式的)
- [launch 和 async 的异常传播有什么区别](#launch-和-async-的异常传播有什么区别)
- [Job SupervisorJob CoroutineExceptionHandler 怎么配合](#job-supervisorjob-coroutineexceptionhandler-怎么配合)
- [为什么捕获异常时要注意 CancellationException](#为什么捕获异常时要注意-cancellationexception)
- [StateFlow 和 SharedFlow 有什么区别](#stateflow-和-sharedflow-有什么区别)
- [SharedFlow 的 replay 和 extraBufferCapacity 有什么区别](#sharedflow-缓存参数)
- [SharedFlow 缓冲满了怎么办 emit 和 tryEmit 有什么区别](#sharedflow-溢出与发送)
- [Android 协程常见使用方式是什么](#android-协程常见使用方式是什么)
- [协程相比 Thread Handler Executor 有什么优势](#协程相比-thread-handler-executor-有什么优势)
- [协程和 RxJava LiveData 怎么取舍](#协程和-rxjava-livedata-怎么取舍)
- [Android 项目里协程工程规范有哪些](#android-项目里协程工程规范有哪些)
- [Android 协程有哪些常见坑](#android-协程有哪些常见坑)
- [Dispatchers.Main 是哪个依赖提供的](#dispatchers.main-是哪个依赖提供的)
- [launch 和 async 底层创建的对象有什么区别](#launch-和-async-底层创建的对象有什么区别)
- [Continuation 在挂起恢复中起什么作用](#continuation-在挂起恢复中起什么作用)
- [为什么不建议在 viewModelScope.launch 中传入新的 Job](#为什么不建议在-viewmodelscope.launch-中传入新的-job)
- [CoroutineExceptionHandler 能捕获所有异常吗](#coroutineexceptionhandler-能捕获所有异常吗)
- [Repository 能不能创建自己的 CoroutineScope](#repository-能不能创建自己的-coroutinescope)
- [CoroutineStart.LAZY 什么时候启动](#coroutinestart.lazy-什么时候启动)
- [coroutineScope 和 supervisorScope 有什么区别](#coroutinescope-和-supervisorscope-有什么区别)
- [delay 和 Thread.sleep 有什么区别](#delay-和-thread.sleep-有什么区别)
- [Dispatchers.Main.immediate 和 Main 有什么区别](#dispatchers.main.immediate-和-main-有什么区别)
- [withContext Dispatchers.IO 底层大概做了什么](#withcontext-dispatchers.io-底层大概做了什么)
- [flowOn 改的是上游还是下游线程](#flowon-改的是上游还是下游线程)
- [Android 项目中协程配置通常怎么抽象](#android-项目中协程配置通常怎么抽象)
- [排查协程泄漏异常丢失和线程用错时看哪些点](#排查协程泄漏异常丢失和线程用错时看哪些点)
- [为什么建议注入 Dispatcher](#为什么建议注入-dispatcher)
- [Repository 什么时候用 suspend 什么时候用 Flow](#repository-什么时候用-suspend-什么时候用-flow)
- [为什么 ViewModel 常用 StateFlow 表示 UI 状态](#为什么-viewmodel-常用-stateflow-表示-ui-状态)
- [Toast 和导航事件为什么不建议直接放进 StateFlow](#toast-和导航事件为什么不建议直接放进-stateflow)
- [协程异常应该在哪一层转成 UI 错误态](#协程异常应该在哪一层转成-ui-错误态)
- [协程代码怎么设计才方便单元测试](#协程代码怎么设计才方便单元测试)
- [Code Review Android 协程代码时重点看什么](#code-review-android-协程代码时重点看什么)
- [协程相比回调写法解决了什么问题](#协程相比回调写法解决了什么问题)
- [有了协程以后 Handler 还有必要吗](#有了协程以后-handler-还有必要吗)
- [Dispatcher 和 Executor 是什么关系](#dispatcher-和-executor-是什么关系)
- [为什么不建议继续用 AsyncTask](#为什么不建议继续用-asynctask)
- [LiveData 和 StateFlow 怎么选择](#livedata-和-stateflow-怎么选择)
- [什么时候用协程什么时候保留传统异步方案](#什么时候用协程什么时候保留传统异步方案)
<!-- page-toc:end -->


<a id="section-内容概述"></a>
###### 内容概述

这里记录 Android 协程高频面试题，覆盖协程定位、作用域、调度器、启动方式、生命周期收集、结构化并发、异常处理、StateFlow / SharedFlow 和常见实践问题。

以下题目已归入协程知识点笔记中全部“面试可能怎么问”；相近问法合并在对应题目的“相关问法”中。

<a id="协程和线程有什么区别"></a>
###### 协程和线程有什么区别

**相关问法：**

- 协程和线程有什么区别？

答案：

**简答：** 线程是系统调度的执行资源，协程是运行在线程上的轻量级并发任务。协程本身不等于线程，协程在哪个线程执行由调度器决定。

**展开回答：** Android 中使用协程主要是为了让异步任务更容易编写、取消和组合。比如网络请求可以写成顺序代码，挂起时不会阻塞主线程；等结果回来后再恢复执行。线程更底层，直接手写线程需要自己处理切换、取消、异常和生命周期。协程轻量不是说没有线程切换成本，而是不用每个任务都创建独立线程，挂起时能释放线程，恢复时由调度器把续体投递回合适线程。

**易错点：** 挂起函数不一定自动切到后台线程，是否切线程要看内部实现或是否使用 `withContext(Dispatchers.IO)`。

**关联知识点：** [Android 协程 - 协程解决什么问题](../知识点梳理/Android协程.md#协程解决什么问题)

<a id="协程核心对象之间是什么关系"></a>
###### 协程核心对象之间是什么关系

**相关问法：**

- 协程底层有哪些核心对象？
- 协程核心对象有哪些？`CoroutineScope`、`CoroutineContext`、`Job`、`Dispatcher` 分别负责什么？

答案：

**简答：** `CoroutineScope` 是启动协程的归属入口，`CoroutineContext` 是协程配置集合，`Job` 管生命周期和父子关系，`CoroutineDispatcher` 决定线程调度，`Continuation` 保存挂起后的恢复点。

**展开回答：** 可以按这条链路理解：`CoroutineScope` 持有 `CoroutineContext`，context 里通常放 `Job`、`Dispatcher`、`CoroutineName`、`CoroutineExceptionHandler` 等元素；`launch` 或 `async` 基于 scope 创建协程；协程执行到 suspend 挂起点时，通过 `Continuation` 保存后续执行位置；结果回来后由 Dispatcher 把 continuation 恢复到合适线程继续执行。源码阅读时会看到 `StandaloneCoroutine`、`DeferredCoroutine`、`DispatchedContinuation`、`ContinuationImpl` 等实现名，但业务代码不应该依赖这些内部类。

**易错点：** 不要把协程等同于线程，也不要把 `CoroutineScope` 理解成线程池；真正管理生命周期的是 `Job`，真正决定执行线程的是 `Dispatcher`。

**关联知识点：** [协程核心对象和底层实现 - 核心对象关系](../知识点梳理/协程核心对象和底层实现.md#核心对象关系)

<a id="coroutinecontext-里常见配置项有哪些"></a>
###### CoroutineContext 里常见配置项有哪些

**相关问法：**

- `CoroutineContext` 里通常放哪些元素？

答案：

**简答：** 常见配置项包括 `Job` / `SupervisorJob`、`CoroutineDispatcher`、`CoroutineName`、`CoroutineExceptionHandler`，特殊挂起清理场景还会用 `NonCancellable`。

**展开回答：** `CoroutineContext` 可以通过 `+` 组合多个元素，例如 `SupervisorJob() + Dispatchers.IO + CoroutineName("sync")`。`Job` 决定任务生命周期和取消传播，`Dispatcher` 决定运行线程，`CoroutineName` 方便调试，`CoroutineExceptionHandler` 处理未捕获异常。相同 key 的元素后者会覆盖前者，所以在 `viewModelScope.launch(Job())` 里随便传新的 `Job` 可能改变父子关系，导致任务脱离原本的结构化并发链路。

**易错点：** `CoroutineExceptionHandler` 不是业务错误处理的替代品；接口失败、表单失败这类业务错误仍然应该在 ViewModel 或调用链中转成 UI 状态。

**关联知识点：** [协程核心对象和底层实现 - CoroutineContext 配置项](../知识点梳理/协程核心对象和底层实现.md#coroutinecontext-配置项)

<a id="suspend-函数底层为什么能挂起恢复"></a>
###### suspend 函数底层为什么能挂起恢复

**相关问法：**

- suspend 函数底层为什么能挂起和恢复？

答案：

**简答：** suspend 函数会被编译成带 `Continuation` 的状态机，挂起时保存当前执行位置和局部状态，结果回来后再从对应状态继续执行。

**展开回答：** suspend 不是自动开线程。它的核心是把“后续代码”包装成 continuation。执行到挂起点时，如果结果还没准备好，就返回挂起标记，当前线程可以去做别的事；异步结果回来后，通过 continuation 恢复，状态机根据 label 跳回挂起后的下一段代码。`delay()` 这类挂起函数不会像 `Thread.sleep()` 一样占住线程。

**易错点：** suspend 函数不等于后台函数。如果函数内部做文件读写、数据库阻塞查询或 CPU 密集计算，仍然要配合 `withContext(Dispatchers.IO)` 或 `Dispatchers.Default`。

**关联知识点：** [协程核心对象和底层实现 - 挂起函数和状态机](../知识点梳理/协程核心对象和底层实现.md#挂起函数和状态机)

<a id="android-中为什么推荐使用-viewmodelscope"></a>
###### Android 中为什么推荐使用 viewModelScope

答案：

**简答：** `viewModelScope` 会跟随 ViewModel 生命周期自动取消，适合发起页面数据请求、业务组合和 UI 状态更新。

**展开回答：** ViewModel 通常承载页面状态，页面旋转时 ViewModel 可以保留，而页面真正结束时 ViewModel 会被清理。`viewModelScope` 在 `onCleared()` 时取消内部协程，能减少请求回调更新已销毁页面、任务泄漏和手动管理 Job 的复杂度。

**易错点：** `viewModelScope` 适合页面状态相关任务，不适合需要跨页面长期运行的全局任务。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="android-中各种级别作用域怎么选"></a>
###### Android 中各种级别作用域怎么选

**相关问法：**

- Android 协程的作用域级别应该怎么选？
- Android 中有哪些级别的协程作用域？怎么选？

答案：

**简答：** 作用域选择看任务 owner：页面状态用 `viewModelScope`，更新 Fragment View 用 `viewLifecycleOwner.lifecycleScope`，生命周期短任务用 `lifecycleScope`，Compose 副作用用 `LaunchedEffect`，局部并发用 `coroutineScope` / `supervisorScope`，跨页面长期任务用明确 owner 的外部 scope。

**展开回答：** 协程作用域不是随便找个地方 launch，而是要回答“任务属于谁，什么时候取消”。例如页面数据加载属于 ViewModel，所以用 `viewModelScope`；Fragment View 销毁后不能再更新 binding，所以收集 UI 状态用 `viewLifecycleOwner.lifecycleScope`；多个接口并发组合并等待结果可以用 `coroutineScope`；多个区域互不影响可以用 `supervisorScope`。真正跨页面的同步任务可以由 Application 或 Manager 持有 `SupervisorJob + Dispatcher` 的外部 scope，并提供取消入口。

**易错点：** Repository 默认不应该因为拿不到 scope 就创建 `GlobalScope`；多数 Repository 暴露 `suspend` 或 `Flow`，由调用方决定生命周期。

**关联知识点：** [协程核心对象和底层实现 - 作用域级别](../知识点梳理/协程核心对象和底层实现.md#作用域级别)

<a id="viewmodelscope-和-lifecyclescope-有什么区别"></a>
###### viewModelScope 和 lifecycleScope 有什么区别

**相关问法：**

- `viewModelScope` 和 `lifecycleScope` 有什么区别？
- Fragment 里为什么要用 `viewLifecycleOwner.lifecycleScope`？
- Fragment 中收集 StateFlow 为什么要绑定 viewLifecycleOwner？
- `viewLifecycleOwner.lifecycleScope` 和 `lifecycleScope` 的区别是什么？

答案：

**简答：** `viewModelScope` 绑定 ViewModel 生命周期，`lifecycleScope` 绑定 Activity 或 Fragment 的 Lifecycle。

**展开回答：** ViewModel 中的数据加载和状态管理一般放在 `viewModelScope`；Activity / Fragment 中和 UI 生命周期直接相关的任务可以用 `lifecycleScope`。Fragment 收集 UI 状态时，通常使用 `viewLifecycleOwner.lifecycleScope`，因为 Fragment 的 View 生命周期可能短于 Fragment 本身。

**易错点：** Fragment 中直接用 `fragment.lifecycleScope` 收集并访问 binding，可能在 View 销毁后继续访问旧 View。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="为什么不建议使用-globalscope"></a>
###### 为什么不建议使用 GlobalScope

**相关问法：**

- 为什么不建议在 Android 中使用 `GlobalScope`？

答案：

**简答：** `GlobalScope` 不绑定页面、ViewModel 或业务对象生命周期，任务启动后容易变成无主任务，导致泄漏、重复请求或结果回调到错误页面。

**展开回答：** Android 任务大多数都和某个页面、业务流程或应用组件有关。使用 `viewModelScope`、`lifecycleScope` 或自定义可取消作用域，可以在生命周期结束时取消任务。`GlobalScope` 只有在极少数真正全局且可控的后台任务中才可能考虑，并且要有明确取消策略。

**易错点：** 用 `GlobalScope` 解决“作用域拿不到”的问题通常是设计问题，不是最佳实践。

**关联知识点：** [Android 协程 - Android 常用作用域](../知识点梳理/Android协程.md#android-常用作用域)

<a id="launch-async-withcontext-有什么区别"></a>
###### launch async withContext 有什么区别

**相关问法：**

- `withContext` 和 `launch` 有什么区别？

答案：

**简答：** `launch` 启动不直接返回结果的协程，返回 `Job`；`async` 启动需要结果的协程，返回 `Deferred`，通过 `await()` 取结果；`withContext` 在当前协程中切换上下文并等待结果。

**展开回答：** Android 中常用 `launch` 发起 UI 状态更新流程；需要并发请求多个结果时可以用 `async`；需要把一段 IO 或计算切到指定线程时用 `withContext`。`withContext` 不会创建一个和当前流程无关的任务，它仍然属于当前结构化并发链路。

**易错点：** 不要用 `async` 但不 `await()`，这会让结果和异常都难以管理。

**关联知识点：** [Android 协程 - 调度器和线程切换](../知识点梳理/Android协程.md#调度器和线程切换)

<a id="launch-的-context-start-block-参数分别是什么"></a>
###### launch 的 context start block 参数分别是什么

**相关问法：**

- `launch` 的 `context`、`start`、`block` 参数分别是什么？

答案：

**简答：** `context` 用来追加或覆盖本次协程的上下文配置，`start` 控制启动时机，`block` 是真正执行的协程体；`launch` 返回 `Job`。

**展开回答：** `launch(context = EmptyCoroutineContext, start = CoroutineStart.DEFAULT, block)` 会把当前 scope 的 context 和传入 context 合并，再创建一个子协程。常见 context 是 `Dispatchers.IO`、`CoroutineName`、`CoroutineExceptionHandler`；`start` 默认是 `DEFAULT`，`LAZY` 表示调用 `start()` / `join()` 时才启动，`ATOMIC` 和 `UNDISPATCHED` 偏底层场景，Android 业务很少用。`block` 里面再启动的子协程默认属于这个父协程。

**易错点：** 不要在 `viewModelScope.launch(Job())` 里随便传新的 `Job`，这可能改变父子取消关系；一般只传 Dispatcher、Name 或 Handler。

**关联知识点：** [协程核心对象和底层实现 - 启动方法参数](../知识点梳理/协程核心对象和底层实现.md#启动方法参数)

<a id="dispatchers-main-io-default-怎么选择"></a>
###### Dispatchers Main IO Default 怎么选择

**相关问法：**

- `Dispatchers.IO` 和 `Dispatchers.Default` 有什么区别？

答案：

**简答：** `Main` 用于 UI，`IO` 用于网络、数据库、文件等阻塞 IO，`Default` 用于 CPU 密集计算。

**展开回答：** Android 主线程不能执行耗时阻塞任务，否则可能卡顿或 ANR。网络、数据库、文件读写通常放到 `Dispatchers.IO`；大量排序、加密、压缩、JSON 大量解析等 CPU 任务更适合 `Dispatchers.Default`。UI 更新必须回到主线程。

**易错点：** `Dispatchers.IO` 不是万能后台线程池，CPU 密集任务放到 IO 里会影响 IO 任务调度。

**关联知识点：** [Android 协程 - 调度器和线程切换](../知识点梳理/Android协程.md#调度器和线程切换)

<a id="fragment-收集-flow-为什么推荐-repeatonlifecycle"></a>
###### Fragment 收集 Flow 为什么推荐 repeatOnLifecycle

**相关问法：**

- 为什么收集 Flow 推荐使用 `repeatOnLifecycle`？

答案：

**简答：** 因为 `repeatOnLifecycle` 能在生命周期达到指定状态时收集，低于该状态时自动取消收集，避免页面不可见还持续更新 UI。

**展开回答：** Fragment 的 View 会创建和销毁多次，如果收集 Flow 的协程没有绑定 `viewLifecycleOwner`，就可能访问已经销毁的 binding。`repeatOnLifecycle(Lifecycle.State.STARTED)` 可以让页面可见时收集，不可见时停止，重新可见时再启动。

**易错点：** `launchWhenStarted` 这类旧写法容易让上游 Flow 仍然活跃，实际项目中更推荐 `repeatOnLifecycle`。

**关联知识点：** [Android 协程 - 生命周期感知收集 Flow](../知识点梳理/Android协程.md#生命周期感知收集-flow)

<a id="什么是结构化并发"></a>
###### 什么是结构化并发

**相关问法：**

- 什么是结构化并发？

答案：

**简答：** 结构化并发要求协程有明确父子关系，子协程属于父协程，父协程取消时子协程也会取消，父协程会等待子协程完成。

**展开回答：** 结构化并发让异步任务不再到处散落。比如 `viewModelScope.launch` 里启动的多个 `async` 子任务，都归属于这个父协程。页面结束或 ViewModel 清理时，整个任务树可以一起取消。

**易错点：** 逃离当前作用域的任务会破坏结构化并发，例如随意使用 `GlobalScope`。

**关联知识点：** [Android 协程 - 结构化并发和取消](../知识点梳理/Android协程.md#结构化并发和取消)

<a id="协程取消为什么是协作式的"></a>
###### 协程取消为什么是协作式的

**相关问法：**

- 协程取消为什么说是协作式的？

答案：

**简答：** 协程取消不会强制杀死正在执行的代码，而是通过取消状态让协程在挂起点或主动检查时退出。

**展开回答：** 大多数挂起函数会检查取消状态，所以网络请求、delay、withContext 等通常能响应取消。但如果协程里是长时间 CPU 循环，就需要使用 `isActive`、`ensureActive()` 或 `yield()` 主动响应取消。

**易错点：** 捕获 `Exception` 后不重新抛出 `CancellationException`，可能导致协程无法正确取消。

**关联知识点：** [Android 协程 - 结构化并发和取消](../知识点梳理/Android协程.md#结构化并发和取消)

<a id="launch-和-async-的异常传播有什么区别"></a>
###### launch 和 async 的异常传播有什么区别

**相关问法：**

- `launch` 和 `async` 的异常有什么区别？

答案：

**简答：** 普通父 Job 下，launch 和 async 的非取消异常都会使父级失败，并影响兄弟任务；async 还会将异常保存在 Deferred 中，在 await 时重新抛出。

**展开回答：** 不能把 async 理解成“不 await 就不传播异常”。根 async 或 supervisorScope 下的直接 async 子任务才不会因自身失败取消普通父级；此时尤其需要 await 观察失败。多个请求要求一起成功时，可在 try/catch 内用 coroutineScope 组织 async 和 await；需要失败隔离时用 supervisorScope 并分别处理结果。

**易错点：** 以为 `CoroutineExceptionHandler` 能捕获所有 `async` 异常，这是不准确的；`async` 异常通常要通过 `await()` 处理。

**关联知识点：** [Android 协程 - 异常处理](../知识点梳理/Android协程.md#异常处理)

<a id="job-supervisorjob-coroutineexceptionhandler-怎么配合"></a>
###### Job SupervisorJob CoroutineExceptionHandler 怎么配合

**相关问法：**

- `Job` 和 `SupervisorJob` 的异常传播有什么区别？

答案：

**简答：** `Job` 负责父子生命周期和取消传播，`SupervisorJob` 改变子任务失败对兄弟任务的影响，`CoroutineExceptionHandler` 只兜底未捕获异常，三者解决的问题不同。

**展开回答：** 普通 `Job` 下，一个子协程未捕获异常通常会取消父协程并影响兄弟任务；`SupervisorJob` 或 `supervisorScope` 下，一个子任务失败不会自动取消其它子任务，适合多个独立区域加载。但监督不代表异常消失，失败子任务仍然要 `try/catch`、`await()` 处理或让 root handler 记录。`CoroutineExceptionHandler` 更像最后兜底日志入口，不能替代业务错误态建模。

**易错点：** 以为加了 `SupervisorJob` 就不用处理异常是错的；它只是隔离失败传播，不负责把错误转成 UI 状态。

**关联知识点：** [协程核心对象和底层实现 - Job 取消和异常传播](../知识点梳理/协程核心对象和底层实现.md#job-取消和异常传播)

<a id="为什么捕获异常时要注意-cancellationexception"></a>
###### 为什么捕获异常时要注意 CancellationException

**相关问法：**

- 为什么捕获异常时要注意 `CancellationException`？
- 为什么不能吞掉 `CancellationException`？

答案：

**简答：** `CancellationException` 是协程取消的正常信号，通常应该继续抛出，不应该当成普通业务错误吞掉。

**展开回答：** 很多代码会写 `catch (e: Exception)` 统一处理错误，但 `CancellationException` 也是异常的一种。如果把它吞掉，父子协程取消流程可能被破坏，任务可能继续执行清理之外的逻辑。

**易错点：** 正确写法通常是先 `catch (e: CancellationException) { throw e }`，再捕获普通 `Exception`。

**关联知识点：** [Android 协程 - 异常处理](../知识点梳理/Android协程.md#异常处理)

<a id="stateflow-和-sharedflow-有什么区别"></a>
###### StateFlow 和 SharedFlow 有什么区别

**相关问法：**

- `StateFlow` 和 `SharedFlow` 分别适合什么场景？

答案：

**简答：** `StateFlow` 表示状态，有当前值，新订阅者会立即收到最新值；`SharedFlow` 更适合事件，默认没有当前值，可配置 replay 和缓冲策略。

**展开回答：** 页面 loading、content、error、empty 这类状态适合用 `StateFlow`；Toast、导航、Snackbar 这类一次性事件更适合用 `SharedFlow`。把事件放进 `StateFlow` 容易在页面重建后重复消费。

**易错点：** SharedFlow 也不保证事件可靠送达：默认 replay=0 时，没有订阅者会丢事件；replay>0 又可能重放。必须明确事件允许丢失、重放还是需要消费确认。

**关联知识点：** [Android 协程 - StateFlow 和 SharedFlow 使用](../知识点梳理/Android协程.md#stateflow-和-sharedflow-使用)

<a id="sharedflow-缓存参数"></a>
###### SharedFlow 的 replay 和 extraBufferCapacity 有什么区别

**相关问法：**

- `replay` 和 `extraBufferCapacity` 有什么区别？没有订阅者时还会缓存吗？

**简答版：** replay 决定新订阅者收到多少条最近的历史事件；extraBufferCapacity 是为已有慢订阅者增加的额外缓冲。有订阅者时容量合计为两者之和，无订阅者时只保留 replay 部分。

**深入追问：** `replay = 0, extraBufferCapacity = 4` 在无订阅者时仍会丢事件，并不会等页面恢复后再发送；`replay = 4` 则会向每个新订阅者重放最近最多 4 条，消费过也不自动清除历史。因此缓冲不是消费一次就删除的可靠消息队列，Toast / 导航要权衡丢失和重放，需要可靠消费时建模为待处理状态并确认消费。

**关联知识点：** [SharedFlow 缓冲参数](../知识点梳理/Android协程.md#sharedflow-缓冲参数)

<a id="sharedflow-溢出与发送"></a>
###### SharedFlow 缓冲满了怎么办 emit 和 tryEmit 有什么区别

**相关问法：**

- `onBufferOverflow` 有哪些策略？`emit` 挂起和 `tryEmit` 返回值分别意味着什么？

**简答版：** 缓冲满且有慢订阅者时，默认 SUSPEND 让 emit 挂起等待空间，tryEmit 则立即返回 false；DROP_OLDEST 丢最旧事件，DROP_LATEST 丢本次事件，这两种策略不会因缓冲满而挂起，tryEmit 可返回 true，但不保证事件送达。

**深入追问：** 挂起只暂停当前协程，不阻塞线程，等的是缓冲空间，不是订阅者业务全部完成。丢弃策略要求 replay 或 extraBufferCapacity 至少一个大于 0。无订阅者时只保留 replay 历史，不触发上述溢出等待；replay 为 0 时 tryEmit 返回 true 也会丢事件。默认两个容量都为 0 时，有订阅者则 emit 等所有订阅者接收，tryEmit 返回 false，不能把“已接收”当成“业务处理成功”。

**关联知识点：** [SharedFlow 缓冲参数](../知识点梳理/Android协程.md#sharedflow-缓冲参数)

<a id="android-协程常见使用方式是什么"></a>
###### Android 协程常见使用方式是什么

**相关问法：**

- Android 中协程从 ViewModel 到 Repository 一般怎么分层使用？
- Android 项目里协程应该放在哪一层使用？

答案：

**简答：** ViewModel 用 `viewModelScope` 发起任务并更新 `StateFlow`，Repository 暴露 suspend / Flow，并只在阻塞 IO 等确有需要的边界切换 Dispatcher，Fragment 用 `repeatOnLifecycle` 收集状态并渲染 UI。

**展开回答：** 常见分层是：UI 层只收集状态和触发事件；ViewModel 编排业务和维护状态；Repository 负责网络、数据库和缓存。这样可以减少 UI 层复杂度，也方便测试和复用。

**易错点：** 不要把网络请求、数据库写入和复杂业务都塞进 Fragment。

**关联知识点：** [Android 协程 - Android 常用使用方式](../知识点梳理/Android协程.md#android-常用使用方式)

<a id="协程相比-thread-handler-executor-有什么优势"></a>
###### 协程相比 Thread Handler Executor 有什么优势

**相关问法：**

- Android 为什么推荐用协程处理异步任务？
- 协程比直接 new Thread 好在哪里？

答案：

**简答：** 协程能用顺序代码表达异步流程，并提供结构化并发、取消、异常传播、调度器切换和生命周期绑定；`Thread`、`Handler`、`Executor` 更底层，需要手动处理更多细节。

**展开回答：** `Thread` 直接对应系统线程，创建和管理成本高；`Handler` 适合消息队列和线程投递，但业务延迟任务需要手动移除；`Executor` 管线程池，但不直接管理父子任务、页面生命周期和挂起恢复。协程在 Android 中能结合 `viewModelScope`、`lifecycleScope`、`withContext`、`repeatOnLifecycle` 建立更完整的异步流程。如果和线程池对比，单次调度成本不一定差很多，协程优势主要在挂起恢复、自动回到原上下文、取消和异常传播。

**易错点：** 协程不是完全替代传统工具。底层消息分发、精细线程池控制、老项目兼容场景仍可能保留 `Handler` 或 `Executor`。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md)

<a id="协程和-rxjava-livedata-怎么取舍"></a>
###### 协程和 RxJava LiveData 怎么取舍

**相关问法：**

- 协程和 RxJava 怎么取舍？

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

**相关问法：**

- Android 协程使用中有哪些常见坑？

答案：

**简答：** 常见坑包括主线程阻塞、错误作用域、Flow 收集不绑定生命周期、异常未处理、吞掉取消异常、事件状态混用和滥用 `GlobalScope`。

**展开回答：** Android 协程问题大多不是语法问题，而是生命周期、线程和状态管理问题。排查时要看任务属于谁、什么时候取消、在哪个线程运行、异常在哪里处理、UI 是否可能重复消费事件。

**易错点：** 看到用了协程不代表异步和生命周期就自动正确，还要看作用域、调度器和收集方式。

**关联知识点：** [Android 协程 - 常见坑](../知识点梳理/Android协程.md#常见坑)

<a id="dispatchers.main-是哪个依赖提供的"></a>
###### Dispatchers.Main 是哪个依赖提供的

**相关问法：**

- `Dispatchers.Main` 是哪个依赖提供的？

**简答版：** `Dispatchers.Main` 的 API 定义在 kotlinx-coroutines-core；Android 上的主线程调度器实现由 kotlinx-coroutines-android 提供，项目可直接或通过传递依赖引入。

**深入追问：** Android 实现通过主线程 Looper / Handler 调度。普通 JVM 单元测试没有 Android 主线程实现，应使用 kotlinx-coroutines-test 的 `Dispatchers.setMain(testDispatcher)`，测试后 `resetMain()`；不要把缺少 Main 实现误判成协程语法问题。

**关联知识点：** [Android协程](../知识点梳理/Android协程.md#android-常用依赖)

<a id="launch-和-async-底层创建的对象有什么区别"></a>
###### launch 和 async 底层创建的对象有什么区别

**相关问法：**

- `launch` 底层创建的协程对象和 `async` 有什么区别？

**简答版：** 两者都创建有 Job 生命周期的协程对象；`launch` 返回 Job，`async` 返回同时承载结果的 Deferred。

**深入追问：** 常见内部实现分别是 `StandaloneCoroutine` 和 `DeferredCoroutine`，惰性启动有对应变体，具体类名属于版本相关实现细节。Deferred 还负责保存成功结果或异常并支持 `await()`；普通父 Job 下，async 失败仍会向父级传播，不能理解为只在 await 时才发生失败。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#核心对象关系)

<a id="continuation-在挂起恢复中起什么作用"></a>
###### Continuation 在挂起恢复中起什么作用

**相关问法：**

- `Continuation` 在协程挂起恢复里起什么作用？
- `Continuation` 是什么？

**简答版：** Continuation 表示计算的后续执行，提供上下文和 `resumeWith(Result<T>)` 恢复入口；编译器生成的续体可保存状态机位置及跨挂起点需要的局部变量。

**深入追问：** 挂起函数通常被编译成接收 Continuation 的形式；真正挂起时返回挂起标记，结果就绪后恢复状态机。并不是每次调用 suspend 都会挂起；线程调度由上下文中的拦截器 / Dispatcher 配合完成。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#挂起函数和状态机)

<a id="为什么不建议在-viewmodelscope.launch-中传入新的-job"></a>
###### 为什么不建议在 viewModelScope.launch 中传入新的 Job

**相关问法：**

- 为什么不建议在 `viewModelScope.launch(Job())` 里随便传新的 `Job`？

**简答版：** 传入的 Job 会覆盖 scope 上下文中的 Job，使新协程以这个 Job 为父级，脱离原 ViewModel 的取消链。

**深入追问：** `launch(Job())` 返回的协程 Job 仍是新建的，但父级已经换掉，ViewModel 清理未必能取消它。需要兄弟失败隔离时用适当的 supervisorScope，或由明确 owner 管理外部 scope；不要靠随意替换 Job 实现。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#coroutinecontext-配置项)

<a id="coroutineexceptionhandler-能捕获所有异常吗"></a>
###### CoroutineExceptionHandler 能捕获所有异常吗

**相关问法：**

- `CoroutineExceptionHandler` 为什么不能替代业务异常处理？
- `CoroutineExceptionHandler` 能捕获所有异常吗？

**简答版：** 不能。它处理传播到可处理边界的未捕获异常，不能恢复已经失败的协程，也不能替代调用处的业务 try/catch。

**深入追问：** 普通子协程通常向父级委托异常；根 launch 或监督下的直接 launch 子协程可使用 handler。async 把异常保存在 Deferred，需 await 观察；普通父级仍可能被其失败取消。CancellationException 通常不交给 handler。接口错误应在业务边界转成状态，日志兜底与业务处理分开。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#job-取消和异常传播)

<a id="repository-能不能创建自己的-coroutinescope"></a>
###### Repository 能不能创建自己的 CoroutineScope

**相关问法：**

- Repository 里能不能直接创建 CoroutineScope？
- Repository 里能不能创建自己的 `CoroutineScope`？

**简答版：** 可以，但必须有明确任务所有者、生命周期和取消策略；默认更推荐暴露 suspend / Flow，让调用方管理任务。

**深入追问：** 如果某次保存必须跨越当前页面生命周期，可注入应用或业务组件持有的外部 scope，按需求等待完成。避免每个方法临时创建 scope 或使用 GlobalScope。进程结束后仍需保证执行的持久任务，应考虑 WorkManager，应用 scope 本身不保证存活。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#作用域选择)

<a id="coroutinestart.lazy-什么时候启动"></a>
###### CoroutineStart.LAZY 什么时候启动

**相关问法：**

- `CoroutineStart.LAZY` 什么时候启动？

**简答版：** LAZY 创建后不立即执行；调用 `start()`、`join()`，或对 Deferred 调用 `await()` 时会触发启动。

**深入追问：** 仅把 Job 保存下来不会启动它；多个 lazy async 若逐个 await，可能变成串行，应先全部 start 再等待。惰性子协程仍属于父级，既不启动也不取消会使等待全部子任务的父级无法完成。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#启动方法参数)

<a id="coroutinescope-和-supervisorscope-有什么区别"></a>
###### coroutineScope 和 supervisorScope 有什么区别

**相关问法：**

- `coroutineScope` 和 `supervisorScope` 有什么区别？

**简答版：** 两者都会等待代码块和子协程结束；coroutineScope 中子协程失败通常取消整个作用域，supervisorScope 隔离直接子协程之间的失败。

**深入追问：** supervisorScope 不会吞掉异常。直接 launch 子协程要自行处理异常或配置适当 handler，async 要处理 await 结果；若 scope 代码块自身抛异常，包括未捕获的 await 失败，整个 scope 及其子任务仍会取消。父级取消对两者都会向下传播。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#启动方法参数)

<a id="delay-和-thread.sleep-有什么区别"></a>
###### delay 和 Thread.sleep 有什么区别

**相关问法：**

- `delay()` 和 `Thread.sleep()` 有什么区别？

**简答版：** delay 挂起协程而不占住执行线程，且可响应取消；Thread.sleep 阻塞当前线程。

**深入追问：** 主线程 sleep 会卡 UI。把 sleep 放到 IO 虽然不阻塞主线程，仍会占用工作线程；普通 Job.cancel 不保证中断这类阻塞调用，支持中断的阻塞 API 可按场景用 runInterruptible 包装。suspend 关键字本身不会把阻塞 API 变为非阻塞。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#挂起函数和状态机)

<a id="dispatchers.main.immediate-和-main-有什么区别"></a>
###### Dispatchers.Main.immediate 和 Main 有什么区别

**相关问法：**

- `Dispatchers.Main.immediate` 和 `Dispatchers.Main` 有什么区别？

**简答版：** Main 通常把执行投递到主线程队列；Main.immediate 在已经位于正确主线程时可直接执行，避免一次额外投递。

**深入追问：** 从后台调用 immediate 仍需调度到主线程。直接执行可能改变与队列任务的先后顺序，并带来重入问题；它不意味着同步执行完所有挂起逻辑，也不允许在主线程做耗时工作。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#调度器与线程切换)

<a id="withcontext-dispatchers.io-底层大概做了什么"></a>
###### withContext Dispatchers.IO 底层大概做了什么

**相关问法：**

- `withContext(Dispatchers.IO)` 底层大概做了什么？

**简答版：** 它合并当前上下文与传入上下文，执行代码块并等待结果；调度器变化时通常把代码块调度到目标上下文，完成后恢复调用方上下文。

**深入追问：** 它仍受结构化并发和取消约束，不是独立后台任务。Default 和 IO 可能共享工作线程，因此不保证每次都发生物理线程切换。调度器改变后的返回路径具有及时取消保证，调用方已取消时可能收到 CancellationException 而不是结果。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#调度器与线程切换)

<a id="flowon-改的是上游还是下游线程"></a>
###### flowOn 改的是上游还是下游线程

**相关问法：**

- `flowOn` 改的是上游还是下游线程？

**简答版：** flowOn 改变它之前、尚未被其他上下文限定的上游算子的执行上下文，不改变下游 collect 的上下文。

**深入追问：** 例如 `flow { emit(load()) }.flowOn(io).collect { render(it) }` 中 load 在指定上游上下文执行，render 仍在收集协程上下文中。切换调度器时可能通过独立协程和 Channel 传值；取消时在途值不保证送达。不要在普通 flow 内用 withContext 跨上下文 emit。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#调度器与线程切换)

<a id="android-项目中协程配置通常怎么抽象"></a>
###### Android 项目中协程配置通常怎么抽象

**相关问法：**

- Android 项目中协程配置通常怎么抽象？

**简答版：** 把 IO、Default、Main 等 Dispatcher 封装成可注入配置；外部 scope 由明确组件持有，同时约定 Job、命名、错误处理和取消入口。

**深入追问：** ViewModel 负责状态与业务编排，Repository 保证数据操作可安全从主线程调用。CoroutineName 用于诊断；CoroutineExceptionHandler 只做未捕获异常兜底。不要为了统一封装而隐藏任务归属，或把日志函数混成业务错误处理器。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#android-配置模板和排查)

<a id="排查协程泄漏异常丢失和线程用错时看哪些点"></a>
###### 排查协程泄漏异常丢失和线程用错时看哪些点

**相关问法：**

- 排查协程泄漏、异常丢失、线程用错时看哪些点？

**简答版：** 先查 scope 的 owner 与 Job 父子关系，再查取消是否传播、异常是否被吞、Dispatcher 是否匹配工作类型，以及 Flow 收集是否绑定 View 生命周期。

**深入追问：** 泄漏看外部 scope 是否持有页面、是否重复启动；异常看 async 是否 await、宽泛 catch / runCatching 是否吞掉取消；卡顿看主线程阻塞和不可取消循环。结合任务命名、堆栈与 profiler 验证，不能只凭使用了 IO 就认定没有线程问题。

**关联知识点：** [协程核心对象和底层实现](../知识点梳理/协程核心对象和底层实现.md#android-配置模板和排查)

<a id="为什么建议注入-dispatcher"></a>
###### 为什么建议注入 Dispatcher

**相关问法：**

- 为什么建议注入 Dispatcher，而不是到处写 Dispatchers.IO？
- 为什么 Dispatcher 注入有利于测试？

**简答版：** 把执行策略从业务逻辑中分离，测试时能替换为使用统一 TestCoroutineScheduler 的测试调度器，控制任务推进和虚拟时间。

**深入追问：** 硬编码 IO 会让任务跑到真实线程池，runTest 的虚拟时间不能统一控制它。注入不等于只能有一个 Dispatcher；可分别提供 IO / Default。viewModelScope 默认使用 Main，纯 JVM 测试还需正确替换并恢复 Main。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#dispatcher-注入)

<a id="repository-什么时候用-suspend-什么时候用-flow"></a>
###### Repository 什么时候用 suspend 什么时候用 Flow

**相关问法：**

- Repository 方法什么时候返回 suspend，什么时候返回 Flow？

**简答版：** 一次调用得到一次结果用 suspend 函数；持续观察、多次更新的数据用 Flow 返回值。suspend 是函数修饰符，不是返回类型。

**深入追问：** 比如一次详情请求用 `suspend fun load(): Detail`，数据库观察用 `fun observe(): Flow<Detail>`。Flow 默认不等于后台执行，要明确上游调度；通常不需要把返回 Flow 的函数也声明为 suspend，除非创建流之前确实有挂起工作。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#repository-暴露-suspend-还是-flow)

<a id="为什么-viewmodel-常用-stateflow-表示-ui-状态"></a>
###### 为什么 ViewModel 常用 StateFlow 表示 UI 状态

**相关问法：**

- 为什么 ViewModel 常用 StateFlow 表示 UI 状态？

**简答版：** 它总有初始值和当前值，新订阅者可获得最新状态，适合表示 loading、内容、空态和错误等可持续渲染的数据。

**深入追问：** 对外暴露只读 StateFlow，内部用 MutableStateFlow 更新不可变状态。StateFlow 按 equals 合并相同值，慢收集者可能跳过中间变化，因此不适合要求每次都消费的事件序列；界面仍需绑定生命周期收集。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#ui-状态建模)

<a id="toast-和导航事件为什么不建议直接放进-stateflow"></a>
###### Toast 和导航事件为什么不建议直接放进 StateFlow

**相关问法：**

- Toast 和导航事件为什么不建议直接放进 StateFlow？

**简答版：** StateFlow 会向新收集者提供当前值，重建或重新订阅后可能再次触发旧事件；相同值又可能被合并，导致重复事件不触发。

**深入追问：** SharedFlow 可表达广播事件，但默认 replay=0 时无订阅者会丢事件，extraBufferCapacity 不会替无订阅者保存历史；replay>0 又可能重放。需要可靠消费的导航或支付结果应按业务建模为待处理状态并确认消费，不能宣称 SharedFlow 保证恰好一次。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#事件处理)

<a id="协程异常应该在哪一层转成-ui-错误态"></a>
###### 协程异常应该在哪一层转成 UI 错误态

**相关问法：**

- 协程异常应该在哪一层转成 UI 错误态？

**简答版：** 数据层可保留技术异常或映射为领域错误，ViewModel / 表现层再把预期失败映射为 UI 状态，UI 负责渲染。

**深入追问：** 在能够处理失败的挂起调用边界 try/catch，先重新抛出 CancellationException，再处理预期错误。异步 launch 内部异常不能靠包住 launch 调用的外层 try/catch 接住。CoroutineExceptionHandler 不能代替请求级的错误态和重试决策。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#错误处理)

<a id="协程代码怎么设计才方便单元测试"></a>
###### 协程代码怎么设计才方便单元测试

**相关问法：**

- 协程代码怎么设计才方便单元测试？

**简答版：** 注入 Dispatcher、数据依赖和必要的外部 scope，用 runTest 与统一调度器控制时间，断言状态、结果、取消和失败传播。

**深入追问：** 用 StandardTestDispatcher 时通过 runCurrent / advanceTimeBy 等推进执行；测试 Main 使用 setMain / resetMain。长期 Flow 收集可放 backgroundScope 并在结束时取消，避免无限 collect 卡住测试。不要依赖 Thread.sleep 或真实网络测试调度正确性。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#测试规范)

<a id="code-review-android-协程代码时重点看什么"></a>
###### Code Review Android 协程代码时重点看什么

**相关问法：**

- Code Review Android 协程代码时重点看什么？

**简答版：** 检查任务归属、父子关系、生命周期、主线程安全、取消传播、异常边界、Flow 状态与事件语义，以及测试可控性。

**深入追问：** 重点追问 GlobalScope 或独立 Job 是否合理，Fragment 是否绑定 viewLifecycleOwner，循环是否检查取消，runCatching 是否吞取消，async 是否观察结果，SharedFlow 无订阅时会怎样，以及一次性事件是否可能重复或丢失。

**关联知识点：** [Android协程工程规范](../知识点梳理/Android协程工程规范.md#code-review-清单)

<a id="协程相比回调写法解决了什么问题"></a>
###### 协程相比回调写法解决了什么问题

**相关问法：**

- 协程相比回调写法解决了什么问题？

**简答版：** 它把依赖顺序明确的异步操作写成顺序代码，让结果组合、异常处理和取消更集中，减少回调嵌套和手工状态管理。

**深入追问：** 协程不自动消除底层回调；封装单次回调可用 suspendCancellableCoroutine，并在取消时注销回调或取消请求，避免重复恢复。连续回调流可考虑 callbackFlow，关闭时清理注册。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和回调对比)

<a id="有了协程以后-handler-还有必要吗"></a>
###### 有了协程以后 Handler 还有必要吗

**相关问法：**

- 有了协程以后 Handler 还有必要吗？

**简答版：** 有。Handler / Looper 是 Android 消息队列和线程投递机制，协程提供更高层的任务组织，二者不在同一抽象层。

**深入追问：** Android 主线程 Dispatcher 本身就依赖 Handler / Looper。应用业务延时和生命周期任务常可改用协程，但系统消息分发、既有 HandlerThread 接口和精细队列行为仍可能使用 Handler。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和-handler-对比)

<a id="dispatcher-和-executor-是什么关系"></a>
###### Dispatcher 和 Executor 是什么关系

**相关问法：**

- Dispatcher 和 Executor 是什么关系？

**简答版：** Executor 执行或排队 Runnable，Dispatcher 决定协程代码和续体在哪里执行；Executor 可通过 asCoroutineDispatcher 适配给协程使用。

**深入追问：** 两者都涉及调度，但 Executor 本身不提供协程的挂起恢复和父子取消关系。自建 ExecutorCoroutineDispatcher 需要明确关闭责任，不能关闭共享线程池。复用同一个线程池时，协程也不保证每次调度都比直接提交任务便宜。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和-executor-对比)

<a id="为什么不建议继续用-asynctask"></a>
###### 为什么不建议继续用 AsyncTask

**相关问法：**

- 为什么不建议继续用 AsyncTask？

**简答版：** AsyncTask 已在 Android API 30 废弃，生命周期管理、执行策略和组合复杂任务都比较受限，容易持有旧页面或在销毁后回调。

**深入追问：** 普通页面异步任务可用 ViewModel 加协程，Java 项目可用 Executor；需要持久化调度的后台任务考虑 WorkManager。替换时必须保留取消、错误处理和任务时序，不能只机械替换 API。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和-asynctask-对比)

<a id="livedata-和-stateflow-怎么选择"></a>
###### LiveData 和 StateFlow 怎么选择

**相关问法：**

- LiveData 和 StateFlow 怎么选择？

**简答版：** LiveData 自带基于 LifecycleOwner 的观察机制，适合既有 XML / Java 界面；StateFlow 与协程、Flow 操作符和 Compose 集成自然，适合 Kotlin 状态流。

**深入追问：** StateFlow 必须有初始值，普通 collect 不自动感知界面生命周期，View 中配合 repeatOnLifecycle，Compose 中可用 collectAsStateWithLifecycle。LiveData 和 StateFlow 都是状态传播工具，不等同于异步执行引擎，也无需仅为技术统一全量迁移。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#和-livedata-对比)

<a id="什么时候用协程什么时候保留传统异步方案"></a>
###### 什么时候用协程什么时候保留传统异步方案

**相关问法：**

- 项目里什么时候用协程，什么时候保留传统异步方案？

**简答版：** 新的 Kotlin 页面任务和数据流通常适合协程 / Flow；稳定的 RxJava 链、Java 接口、底层消息队列或精细线程池控制可按成本保留。

**深入追问：** 决策看生命周期、错误处理、取消能力、团队维护成本和兼容要求。可在边界适配后渐进迁移，避免一条业务链里混杂多个无主任务系统；可靠后台调度仍需 WorkManager 等机制。

**关联知识点：** [协程和传统方案对比](../知识点梳理/协程和传统方案对比.md#选择建议)
