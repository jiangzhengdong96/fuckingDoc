### StateFlow 状态更新细节

<!-- page-toc:start -->
**目录**

- [内容概述](#section-内容概述)
- [使用场景](#section-使用场景)
- [当前值与相等合并](#当前值与相等合并)
- [可变集合与不可变快照](#可变集合与不可变快照)
- [原子更新与副作用](#原子更新与副作用)
- [状态与事件语义](#状态与事件语义)
- [有 StateFlow 为什么还需要 SharedFlow](#有stateflow为什么还需要sharedflow)
- [用状态表达待处理事件](#用状态表达待处理事件)
- [状态收集与测试](#状态收集与测试)
- [状态收集与测试：面试可能怎么问](#状态-面试问题)
<!-- page-toc:end -->


<a id="section-内容概述"></a>
###### 内容概述

解释 equals 合并、不可变状态、原子更新、状态与事件、以及测试时可能看不到中间状态的原因。SharedFlow 构造参数见 [缓冲参数](./Android协程.md#sharedflow-缓冲参数)。

<a id="section-使用场景"></a>
###### 使用场景

列表刷新、多个请求同时更新页面不同字段、重复错误提示、状态流单元测试。

<a id="当前值与相等合并"></a>
###### 当前值与相等合并

StateFlow 必须有初始值，可通过 value 读取当前值；新订阅者获得当前状态。更新按 equals 判断，相等时不会再次通知。

这里的当前值包括订阅之前已更新的最新值，不要求发送时就有人订阅；例如先写入 1、2 再订阅，会收到 2。与 SharedFlow replay 的完整对比见 [先发送后订阅会收到什么](./Flow冷流热流与操作符.md#先发送后订阅)。

```kotlin
data class UiState(val loading: Boolean = false, val items: List<Item> = emptyList())
private val _state = MutableStateFlow(UiState())
val state = _state.asStateFlow()
```

StateFlow 是热流，正常 collect 不会自行结束；异常应建模为状态，而不是期待 StateFlow 自身向订阅者抛业务失败。慢收集者可跳过中间变化，只观察到最新值，不保证每次赋值都触发一次 UI 渲染。

<a id="可变集合与不可变快照"></a>
###### 可变集合与不可变快照

错误思路是拿到当前状态里的可变集合后原地 add，再把同一个对象赋回去。旧值也已经被改动，相等比较可能认为没有变化；即使用 copy，也可能因复用同一个已变更集合而无法正确区分前后快照。

```kotlin
// 创建新集合和新状态，保留旧快照。
_state.update { old -> old.copy(items = old.items + newItem) }
```

Kotlin 的 List 只是只读接口，不等于底层对象永远不可变；Item 自身也可能可变。不要向外暴露仍会被其他代码修改的集合或实体引用。列表很大时要权衡复制成本，可根据场景选择持久化不可变集合和分拆状态。

<a id="原子更新与副作用"></a>
###### 原子更新与副作用

`MutableStateFlow.value` 的单次读写线程安全，但 `value = value.copy(...)` 包含读、计算、写多个步骤，不是整体原子操作。两个线程可能读取相同旧状态，然后分别覆盖对方修改。

```kotlin
_state.update { old -> old.copy(loading = false) }
```

| 方法 | 结果 |
|---|---|
| `update { ... }` | 原子更新，不返回前后状态 |
| `getAndUpdate { ... }` | 原子更新并返回更新前的状态 |
| `updateAndGet { ... }` | 原子更新并返回更新后的状态 |
| `compareAndSet(expect, update)` | 按相等语义比较并尝试更新，返回是否成功 |

update 基于重试语义，lambda 在竞争下可能执行多次。因此其中只做无副作用的状态计算，不要发请求、计费、写日志计数或生成必须只执行一次的业务 ID。先取得结果，再通过纯转换更新状态；跨多个对象的事务不能只靠一个 StateFlow.update 保证。

单一主线程上、不含挂起点的简单读改写不会被另一普通协程插入，但跨挂起点就可能交错；采用 update 能明确表达原子转换意图，也便于将来改变线程策略。

<a id="状态与事件语义"></a>
###### 状态与事件语义

- 页面内容、loading、可持续展示的错误态适合 StateFlow。
- 相同 Toast 连续两次、每次都要处理的动作不适合仅凭相等状态发射；添加随机值只是绕开去重，未解决重放和消费确认。
- SharedFlow 是广播，Channel 分配元素给接收者，两者也不会自动保证业务恰好执行一次。
- 必须处理的结果可建模为带标识的待处理状态，由 UI 消费后确认；若要求跨进程死亡仍保留，需持久化。
- 正确选择先看“允许丢失、允许重放、是否需要确认”，再决定容器。

<a id="有stateflow为什么还需要sharedflow"></a>
###### 有 StateFlow 为什么还需要 SharedFlow

StateFlow 主要回答“现在是什么状态”，SharedFlow 用于广播独立消息。页面并非必须同时使用两者，但 StateFlow 不保证每次赋值都通知，不能直接替代所有消息流。

| 行为 | StateFlow | SharedFlow |
|---|---|---|
| 初始值与当前值 | 必须有初始值，可读 value | 不要求初始值，没有当前状态的语义 |
| 相等值连续发送 | 按 equals 合并 | 可以重复发送，不按 equals 去重 |
| 慢订阅者 | 允许跳过中间状态，观察较新的值 | 根据缓冲、挂起或丢弃策略处理 |
| 新订阅者 | 收到当前值 | 根据 replay 收到历史消息 |

```kotlin
val errorState = MutableStateFlow("")
errorState.value = "网络异常"
errorState.value = "网络异常" // 相等，不会再次通知

// 在协程中发射，假设已有持续收集的订阅者。
val errorEvents = MutableSharedFlow<String>()
errorEvents.emit("网络异常")
errorEvents.emit("网络异常") // 可以收到两条相同消息
```

StateFlow 的 emit 也遵循相等合并规则，不会因为把 value 赋值改成 emit 就变成事件流。上例 SharedFlow 默认没有 replay，无订阅者时两条消息都会丢失；不能只看 emit 调用次数就认定页面收到次数。

- 下载进度 `10% → 11% → 12%`：UI 忙时直接显示 12% 通常合理，适合状态合并。
- “文件 A 下载完成”和“文件 B 下载完成”：是两条独立消息，若要求已有订阅者逐条收到，可采用 SharedFlow 的挂起策略与适当缓冲；是否要求离线或页面恢复后补发，需要另行设计。
- 临时提示是否允许丢失由产品语义决定，不能简单规定“所有 Toast / 导航都用 SharedFlow”。`replay = 0` 可能丢消息，增加 replay 又可能重放；参数细节见 [SharedFlow 缓冲参数](./Android协程.md#sharedflow-缓冲参数)。

<a id="用状态表达待处理事件"></a>
###### 用状态表达待处理事件

StateFlow 可以保存“尚未处理的消息列表”这一状态，消费后按 ID 确认，而不是每发一条新消息就覆盖旧消息：

```kotlin
data class UiMessage(val id: String, val text: String)
data class MessageState(val pending: List<UiMessage> = emptyList())

private val _messages = MutableStateFlow(MessageState())
val messages = _messages.asStateFlow()

fun enqueueMessage(text: String) {
    // 在 update 外生成 ID，避免原子更新重试时重复执行副作用。
    val message = UiMessage(java.util.UUID.randomUUID().toString(), text)
    _messages.update { old -> old.copy(pending = old.pending + message) }
}

fun acknowledgeMessage(id: String) {
    _messages.update { old ->
        old.copy(pending = old.pending.filterNot { it.id == id })
    }
}
```

即使收集者跳过一次中间状态，只要消息未确认移除，最新 pending 列表中仍保留它。应由明确的消费者按顺序处理，完成后再确认；不要因为收到新状态就重新处理整个列表，或用 collectLatest 无条件取消正在处理的消息。

这个模型也不自动保证恰好处理一次：处理成功但确认前页面销毁，可能重复；先确认再处理，处理失败又可能丢失。多消费者需要协调归属，业务副作用需要幂等，进程死亡后的恢复需要持久化。添加消息 ID 只是支持识别与确认，不是可靠性保证。

选择建议：当前页面状态优先 StateFlow；有明确丢失、缓冲和重放约定的广播消息考虑 SharedFlow；可靠业务动作需要状态、确认与必要的持久化，不能只靠选择一种 Flow。

<a id="状态收集与测试"></a>
###### 状态收集与测试

View 使用 repeatOnLifecycle；Compose 使用 collectAsStateWithLifecycle。界面恢复时会收到当前状态，而不是自动重演页面离开期间的全部变化。

测试最终结果可断言 state.value；测试过程需要先启动收集，再驱动任务分阶段运行。即使收集提前开始，StateFlow 仍允许合并连续快速更新，不能把它当作事件审计日志。

```kotlin
@Test
fun incrementsAreNotLost() = runTest {
    val counter = MutableStateFlow(0)
    coroutineScope {
        repeat(100) {
            launch { counter.update { it + 1 } }
        }
    }
    assertEquals(100, counter.value)
}
```

示例用于说明更新与结构化等待，不等于真实多线程压力测试。使用 StandardTestDispatcher 测试 ViewModel 时，launch 默认可能尚未执行，应 runCurrent / advanceUntilIdle 或等待任务；不能调用 load 后立刻假定状态已更新。Main 需要按测试环境 setMain / resetMain，多个测试 Dispatcher 应共享同一个 TestCoroutineScheduler。

WhileSubscribed 的 stateIn 没有订阅者就不会启动上游；单测只读 value 可能永远是初始值。可用 backgroundScope.launch 启动收集，并推进调度器。advanceTimeBy 推进到目标时刻后，目标时刻排队的任务可能还需 runCurrent；不要靠 Thread.sleep 测虚拟时间。

<a id="状态-面试问题"></a>
###### 面试可能怎么问

- StateFlow 为什么重复赋相同值不通知，慢收集者会漏掉中间值吗？
- 为什么原地修改状态里的 MutableList 可能不刷新 UI？
- value 线程安全，为什么还需要 update，update 中能放副作用吗？
- 为什么测试 WhileSubscribed 的 StateFlow 时只读 value 不够？
- 有 StateFlow 为什么还需要 SharedFlow，页面能否只用 StateFlow？
- 用 StateFlow 保存待处理消息列表，是否就能保证恰好消费一次？

对应答案见 [Flow 与协程进阶面试题](../面试/Flow与协程进阶面试题.md)。
