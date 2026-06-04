### Android TV 列表和焦点性能知识点清单

###### 内容概述

本文件记录 Android TV 列表和焦点性能相关知识，包括 RecyclerView、横竖嵌套列表、焦点稳定、数据刷新、图片加载、预加载、滚动性能和常见优化方向。

###### 使用场景

- TV 首页、频道页、搜索结果页、推荐列表、选集列表等都大量依赖列表和焦点。
- 当出现列表卡顿、焦点丢失、焦点跳错、返回后位置错乱、图片闪烁时，可以从本文件梳理排查点。
- 面试中 TV 列表焦点、RecyclerView 复用和性能优化属于高频问题。

一级栏目导航：

- [TV 列表特点](#tv-列表特点)
- [RecyclerView 基础策略](#recyclerview-基础策略)
- [Adapter 和 ViewHolder 写法](#adapter-和-viewholder-写法)
- [横竖嵌套列表](#横竖嵌套列表)
- [嵌套列表代码结构](#嵌套列表代码结构)
- [焦点稳定](#焦点稳定)
- [数据刷新](#数据刷新)
- [图片加载](#图片加载)
- [预加载和缓存](#预加载和缓存)
- [性能优化](#性能优化)
- [面试可能怎么问](#面试可能怎么问)

<a id="tv-列表特点"></a>
###### TV 列表特点

- TV 列表不是单纯滚动列表，而是“列表 + 焦点 + 遥控器路径”的组合。
- TV 首页常见结构是纵向栏目列表，每一行内部是横向内容列表。
- 用户按上、下切换栏目，按左、右切换栏目内卡片，按确认进入详情或播放。
- TV 列表要保持焦点移动可预期。用户关心的是“按一下方向键会去哪里”。
- 列表 item 尺寸、间距、焦点放大、图片加载状态都会影响焦点体验。

<a id="recyclerview-基础策略"></a>
###### RecyclerView 基础策略

- RecyclerView 是 TV 列表常用实现，但默认行为更偏通用移动端，需要结合 TV 焦点定制。
- item 根布局一般要设置 `focusable=true`，并有明确焦点态。
- ViewHolder 绑定数据时要避免重置用户当前焦点状态，尤其是局部刷新和复用场景。
- 尽量使用稳定 item 尺寸，避免加载图片后高度或宽度变化。
- 尽量使用 DiffUtil 或 ListAdapter，减少全量刷新导致的焦点丢失。
- 可以根据业务开启 stable id，让 RecyclerView 更容易保持 item 身份稳定。
- 不要在 `onBindViewHolder()` 中无条件 `requestFocus()`，否则滚动和刷新时会反复抢焦点。
- 如果需要请求焦点，要先判断是否是目标 item、是否已 attach、是否当前页面允许恢复焦点。

<a id="adapter-和-viewholder-写法"></a>
###### Adapter 和 ViewHolder 写法

TV 列表推荐优先使用 `ListAdapter + DiffUtil`，让 item 身份稳定，减少刷新时焦点 View 被销毁的概率。

```kotlin
class ContentAdapter(
    private val onCardClick: (Content) -> Unit,
    private val onCardFocus: (Content, Int) -> Unit
) : ListAdapter<Content, ContentViewHolder>(DIFF) {

    init {
        setHasStableIds(true)
    }

    override fun getItemId(position: Int): Long {
        return getItem(position).id.hashCode().toLong()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ContentViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_tv_content_card, parent, false)
        return ContentViewHolder(view, onCardClick, onCardFocus)
    }

    override fun onBindViewHolder(holder: ContentViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<Content>() {
            override fun areItemsTheSame(oldItem: Content, newItem: Content): Boolean {
                return oldItem.id == newItem.id
            }

            override fun areContentsTheSame(oldItem: Content, newItem: Content): Boolean {
                return oldItem == newItem
            }
        }
    }
}
```

ViewHolder 中只绑定当前 item 的显示、点击、焦点态，不在 `bind()` 里无条件恢复焦点：

```kotlin
class ContentViewHolder(
    itemView: View,
    private val onCardClick: (Content) -> Unit,
    private val onCardFocus: (Content, Int) -> Unit
) : RecyclerView.ViewHolder(itemView) {

    private val poster = itemView.findViewById<ImageView>(R.id.poster)
    private val title = itemView.findViewById<TextView>(R.id.title)

    fun bind(item: Content) {
        title.text = item.title
        poster.load(item.posterUrl) {
            crossfade(false)
            placeholder(R.drawable.bg_poster_placeholder)
            size(360, 520)
        }

        itemView.setOnClickListener {
            onCardClick(item)
        }

        itemView.setOnFocusChangeListener { view, hasFocus ->
            view.isSelected = hasFocus
            view.animate()
                .scaleX(if (hasFocus) 1.08f else 1f)
                .scaleY(if (hasFocus) 1.08f else 1f)
                .setDuration(120L)
                .start()

            if (hasFocus && bindingAdapterPosition != RecyclerView.NO_POSITION) {
                onCardFocus(item, bindingAdapterPosition)
            }
        }
    }
}
```

item XML 建议固定宽高，并给焦点放大留出外部空间：

```xml
<FrameLayout
    android:layout_width="204dp"
    android:layout_height="292dp"
    android:clipChildren="false"
    android:clipToPadding="false"
    android:padding="12dp">

    <FrameLayout
        android:id="@+id/cardRoot"
        android:layout_width="180dp"
        android:layout_height="260dp"
        android:layout_gravity="center"
        android:clickable="true"
        android:focusable="true"
        android:background="@drawable/bg_tv_card_selector">

        <!-- poster + title -->
    </FrameLayout>
</FrameLayout>
```

<a id="横竖嵌套列表"></a>
###### 横竖嵌套列表

- 横竖嵌套列表常见于 TV 首页：外层竖向 RecyclerView 表示栏目，内层横向 RecyclerView 表示内容。
- 外层 item 可以表示一整行，包括行标题和横向列表。
- 内层 item 表示具体内容卡片，通常是真正获得焦点的对象。
- 常见问题：

| 问题 | 原因 |
|---|---|
| 上下移动后列位置不稳定 | 每一行横向列表滚动位置不同，未保存列索引 |
| 返回后焦点回不到原卡片 | 只保存外层 position，没有保存内层 position 或业务 id |
| 横向列表刷新后焦点丢失 | 内层 item 被重建或 detach |
| 连续按键卡顿 | 嵌套列表同时滚动、图片加载和焦点动画过重 |

- 外层行和内层 item 都要有焦点恢复策略。通常保存外层栏目 id、内层内容 id、外层 position、内层 position。
- 横向列表滚动位置要按栏目保存。否则用户上下切换后，可能每行都回到第一个 item。
- 嵌套列表要控制 ViewPool、缓存和预取，减少频繁创建 ViewHolder。

<a id="嵌套列表代码结构"></a>
###### 嵌套列表代码结构

首页常见数据结构：

```kotlin
data class HomeRow(
    val id: String,
    val title: String,
    val items: List<Content>
)

data class FocusAnchor(
    val rowId: String,
    val contentId: String,
    val rowPosition: Int,
    val itemPosition: Int
)
```

外层 Adapter 负责行，内层 Adapter 负责卡片。共享 `RecycledViewPool` 可以减少内层 ViewHolder 创建：

```kotlin
class HomeRowAdapter(
    private val sharedPool: RecyclerView.RecycledViewPool,
    private val onCardClick: (Content) -> Unit,
    private val onCardFocus: (HomeRow, Content, Int, Int) -> Unit
) : ListAdapter<HomeRow, RowViewHolder>(ROW_DIFF) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RowViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_tv_home_row, parent, false)
        return RowViewHolder(view, sharedPool, onCardClick, onCardFocus)
    }

    override fun onBindViewHolder(holder: RowViewHolder, position: Int) {
        holder.bind(getItem(position), position)
    }
}
```

行 ViewHolder 初始化横向列表：

```kotlin
class RowViewHolder(
    itemView: View,
    sharedPool: RecyclerView.RecycledViewPool,
    private val onCardClick: (Content) -> Unit,
    private val onCardFocus: (HomeRow, Content, Int, Int) -> Unit
) : RecyclerView.ViewHolder(itemView) {

    private val title = itemView.findViewById<TextView>(R.id.rowTitle)
    private val recyclerView = itemView.findViewById<RecyclerView>(R.id.horizontalList)
    private val adapter = ContentAdapter(
        onCardClick = onCardClick,
        onCardFocus = { content, itemPosition ->
            val row = currentRow ?: return@ContentAdapter
            val rowPosition = bindingAdapterPosition
            if (rowPosition != RecyclerView.NO_POSITION) {
                onCardFocus(row, content, rowPosition, itemPosition)
            }
        }
    )

    private var currentRow: HomeRow? = null

    init {
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(
            itemView.context,
            RecyclerView.HORIZONTAL,
            false
        )
        recyclerView.setRecycledViewPool(sharedPool)
        recyclerView.itemAnimator = null
        recyclerView.clipChildren = false
        recyclerView.clipToPadding = false
    }

    fun bind(row: HomeRow, rowPosition: Int) {
        currentRow = row
        title.text = row.title
        adapter.submitList(row.items)
    }
}
```

外层 RecyclerView 初始化：

```kotlin
private val sharedPool = RecyclerView.RecycledViewPool()

private val rowAdapter = HomeRowAdapter(
    sharedPool = sharedPool,
    onCardClick = { content -> openDetail(content) },
    onCardFocus = { row, content, rowPosition, itemPosition ->
        viewModel.saveFocus(
            FocusAnchor(
                rowId = row.id,
                contentId = content.id,
                rowPosition = rowPosition,
                itemPosition = itemPosition
            )
        )
    }
)

fun setupHomeList() {
    binding.rowList.adapter = rowAdapter
    binding.rowList.layoutManager = LinearLayoutManager(requireContext())
    binding.rowList.itemAnimator = null
    binding.rowList.clipChildren = false
    binding.rowList.clipToPadding = false
}
```

根据业务 id 恢复嵌套列表焦点：

```kotlin
fun restoreNestedFocus(anchor: FocusAnchor, rows: List<HomeRow>) {
    val rowPosition = rows.indexOfFirst { it.id == anchor.rowId }
        .takeIf { it >= 0 }
        ?: anchor.rowPosition.coerceIn(rows.indices)

    val row = rows.getOrNull(rowPosition) ?: return
    val itemPosition = row.items.indexOfFirst { it.id == anchor.contentId }
        .takeIf { it >= 0 }
        ?: anchor.itemPosition.coerceIn(row.items.indices)

    binding.rowList.scrollToPosition(rowPosition)

    binding.rowList.post {
        val rowHolder = binding.rowList
            .findViewHolderForAdapterPosition(rowPosition) as? RowViewHolder

        rowHolder?.requestChildFocus(itemPosition)
    }
}
```

行 ViewHolder 暴露内层恢复方法：

```kotlin
fun requestChildFocus(itemPosition: Int) {
    recyclerView.scrollToPosition(itemPosition)
    recyclerView.requestFocusWhenChildAttached(itemPosition) { child ->
        child.findViewById(R.id.cardRoot)
    }
}
```

恢复焦点时要处理数据为空、栏目被删除、内容被下架这些降级场景。上面的代码先按业务 id 找，找不到再按旧 position 降级。

<a id="焦点稳定"></a>
###### 焦点稳定

- 焦点稳定的关键是：焦点 View 不要无故被重建，焦点位置不要因为布局变化而跳动。
- 焦点 item 要有稳定业务 id，例如内容 id、频道 id、分类 id。
- 数据刷新后优先根据业务 id 找回 item，而不是只依赖 position。
- item 放大时不要影响测量尺寸，可以让外层容器固定尺寸，内部内容做缩放。
- 焦点边框和阴影不要被父容器裁剪。必要时检查 `clipChildren`、`clipToPadding`。
- 当前焦点滚动到边缘时，要保证列表能正确滚动并让新焦点可见。
- 复杂场景可以把“当前焦点位置”放到 ViewModel 或页面状态中管理，而不是散落在多个 ViewHolder。

<a id="数据刷新"></a>
###### 数据刷新

- `notifyDataSetChanged()` 会让 RecyclerView 认为整体数据都变了，容易导致焦点 View 被重建。
- 更推荐使用 DiffUtil，告诉 RecyclerView 哪些 item 是同一个、哪些内容变了。
- DiffUtil 判断通常分两层：

| 方法 | 作用 |
|---|---|
| `areItemsTheSame` | 判断是不是同一个业务对象 |
| `areContentsTheSame` | 判断内容是否完全一样 |

- 刷新后恢复焦点的顺序建议是：提交数据、等待列表完成布局、定位目标 item、滚动到可见、请求焦点。
- 如果刷新后目标 item 不存在，要有降级焦点：同栏目第一个、邻近 item、页面默认按钮。
- 分页加载时不要让底部 loading item 抢走焦点，除非它本身是可操作入口。

`submitList` 有提交完成回调，可以用于“数据已经进 Adapter 之后”的恢复入口：

```kotlin
rowAdapter.submitList(rows) {
    val anchor = viewModel.lastFocusAnchor
    if (anchor != null) {
        restoreNestedFocus(anchor, rows)
    } else {
        requestDefaultHomeFocus(rows)
    }
}
```

如果接口刷新很频繁，不要每次 `submitList` 都恢复焦点。可以加一个一次性标记：

```kotlin
private var pendingRestoreFocus = false

fun markNeedRestoreFocus() {
    pendingRestoreFocus = true
}

fun renderRows(rows: List<HomeRow>) {
    rowAdapter.submitList(rows) {
        if (pendingRestoreFocus) {
            pendingRestoreFocus = false
            viewModel.lastFocusAnchor?.let { restoreNestedFocus(it, rows) }
        }
    }
}
```

<a id="图片加载"></a>
###### 图片加载

- TV 列表通常图片多、尺寸大，图片加载会直接影响滚动性能和内存。
- 图片要按显示尺寸加载，不要加载原图后再缩小显示。
- item 要有固定宽高和占位图，避免加载完成后布局变化。
- 快速滚动时要避免旧请求回调把错误图片设置到复用后的 ViewHolder。
- 图片圆角、阴影、模糊、渐变等效果要评估性能，低端 TV 设备可能吃力。
- 背景大图要控制加载时机和缓存策略，避免首页多个背景同时解码造成卡顿。

<a id="预加载和缓存"></a>
###### 预加载和缓存

- TV 首页可以对下一屏、下一行、当前行附近 item 做适度预加载。
- 预加载要有边界，避免一次性加载过多图片和数据。
- RecyclerView 可以通过共享 `RecycledViewPool` 优化嵌套列表 ViewHolder 复用。
- 横向列表可以适当设置 item cache，但不能盲目调很大，内存会快速上涨。
- 数据缓存要区分内存缓存、本地缓存和网络缓存。TV 首页通常需要快速展示上次内容，再异步刷新。
- 播放类应用要考虑海报、背景图、剧集列表、推荐列表的数据缓存和失效策略。

<a id="性能优化"></a>
###### 性能优化

- 列表卡顿通常来自：布局层级深、频繁刷新、图片解码过大、焦点动画过重、主线程做计算、嵌套列表创建过多。
- 优化方向：

| 方向 | 做法 |
|---|---|
| 减少刷新 | 使用 DiffUtil、局部刷新、避免全量 notify |
| 降低布局成本 | 简化 item 层级、固定尺寸、减少嵌套权重 |
| 控制图片 | 按尺寸加载、占位图、缓存、避免大图主线程处理 |
| 优化焦点动画 | 缩短动画、避免触发布局、避免频繁创建动画对象 |
| 后台处理 | 数据转换、排序、过滤放后台线程 |
| 监控定位 | 使用 Profiler、Logcat、帧率、Systrace/Perfetto 分析 |

- TV 设备性能差异很大，不能只在高性能盒子上验证。
- 连续按方向键是必须压测的场景。用户会快速移动焦点，页面要保证按键响应、滚动和图片加载不互相拖垮。

<a id="面试可能怎么问"></a>
###### 面试可能怎么问

- [TV RecyclerView 焦点为什么容易丢](../面试/焦点和遥控器面试题.md#recyclerview-列表焦点为什么容易出问题)
- [TV 嵌套列表怎么做焦点恢复](../面试/焦点和遥控器面试题.md#tv-嵌套列表怎么做焦点恢复)
- [TV 列表卡顿怎么优化](../面试/TV界面适配面试题.md#tv-列表卡顿怎么优化)
