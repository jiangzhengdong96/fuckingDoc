### Flow 与协程进阶面试题

<!-- page-toc:start -->
**目录**

- [内容概述](#section-内容概述)
- [冷 Flow 为什么可能重复请求，stateIn 和 shareIn 怎么选？](#advanced-q1)
- [WhileSubscribed 的两个超时参数分别控制什么？](#advanced-q2)
- [collectLatest、conflate 和 buffer 有什么区别？](#advanced-q3)
- [搜索使用 debounce 和 flatMapLatest 能保证旧结果绝不出现吗？](#advanced-q4)
- [Flow 的 catch 和 retryWhen 能处理哪些异常？](#advanced-q5)
- [callbackFlow 为什么需要 awaitClose？](#advanced-q6)
- [cancel、join、cancelAndJoin 和 await 有什么区别？](#advanced-q7)
- [为什么切到 IO 仍可能无法及时取消阻塞任务？](#advanced-q8)
- [withTimeoutOrNull 会把所有失败和取消都变成 null 吗？](#advanced-q9)
- [取消后 finally 能执行吗，什么时候需要 NonCancellable？](#advanced-q10)
- [请求取消或超时后，为什么仍可能产生业务副作用？](#advanced-q11)
- [StateFlow 为什么重复赋相同值不通知，慢收集者会漏掉中间值吗？](#advanced-q12)
- [为什么原地修改状态里的 MutableList 可能不刷新 UI？](#advanced-q13)
- [value 线程安全，为什么还需要 update，update 中能放副作用吗？](#advanced-q14)
- [为什么测试 WhileSubscribed 的 StateFlow 时只读 value 不够？](#advanced-q15)
- [有 StateFlow 为什么还需要 SharedFlow，页面能否只用 StateFlow？](#stateflow与sharedflow选择)
- [用 StateFlow 保存待处理消息列表，是否就能保证恰好消费一次？](#待处理消息消费确认)
- [为什么同一主线程上的协程仍可能发生逻辑竞态？](#advanced-q16)
- [Mutex 和 synchronized 有什么区别，Mutex 可以重入吗？](#advanced-q17)
- [Semaphore 和 limitedParallelism 都能限制上传并发数吗？](#advanced-q18)
- [Channel 与 SharedFlow 的多消费者语义有什么区别？](#advanced-q19)
- [Channel 发送成功是否保证事件被业务消费一次？](#advanced-q20)
- [flow 创建时会执行吗，两个 collect 是重放还是重新执行？](#flow执行与重复收集)
- [StateFlow 在没有订阅者时更新，新订阅者为什么还能收到？](#stateflow晚订阅)
- [慢订阅者、背压、缓冲、合并和去重有什么区别？](#背压缓冲与合并)
- [返回 Flow 是否就代表自动监听数据变化，flowOf(load()) 会延迟执行吗？](#flow不自动监听)
- [CoroutineScope、launch、withContext、runBlocking 分别是什么，能混称为作用域吗？](#scope-api-types)
- [async 什么时候开始执行，await 是启动任务还是等待结果？](#async-start-await)
- [withContext 和 runBlocking 都等待结果，区别在哪里？](#context-versus-blocking)
- [为什么 GlobalScope 内部加 delay，外层演示入口仍可能提前结束？](#global-demo-wait)
- [coroutineScope 和 supervisorScope 如何等待子任务并处理失败？](#local-scope-failure)
- [Job 和 SupervisorJob 有什么区别，监督会自动处理异常吗？](#job-supervisor-intro)
- [SupervisorJob 会隔离所有后代的失败吗，和 supervisorScope 怎么选？](#supervisor-depth)
- [CoroutineContext 的加号是什么意思，Job 和 Dispatcher 分别负责什么？](#context-job-dispatcher)
- [suspend 函数一定挂起吗，为什么不等于开线程？](#suspend-immediate)
- [一个函数有两个挂起点，恢复位置和局部变量如何保存？](#suspend-saved-locals)
- [挂起函数立即返回与返回 COROUTINE_SUSPENDED 有什么区别？](#suspend-marker)
- [循环里的挂起点会为每次循环创建一个独立状态吗？](#suspend-loop)
- [continuation.resume 后一定在回调线程继续执行吗？](#suspend-resume-thread)
- [挂起后恢复的异常如何进入原来的 catch 和 finally？](#suspend-failure-state)
- [COROUTINE_SUSPENDED 是谁返回的，怎样逐层让调用栈退出？](#source-suspended-return)
- [label 与 CancellableContinuation 的决策状态有什么区别？](#source-two-states)
- [invokeSuspend 为什么带着 0 参数重新调用函数却不会从头执行？](#source-label-high-bit)
- [第一次恢复又挂起、第二次恢复返回结果，BaseContinuationImpl 分别怎么处理？](#source-base-loop)
<!-- page-toc:end -->


<a id="section-内容概述"></a>
###### 内容概述

补充 Flow 共享与操作符、取消超时、StateFlow 状态更新和并发控制。基础题见 [Android 协程面试题](./Android协程面试题.md)。

<a id="advanced-q1"></a>
###### 冷 Flow 为什么可能重复请求，stateIn 和 shareIn 怎么选？

**简答版：** 典型冷流每次 collect 都独立执行上游，可能重复请求。stateIn 共享为有当前值的 StateFlow，shareIn 共享为可配置 replay 的 SharedFlow。

**深入追问：** Flow 接口不代表一定是冷流；共享对象应稳定持有，scope 决定上游生命周期。stateIn 适合 UI 状态，shareIn 更适合共享广播；共享不等于网络缓存。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#冷流与热流)

<a id="advanced-q2"></a>
###### WhileSubscribed 的两个超时参数分别控制什么？

**简答版：** stopTimeoutMillis 控制最后一个订阅者离开后多久停止上游；replayExpirationMillis 从上游停止后开始计时，决定多久重置缓存。

**深入追问：** 默认分别为 0 和 Long.MAX_VALUE；重置时 stateIn 回到 initialValue，shareIn 清空 replay。短暂重订阅可避免停启；scope 取消后重订阅不能复活共享协程。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#共享上游与启动策略)

<a id="advanced-q3"></a>
###### collectLatest、conflate 和 buffer 有什么区别？

**简答版：** collectLatest 取消旧的消费处理块；conflate 保留较新的待处理值但不取消当前处理；buffer 用有限队列解耦上下游，默认满时挂起。

**深入追问：** 消费最新 UI 状态和可靠处理每个事件的要求不同。取消无法撤销已发生的副作用；StateFlow 已有相等合并和跳过中间状态的语义，不应再把它当完整事件队列。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#操作符选择)

<a id="advanced-q4"></a>
###### 搜索使用 debounce 和 flatMapLatest 能保证旧结果绝不出现吗？

**简答版：** 不能无条件保证。flatMapLatest 取消旧内层流，但 debounce 放在它之前时，旧请求要等新输入通过防抖窗口后才会被取消。

**深入追问：** 原始输入一变就取消可先 flatMapLatest，再在内层 delay；已交付的结果和旧 SDK 的独立回调不会自动撤销。严格防旧结果覆盖还需查询标识和提交时校验，且异常应在内层处理以保留输入监听。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#操作符选择)

<a id="advanced-q5"></a>
###### Flow 的 catch 和 retryWhen 能处理哪些异常？

**简答版：** catch 只捕获前方上游异常，retryWhen 也只决定是否重收集上游；二者不把下游 collect 失败或用于取消的异常当作可恢复上游失败。

**深入追问：** attempt 从 0 开始，attempt < 3 意味着最多重试 3 次，加初次共 4 次。重试会重复副作用，要限制异常类型并考虑退避、幂等。stateIn / shareIn 前应完成必要的错误处理，否则共享协程可能终止而状态停在最后值。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#异常与重试)

<a id="advanced-q6"></a>
###### callbackFlow 为什么需要 awaitClose？

**简答版：** callbackFlow 常把持续回调转成冷流，awaitClose 在收集取消或通道关闭时注销监听，避免留下回调和资源。

**深入追问：** 每个冷流订阅者会各自注册；需要共享时再 shareIn / stateIn。取消可能与注册和回调竞争，要遵守 SDK 线程约束；trySend 失败必须按业务处理，不能当成事件已送达。

**关联知识点：** [Flow冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#回调与生命周期)

<a id="advanced-q7"></a>
###### cancel、join、cancelAndJoin 和 await 有什么区别？

**简答版：** cancel 发取消信号但不等完成；join 等结束但不返回业务结果；cancelAndJoin 先取消再等结束；await 返回 Deferred 结果或抛其失败。

**深入追问：** join 自身可被调用者取消；普通父子关系下目标失败也可能取消当前调用者，不能因此说 join 总不抛异常。只有 cancelAndJoin 正常返回才能确认清理完成，目标不响应取消时仍可能一直等。

**关联知识点：** [协程取消与超时](../知识点梳理/协程取消与超时.md#取消与等待结束)

<a id="advanced-q8"></a>
###### 为什么切到 IO 仍可能无法及时取消阻塞任务？

**简答版：** IO 只指定执行位置，Job.cancel 不保证中断底层阻塞 API。任务必须在挂起点或显式检查时响应取消。

**深入追问：** CPU 循环可 ensureActive / yield；支持线程中断的阻塞调用可用 runInterruptible，其他 SDK 需要其 cancel / close API。suspend 不等于可取消，超时也不能强行杀死不合作的线程代码。

**关联知识点：** [协程取消与超时](../知识点梳理/协程取消与超时.md#协作式取消与阻塞)

<a id="advanced-q9"></a>
###### withTimeoutOrNull 会把所有失败和取消都变成 null 吗？

**简答版：** 不会，withTimeoutOrNull 只把自己这一层的超时转换为 null；业务异常、外部取消以及不属于自身的超时继续传播。

**深入追问：** 返回值本身可空时要区分合法 null 与超时，可显式建模结果。withTimeout 抛 TimeoutCancellationException，它属于取消异常；超时限制依赖协作取消，不代表服务器已撤销操作。

**关联知识点：** [协程取消与超时](../知识点梳理/协程取消与超时.md#超时参数与边界)

<a id="advanced-q10"></a>
###### 取消后 finally 能执行吗，什么时候需要 NonCancellable？

**简答版：** 取消时 finally 会执行，但其中可取消挂起调用可能立即失败。必须挂起完成的短清理可放 withContext(NonCancellable)。

**深入追问：** 普通 close 通常不需要 NonCancellable；清理应有明确边界，避免拖住父级结束。不要用 launch(NonCancellable) 逃离任务树；超时与资源交付竞争时，优先在同一作用域内获取、使用和关闭资源。

**关联知识点：** [协程取消与超时](../知识点梳理/协程取消与超时.md#finally与资源释放)

<a id="advanced-q11"></a>
###### 请求取消或超时后，为什么仍可能产生业务副作用？

**简答版：** 取消只停止可协作的后续执行，不会回滚已提交的请求、数据库写入或导航；底层独立回调也可能继续到达。

**深入追问：** 需按业务做幂等、查询最终结果和提交时请求版本校验。不要吞 CancellationException 后继续更新页面；业务要求保存必须完成时，应显式设计所有者与持久化，而不是忽略取消。

**关联知识点：** [协程取消与超时](../知识点梳理/协程取消与超时.md#取消信号与旧结果)

<a id="advanced-q12"></a>
###### StateFlow 为什么重复赋相同值不通知，慢收集者会漏掉中间值吗？

**简答版：** StateFlow 按 equals 合并相等更新；慢收集者可以跳过中间变化，只观察最新状态。

**深入追问：** 它始终有当前值，并非每次赋值都触发一次渲染。需要逐条处理的事件不能靠 StateFlow 记录；测试最终状态与测试完整过程也应区分。

**关联知识点：** [StateFlow状态更新细节](../知识点梳理/StateFlow状态更新细节.md#当前值与相等合并)

<a id="advanced-q13"></a>
###### 为什么原地修改状态里的 MutableList 可能不刷新 UI？

**简答版：** 原地修改会同时改变旧状态引用，再赋回去可能被 equals 判断为相等；浅 copy 仍复用已变更集合也可能有同样问题。

**深入追问：** 创建新集合和新状态，并避免 Item 内部可变引用泄露。List 是只读接口，不保证底层不可变；大型列表可考虑持久化集合，不能只为刷新 UI 机械复制所有对象。

**关联知识点：** [StateFlow状态更新细节](../知识点梳理/StateFlow状态更新细节.md#可变集合与不可变快照)

<a id="advanced-q14"></a>
###### value 线程安全，为什么还需要 update，update 中能放副作用吗？

**简答版：** 单次 value 读写安全不代表读取旧值、计算、写回整体原子。update 提供原子转换，但其 lambda 可能因竞争重试。

**深入追问：** 因此 lambda 要纯，不应发请求、计费或记录只应发生一次的副作用。多个字段若在同一不可变状态内可一起转换，跨多个对象的事务仍需更完整同步。

**关联知识点：** [StateFlow状态更新细节](../知识点梳理/StateFlow状态更新细节.md#原子更新与副作用)

<a id="advanced-q15"></a>
###### 为什么测试 WhileSubscribed 的 StateFlow 时只读 value 不够？

**简答版：** WhileSubscribed 的共享上游需要订阅者；只读 value 不会启动收集，可能一直看到 initialValue。

**深入追问：** 测试中提前启动收集，并用共享 TestCoroutineScheduler 推进任务；长期收集可放 backgroundScope。即使如此 StateFlow 仍可合并中间状态，不能要求每次赋值都必然被断言到。

**关联知识点：** [StateFlow状态更新细节](../知识点梳理/StateFlow状态更新细节.md#状态收集与测试)

<a id="stateflow与sharedflow选择"></a>
###### 有 StateFlow 为什么还需要 SharedFlow，页面能否只用 StateFlow？

**简答版：** StateFlow 表达当前状态，有初始值、相等合并和跳过中间状态的语义；SharedFlow 广播独立消息，可重复发相等值并配置 replay、缓冲和溢出策略。页面可以只用 StateFlow，但独立消息需要明确建模，不能用不断覆盖单个状态代替事件队列。

**深入追问：** 进度从 10% 跳到 12% 通常合理，两个不同文件完成通知则可能都需要处理。SharedFlow 默认在无订阅者时丢消息，增加 replay 可能重放，因此也不是所有 UI 事件的通用答案。选择前应先明确是否允许丢失、重放，以及是否需要确认。

**关联知识点：** [有 StateFlow 为什么还需要 SharedFlow](../知识点梳理/StateFlow状态更新细节.md#有stateflow为什么还需要sharedflow)

<a id="待处理消息消费确认"></a>
###### 用 StateFlow 保存待处理消息列表，是否就能保证恰好消费一次？

**简答版：** 不能自动保证。列表能保留尚未确认的消息，即使 StateFlow 合并中间更新，未确认消息仍在最新状态中；但消费和确认之间存在失败窗口。

**深入追问：** 先处理再确认可能在确认前销毁而重复，先确认再处理可能因处理失败而丢失。需要明确消费者归属、按 ID 确认、幂等处理以及必要的持久化；仅添加随机 ID 不等于可靠消费。

**关联知识点：** [用状态表达待处理事件](../知识点梳理/StateFlow状态更新细节.md#用状态表达待处理事件)

<a id="advanced-q16"></a>
###### 为什么同一主线程上的协程仍可能发生逻辑竞态？

**简答版：** 协程在挂起点让出执行权，另一协程可能更新共享状态；原协程恢复后按旧快照写回，就会覆盖新状态。

**深入追问：** 单线程中不含挂起点的短代码段与跨挂起流程不同。保护范围要覆盖业务不变量，可用 Mutex、版本检查或状态原子转换；仅把 Dispatcher 改成单线程不够。

**关联知识点：** [协程并发控制与共享状态](../知识点梳理/协程并发控制与共享状态.md#单线程也有逻辑竞态)

<a id="advanced-q17"></a>
###### Mutex 和 synchronized 有什么区别，Mutex 可以重入吗？

**简答版：** Mutex 等待时挂起，适合协程临界区；synchronized 是线程监视器，竞争时会阻塞线程。Mutex 不可重入。

**深入追问：** 同一协程重复获取同一 Mutex 可能挂起等待自身释放；相同非空 owner 的错误重入可抛异常。withLock 自动释放锁，所有共享状态读写都需遵守同一锁，不能只锁写入。

**关联知识点：** [协程并发控制与共享状态](../知识点梳理/协程并发控制与共享状态.md#mutex互斥)

<a id="advanced-q18"></a>
###### Semaphore 和 limitedParallelism 都能限制上传并发数吗？

**简答版：** 不能等同。limitedParallelism 限制代码执行并行度，挂起上传让出执行槽后仍可启动更多请求；共享 Semaphore 的许可覆盖整个 withPermit，能限制在途上传数。

**深入追问：** limitedParallelism(1) 也不是跨挂起点互斥锁，视图需复用；Semaphore 也要共享，且只限制并发数量，不限制每秒请求数。海量任务还需避免一次创建过多等待协程。

**关联知识点：** [协程并发控制与共享状态](../知识点梳理/协程并发控制与共享状态.md#limitedparallelism边界)

<a id="advanced-q19"></a>
###### Channel 与 SharedFlow 的多消费者语义有什么区别？

**简答版：** Channel 把一个元素交给一个接收者，receiveAsFlow 的多收集者竞争接收；SharedFlow 向订阅者广播，StateFlow 则广播合并后的当前状态。

**深入追问：** Channel 适合 worker 分配，SharedFlow 适合多观察者；容量、关闭和无订阅者行为要单独设计。close 通常允许排空缓冲，cancel 会放弃待处理元素。

**关联知识点：** [协程并发控制与共享状态](../知识点梳理/协程并发控制与共享状态.md#channel与广播)

<a id="advanced-q20"></a>
###### Channel 发送成功是否保证事件被业务消费一次？

**简答版：** 不保证。发送成功表示通道接受或交付了元素，不等于接收方已完成业务；接收与取消竞争还可能使事件来不及处理。

**深入追问：** 可靠处理需要确认、幂等和必要的持久化。onUndeliveredElement 主要清理未交付元素关联的资源，不是可靠重试或消费确认机制。

**关联知识点：** [协程并发控制与共享状态](../知识点梳理/协程并发控制与共享状态.md#channel与广播)

<a id="flow执行与重复收集"></a>
###### flow 创建时会执行吗，两个 collect 是重放还是重新执行？

**简答版：** flow 构建器保存生产逻辑，通常在 collect 时才运行。两个 collect 各执行一遍上游，后一次拿到数据是重新生产，不是重放前一次历史。

**深入追问：** 同一 Flow 对象不意味着共享结果。顺序写两个 collect 时，第一个不结束就到不了第二个；并发收集需分别 launch。共享上游需复用同一个 stateIn / shareIn 产物。

**关联知识点：** [Flow 冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#flow创建发射与收集)

<a id="stateflow晚订阅"></a>
###### StateFlow 在没有订阅者时更新，新订阅者为什么还能收到？

**简答版：** StateFlow 一直保存当前值，新订阅者会收到最新状态；未更新过则收到初始值。默认 SharedFlow 的 replay 为 0，没有这种历史保留行为。

**深入追问：** 先写入 1、2 再订阅 StateFlow，收到的是当前 2，不会补发 0、1。直接读 value 不是订阅；只有同一实例才谈得上读取旧状态，新实例或进程重启不会自动恢复，stateIn 还受缓存重置策略影响。

**关联知识点：** [Flow 冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#先发送后订阅)

<a id="背压缓冲与合并"></a>
###### 慢订阅者、背压、缓冲、合并和去重有什么区别？

**简答版：** 慢订阅者描述消费能力；背压指消费能力约束生产速度；缓冲暂存值；合并跳过待处理的中间值；去重抑制相等值。

**深入追问：** StateFlow 既按 equals 去重，也允许慢收集者跳过不同的中间状态，不会等待慢订阅者。SharedFlow 在 SUSPEND 策略下缓冲满会挂起 emit。conflate 不取消当前消费块，collectLatest 会请求取消旧处理；这些都不能撤销已发生的业务副作用。

**关联知识点：** [Flow 冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#背压与数据流术语)

<a id="flow不自动监听"></a>
###### 返回 Flow 是否就代表自动监听数据变化，flowOf(load()) 会延迟执行吗？

**简答版：** 不是。flow { emit(load()) } 每次收集只调用一次 load，发出结果后结束，不会自动观察服务器；flowOf(load()) 则先求值 load，再创建流。

**深入追问：** 持续更新必须来自 Room 观察、回调、轮询等生产机制。只有一次结果时通常用 suspend 更简单；判断副作用何时执行要看代码位于构建器内部还是参数求值阶段。

**关联知识点：** [Flow 冷流热流与操作符](../知识点梳理/Flow冷流热流与操作符.md#flow创建发射与收集)

<a id="scope-api-types"></a>
###### CoroutineScope、launch、withContext、runBlocking 分别是什么，能混称为作用域吗？

**简答版：** CoroutineScope 是任务归属入口；launch 是启动子协程的扩展函数并返回 Job；withContext 是等待指定上下文代码完成的挂起函数；runBlocking 是阻塞调用线程的桥接构建器。

**深入追问：** scope 不等于线程池，suspend 也不自动启动任务。withContext 创建局部执行边界，不是需要长期持有的页面作用域。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#概念与方法总览)

<a id="async-start-await"></a>
###### async 什么时候开始执行，await 是启动任务还是等待结果？

**简答版：** 默认 async 调用后就按调度器安排启动，await 主要负责等待并取结果；LAZY 模式下 await 也会触发启动。

**深入追问：** 先启动多个 async 再等待才能重叠执行；async 后立即 await，再创建下一个通常是串行。多次 await 同一 Deferred 不重复执行；普通父级下 async 失败也会向父级传播。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#async并发获取结果)

<a id="context-versus-blocking"></a>
###### withContext 和 runBlocking 都等待结果，区别在哪里？

**简答版：** withContext 挂起当前协程，不以阻塞调用线程的方式等待；runBlocking 阻塞调用线程直到块及子任务完成，用于普通入口桥接。

**深入追问：** runBlocking 默认通过线程内事件循环推进工作，但线程仍被这个调用占用。即使传 IO 也不能避免阻塞原调用线程；已有协程通常用 withContext / coroutineScope，不要嵌套 runBlocking。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#runblocking演示入口)

<a id="global-demo-wait"></a>
###### 为什么 GlobalScope 内部加 delay，外层演示入口仍可能提前结束？

**简答版：** GlobalScope 任务不属于外层入口的任务树，launch 立即返回；内部 delay 只挂起独立任务，不会让外层方法等待。

**深入追问：** 学习演示可用 runBlocking 加普通 launch；若专门展示 GlobalScope，则保存 Job 并显式 join。runBlocking 只会自动等待自己的子任务，不能自动等待所有全局任务。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#runblocking演示入口)

<a id="local-scope-failure"></a>
###### coroutineScope 和 supervisorScope 如何等待子任务并处理失败？

**简答版：** 两者都等待块及其子任务结束；coroutineScope 子任务失败通常取消整个局部任务树，supervisorScope 隔离直接子任务的失败。

**深入追问：** 监督不吞异常，async 的 await 失败需明确处理；若异常逃出 supervisorScope 代码块，整个 scope 仍失败并取消其他任务。父级取消对两种 scope 都向下传播。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#局部作用域与失败隔离)

<a id="job-supervisor-intro"></a>
###### Job 和 SupervisorJob 有什么区别，监督会自动处理异常吗？

**简答版：** 普通 Job 下直接子任务的未处理非取消异常会使父级失败并取消兄弟任务；SupervisorJob 隔离直接子任务失败，父级与其他子任务可继续。两者主动取消时都会取消子任务。

**深入追问：** 监督不恢复失败任务，也不自动生成错误态。launch 的未处理异常仍需适当 handler 或任务内部处理；async 需观察 await 的失败。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#supervisorjob失败隔离)

<a id="supervisor-depth"></a>
###### SupervisorJob 会隔离所有后代的失败吗，和 supervisorScope 怎么选？

**简答版：** 只改变直接子任务失败向监督父级的传播，不把所有后代变成监督关系。长期 owner 可用 SupervisorJob 配置 scope，一次挂起调用中的局部任务通常用 supervisorScope。

**深入追问：** 监督父级下的 launch A 内部若有普通 async 子任务，子任务失败仍可能取消 A 和 A 内的其他任务；其他直接兄弟 B 可不受影响。supervisorScope 自身代码块抛异常仍使局部作用域失败。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#supervisorjob与supervisorscope)

<a id="context-job-dispatcher"></a>
###### CoroutineContext 的加号是什么意思，Job 和 Dispatcher 分别负责什么？

**简答版：** 加号组合上下文配置，同 key 的右侧覆盖左侧。Job 管生命周期和父子取消关系，Dispatcher 管代码执行与恢复的调度位置。

**深入追问：** 创建 Job 或 scope 不执行任务；launch / async 创建子任务。Context 不是 Android Context，随意传新 Job 可能替换父级，Dispatcher 变化本身则不意味着任务脱离原 owner。

**关联知识点：** [协程作用域与常用方法](../知识点梳理/协程作用域与常用方法.md#入门核心对象)

<a id="suspend-immediate"></a>
###### suspend 函数一定挂起吗，为什么不等于开线程？

**简答版：** 不一定。缓存命中或结果已就绪可以立即返回，suspend 只是允许通过续体机制挂起恢复。

**深入追问：** 它不自动创建任务或线程，也不把 Thread.sleep 变成非阻塞；调度器决定运行环境，阻塞代码仍占用线程。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景一立即返回)

<a id="suspend-saved-locals"></a>
###### 一个函数有两个挂起点，恢复位置和局部变量如何保存？

**简答版：** 编译器把跨挂起点的控制流转换成状态机，登记恢复位置并保存后续仍需使用的变量；恢复时接收结果并执行对应段。

**深入追问：** 不复制整个线程栈，也不保存所有无用变量。字段名和状态数量取决于编译器优化，立即返回路径可连续经过多个状态。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景三多个挂起点与局部变量)

<a id="suspend-marker"></a>
###### 挂起函数立即返回与返回 COROUTINE_SUSPENDED 有什么区别？

**简答版：** 立即返回表示这次调用已经有结果，调用方可以继续；返回内部挂起标记表示结果稍后通过续体恢复交付。

**深入追问：** Kotlin 业务代码不手动检查该标记。实际挂起后调用栈返回，恢复不是从函数第一行重跑；尾调用等场景可能被优化，不一定生成独立完整状态机。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景三多个挂起点与局部变量)

<a id="suspend-loop"></a>
###### 循环里的挂起点会为每次循环创建一个独立状态吗？

**简答版：** 通常不会，同一个调用点可以重复使用恢复位置，通过保存的循环进度和局部状态区分当前迭代。

**深入追问：** 例如循环 delay 后累加，需要保留迭代状态和累计值；不能按循环次数或源码行数机械推算状态机数量。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景四分支循环与嵌套调用)

<a id="suspend-resume-thread"></a>
###### continuation.resume 后一定在回调线程继续执行吗？

**简答版：** 不一定，恢复代码遵循协程上下文的调度规则；回调线程负责提交结果，调度器决定后续执行位置。

**深入追问：** Main 通常回到主线程，Default / IO 不保证同一条工作线程；某些直接执行路径可能在当前线程继续。Job、状态机和调度器分别负责取消、恢复位置和执行环境。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景六回调如何恢复续体)

<a id="suspend-failure-state"></a>
###### 挂起后恢复的异常如何进入原来的 catch 和 finally？

**简答版：** 续体可以传递失败结果，恢复状态机在对应挂起调用处传播异常，原来的 try/catch/finally 控制流仍成立。

**深入追问：** 取消通常通过 CancellationException 在可取消挂起点退出，finally 仍执行；不合作的阻塞调用不会因此被强制停止。挂起式清理还需考虑取消状态。

**关联知识点：** [挂起函数与状态机场景详解](../知识点梳理/挂起函数与状态机场景详解.md#场景七异常取消和finally)

<a id="source-suspended-return"></a>
###### COROUTINE_SUSPENDED 是谁返回的，怎样逐层让调用栈退出？

**简答版：** 在本例正数 delay 中，注册定时恢复后 CancellableContinuationImpl.getResult 通过 trySuspend 确认挂起，返回标记；delay、业务函数和调用方生成代码逐层识别并返回同一标记。

**深入追问：** 状态与变量已保存在续体对象中，退出线程栈不意味着丢失进度。delay(0) 直接返回，回调提前完成也可能让 getResult 直接取值，不发生真正挂起。

**关联知识点：** [挂起函数与状态机场景详解：源码分析](../知识点梳理/挂起函数与状态机场景详解.md#标记逐层返回)

<a id="source-two-states"></a>
###### label 与 CancellableContinuation 的决策状态有什么区别？

**简答版：** label 是业务函数恢复位置，例如两次 delay 对应恢复分支 1 和 2；UNDECIDED / SUSPENDED / RESUMED 是一次等待中挂起决定与结果就绪的竞争协议。

**深入追问：** 还要区分成功或失败的结果状态和 Job 生命周期。原子决策让提前恢复走直接返回路径，挂起先发生则走后续恢复路径，避免同一次结果被两条路径重复交付。

**关联知识点：** [挂起函数与状态机场景详解：源码分析](../知识点梳理/挂起函数与状态机场景详解.md#立即返回与恢复竞争)

<a id="source-label-high-bit"></a>
###### invokeSuspend 为什么带着 0 参数重新调用函数却不会从头执行？

**简答版：** 本例生成续体先保存 incoming result，并给 label 设置最高位恢复标记，再传自身重新调用生成函数。入口识别标记，复用续体并去掉最高位，按原来的 label 跳入恢复分支。

**深入追问：** 恢复分支从 I$0、J$0、L$0 等字段取回原参数和局部变量，0 只是重入调用的占位参数。字段、最高位与编号属于指定编译器版本实现，不能当成业务 API。

**关联知识点：** [挂起函数与状态机场景详解：源码分析](../知识点梳理/挂起函数与状态机场景详解.md#恢复label一与二)

<a id="source-base-loop"></a>
###### 第一次恢复又挂起、第二次恢复返回结果，BaseContinuationImpl 分别怎么处理？

**简答版：** resumeWith 调用 invokeSuspend；若再次返回挂起标记就立即返回，不通知调用方完成。若返回真正结果，则包装成功结果并推进 completion；抛异常则包装失败推进。

**深入追问：** completion 也是 BaseContinuationImpl 时，标准库通过循环推进上一层而不是简单递归。这样第一次 delay 只推进到第二次等待，第二次等待结束后才把完整字符串交给 main。

**关联知识点：** [挂起函数与状态机场景详解：源码分析](../知识点梳理/挂起函数与状态机场景详解.md#标准库恢复循环)
