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
