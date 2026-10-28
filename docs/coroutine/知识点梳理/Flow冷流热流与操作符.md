### Flow 冷流热流与操作符

<!-- page-toc:start -->
**目录**

- [内容概述](#section-内容概述)
- [使用场景](#section-使用场景)
- [冷流与热流](#冷流与热流)
- [共享上游与启动策略](#共享上游与启动策略)
- [操作符选择](#操作符选择)
- [异常与重试](#异常与重试)
- [回调与生命周期](#回调与生命周期)
- [回调与生命周期：面试可能怎么问](#flow-面试问题)
<!-- page-toc:end -->


<a id="section-内容概述"></a>
###### 内容概述

理解重复收集、共享上游、启动策略、操作符和错误边界。示例中的 repository、UI 模型代表业务依赖，需要在实际项目中替换；涉及实验性 API 时按使用的 kotlinx.coroutines 版本添加对应 OptIn。

<a id="section-使用场景"></a>
###### 使用场景

搜索防抖、数据库观察、多个 UI 同时订阅数据、页面切到后台后停止工作、失败重试。

<a id="冷流与热流"></a>
###### 冷流与热流

| 类型 | 启动与共享 | 新订阅者收到什么 |
|---|---|---|
| `flow { ... }` 等典型冷流 | 每次 collect 独立执行上游代码 | 本次执行产生的数据 |
| `SharedFlow` | 多个订阅者共享发射，生产者生命周期由 owner 管理 | replay 历史和之后的新值 |
| `StateFlow` | 共享一个当前状态 | 当前值及之后变化，按 equals 合并 |

```kotlin
val detail = flow { emit(repository.loadDetail()) }
// 两个 collect 会独立执行两次 loadDetail，而不是共享同一次请求。
```

Flow 类型本身不承诺冷流；StateFlow、SharedFlow 也实现 Flow。不要仅凭变量声明为 Flow 就认定重复收集一定会重新请求，要看上游实现。

默认冷流中 emit 与下游算子顺序执行，慢 collect 会拖慢上游；引入 buffer、flowOn、共享转换后才可能分开执行。Flow 不自动切后台，阻塞操作仍需适当 Dispatcher。

<a id="共享上游与启动策略"></a>
###### 共享上游与启动策略

```kotlin
val uiState: StateFlow<DetailUiState> = repository.observeDetail()
    .map<Detail, DetailUiState> { DetailUiState.Content(it) }
    .catch { emit(DetailUiState.Error(it.message)) }
    .stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(
            stopTimeoutMillis = 5_000,
            replayExpirationMillis = 0
        ),
        initialValue = DetailUiState.Loading
    )
```

| 参数 / API | 含义与边界 |
|---|---|
| `scope` | 执行共享上游的作用域；scope 取消后不能靠重新订阅复活 |
| `stateIn(scope, started, initialValue)` | 冷流转 StateFlow，需要初始状态；另一个挂起重载等待首值，不能混淆 |
| `shareIn(scope, started, replay)` | 转 SharedFlow，replay 默认 0；默认缓冲不能简单等同于 MutableSharedFlow 的全零构造 |
| `Eagerly` | 创建共享流后立即启动上游，不等待订阅者 |
| `Lazily` | 首个订阅者出现才启动，之后无订阅者也不会因此停掉上游 |
| `WhileSubscribed` | 有订阅者时启动，最后一个订阅者离开后按配置停止 |
| `stopTimeoutMillis` | 无订阅者后等待多久才停止上游，默认 0；不是请求超时时间 |
| `replayExpirationMillis` | 上游停止后再过多久重置缓存，默认 Long.MAX_VALUE，即一直保留；必须非负 |

两个时间依次计算：最后一个订阅者离开 → 等待 stopTimeoutMillis → 停上游 → 等待 replayExpirationMillis → 重置缓存。有新订阅者时会按策略重新启动；窗口内重新订阅可避免一次停止和重启。

缓存重置时，stateIn 回到 initialValue，shareIn 清空 replay 历史。停止上游不等于马上清空页面状态；上例停止后立即重置为 Loading，是明确的产品选择，不是通用默认推荐。

`WhileSubscribed(5_000)` 常用于缓冲旋转等短暂订阅中断，但 5 秒不是固定标准。返回页面是否重新请求取决于是否已停止上游、冷流内部逻辑和数据缓存；stateIn 不是网络缓存层。应把共享属性定义一次，不要每次 getter 都重新 stateIn。

<a id="操作符选择"></a>
###### 操作符选择

| API | 作用 | 易混点 |
|---|---|---|
| `collect` | 依次处理每个到达的值 | 前面已被上游合并或丢弃的值无法补回 |
| `collectLatest` | 新值到达时取消上一次 collect 处理块 | 不是仅丢排队值；取消也不能撤销已提交的副作用 |
| `buffer(capacity, onBufferOverflow)` | 用缓冲解耦上游与下游，默认满时挂起 | capacity 是缓存数量，不是业务请求并发数 |
| `conflate` | 忙时保留较新值，丢弃待处理的旧值 | 不取消当前正在执行的 collect 块 |
| `mapLatest` | 新输入到达时取消旧输入的转换块 | 适用于可取消的单次计算 / 请求 |
| `flatMapLatest` | 切换到最新输入对应的内层 Flow | 取消旧流收集；已交付的旧值不会自动撤回 |
| `debounce(timeoutMillis)` | 一段时间没有新值后再发射最近值 | 持续快速输入可能一直不发射；上游正常结束时最后值可立即发射 |
| `distinctUntilChanged` | 抑制相邻相等值 | 默认用 equals；StateFlow 自身已有该语义 |
| `combine` | 任意上游更新后，用各自最新值组合 | 要等每个上游至少发射一次；适合筛选条件加数据 |
| `zip` | 两边逐项配对 | 一边结束时配对流结束，不适合无限等待另一边的最新状态 |

搜索示例：

```kotlin
@OptIn(FlowPreview::class, ExperimentalCoroutinesApi::class)
fun searchResults(queries: Flow<String>): Flow<SearchState> = queries
    .map { it.trim() }
    .debounce(300)
    .distinctUntilChanged()
    .flatMapLatest { query ->
        flow<SearchState> {
            if (query.isBlank()) {
                emit(SearchState.Empty)
            } else {
                emit(SearchState.Loading)
                emit(SearchState.Content(repository.search(query)))
            }
        }.catch { error -> emit(SearchState.Error(error.message)) }
    }
```

catch 放在单次搜索的内层：某次请求失败后，仍能接收后续输入。若放在整个输入链外，捕获并发出错误后该次收集通常就结束了。

debounce 放在 flatMapLatest 前，意味着新按键要等防抖窗口结束才取消旧请求；不能宣称“按键瞬间取消”。若要求原始输入一变就取消，可在原始输入之后先 flatMapLatest，再在内层 delay 防抖。严格防止旧数据覆盖，还要结合请求标识、关键词校验以及底层取消支持。

<a id="异常与重试"></a>
###### 异常与重试

- `catch` 只处理它之前的上游异常，不处理后续算子或 collect 内的异常；协程取消不应转换成业务错误。
- `retryWhen { cause, attempt -> ... }` 中 attempt 从 0 开始；返回 true 才重新收集上游。它不重试下游异常或用于取消的异常。
- 重试会重新执行上游代码，不只是重新接收最后一个值。支付、写入等副作用必须先考虑幂等，不能盲目重试。

```kotlin
val data = flow { emit(repository.load()) }
    .retryWhen { cause, attempt ->
        if (cause is IOException && attempt < 3) {
            delay(500L * (1L shl attempt.toInt())) // 0.5、1、2 秒
            true
        } else false
    }
// 初次执行 + 最多 3 次重试，总共最多 4 次。
```

需要重试或转错误态的逻辑通常放在 stateIn / shareIn 之前。共享上游失败会终止共享协程，由 scope 的异常规则处理，订阅者不会像普通冷流 collect 一样直接收到该异常；stateIn 可能停在最后状态。上游正常结束也不会使 StateFlow / SharedFlow 的订阅者正常结束。

<a id="回调与生命周期"></a>
###### 回调与生命周期

单次回调用 suspendCancellableCoroutine；持续回调用 callbackFlow，并在 awaitClose 注销监听：

```kotlin
fun observeLocation(): Flow<Location> = callbackFlow {
    val listener = LocationListener { location ->
        val result = trySend(location)
        // 失败可能是缓冲满或已关闭；按业务选择丢弃、记录或其他策略。
    }
    client.register(listener)
    awaitClose { client.unregister(listener) }
}
```

这是接口示意：实际 register / unregister 必须考虑注册失败、线程要求，以及取消与回调并发。不要在回调里阻塞等待发送，trySend 返回失败也不能假装必达。多个冷流收集者会各自注册监听，需要共享时用 shareIn / stateIn。

UI 使用 repeatOnLifecycle；多个长期 Flow 应分别 launch 收集，不能先后写两个无限 collect。Compose 页面可用 collectAsStateWithLifecycle。只有收集者全部离开时，WhileSubscribed 才会进入停止倒计时。

<a id="flow-面试问题"></a>
###### 面试可能怎么问

- 冷 Flow 为什么可能重复请求，stateIn 和 shareIn 怎么选？
- WhileSubscribed 的两个超时参数分别控制什么？
- collectLatest、conflate 和 buffer 有什么区别？
- 搜索使用 debounce 和 flatMapLatest 能保证旧结果绝不出现吗？
- Flow 的 catch 和 retryWhen 能处理哪些异常？
- callbackFlow 为什么需要 awaitClose？

对应答案见 [Flow 与协程进阶面试题](../面试/Flow与协程进阶面试题.md)。
