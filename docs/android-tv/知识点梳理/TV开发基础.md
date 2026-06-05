### Android TV 开发基础知识点清单

###### 内容概述

本文件记录 Android TV 开发基础，包括 TV 端定位、和手机端差异、10-foot UI、输入方式、工程配置、Leanback、Compose for TV、设备适配和开发边界。

###### 使用场景

- 新接手 Android TV 项目时，用于快速建立 TV 端开发基本认知。
- 做手机端应用迁移到 TV 端时，用于判断哪些交互和界面需要重做。
- 做 TV 面试复盘时，用于说明 TV 端和普通 Android App 的核心差异。

一级栏目导航：

- [TV 端开发定位](#tv-端开发定位)
- [TV 和手机端差异](#tv-和手机端差异)
- [10-foot UI](#10-foot-ui)
- [输入方式](#输入方式)
- [常用控件和页面结构](#常用控件和页面结构)
- [页面跳转和数据下发](#页面跳转和数据下发)
- [工程和 Manifest](#工程和-manifest)
- [Leanback 和 Compose for TV](#leanback-和-compose-for-tv)
- [设备适配](#设备适配)
- [开发边界](#开发边界)
- [面试可能怎么问](#面试可能怎么问)

<a id="tv-端开发定位"></a>
###### TV 端开发定位

- Android TV 本质上仍然是 Android，但交互模型和手机完全不同。手机端以触摸为主，TV 端以遥控器、焦点和大屏观看为主。
- TV 用户通常离屏幕更远，界面要让用户在沙发距离也能看清当前焦点、内容层级和操作入口。
- TV 应用常见类型包括视频播放、直播、教育、游戏、家庭场景工具、投屏入口、会员/订阅类应用。
- TV 端最核心的体验问题通常不是页面能不能显示，而是用户能不能用遥控器稳定、可预期地操作。
- TV 项目的技术重点一般集中在：焦点、遥控器、列表、性能、播放、适配、发布和设备兼容。

<a id="tv-和手机端差异"></a>
###### TV 和手机端差异

| 维度 | 手机端 | TV 端 |
|---|---|---|
| 输入方式 | 触摸、手势、软键盘 | 遥控器 D-pad、确认键、返回键、语音输入 |
| 操作目标 | 手指直接点击控件 | 焦点移动到控件后再确认 |
| 屏幕距离 | 近距离 | 远距离 |
| 布局方向 | 竖屏为主 | 横屏为主 |
| 页面密度 | 信息可以更密 | 信息要更清晰，焦点态要明显 |
| 滚动方式 | 手势惯性滚动 | 按键逐项移动或分页移动 |
| 常见风险 | 触摸区域、适配、键盘遮挡 | 焦点丢失、焦点错乱、按键无响应、列表卡顿 |

- TV 端不能直接照搬手机 UI。手机上的小按钮、顶部 Tab、底部导航、复杂手势，在 TV 上可能很难操作。
- TV 上所有可操作控件都要考虑焦点态。没有焦点态，用户不知道当前操作对象。
- TV 上页面层级不宜过深。遥控器输入效率低，路径太深会让用户很难返回和定位。
- TV 上输入成本很高。搜索、登录、表单类场景要尽量减少输入量，支持扫码、手机端联动或语音输入会更友好。

<a id="10-foot-ui"></a>
###### 10-foot UI

- 10-foot UI 指用户大约在 10 英尺距离外使用的界面，Android TV 是典型场景。
- 10-foot UI 的核心要求是：看得清、焦点明确、路径简单、反馈及时。
- 字体不能太小。标题、卡片名、按钮文案要保证远距离可读。
- 控件间距要比手机端更大，避免焦点态挤在一起，也方便用户理解当前选择。
- 焦点态要明显，通常可以用放大、描边、阴影、亮度、边框、背景色变化等方式表达。
- 页面应优先展示内容本身，操作入口要少而明确。TV 用户通常更想快速消费内容，而不是处理复杂设置。
- 首屏要有明确默认焦点，用户进入页面后按确认键应该能产生合理结果。

<a id="输入方式"></a>
###### 输入方式

- TV 端主要按键包括：方向键上、下、左、右，确认键，返回键，菜单键，播放暂停键，快进快退键，音量键。
- Android 中遥控器按键通常会通过 `KeyEvent` 分发，例如 `KEYCODE_DPAD_UP`、`KEYCODE_DPAD_DOWN`、`KEYCODE_DPAD_LEFT`、`KEYCODE_DPAD_RIGHT`、`KEYCODE_DPAD_CENTER`、`KEYCODE_ENTER`、`KEYCODE_BACK`。
- 方向键默认会触发焦点搜索。系统会根据当前焦点 View、方向和候选 View 的位置寻找下一个焦点。
- 确认键一般用于触发当前焦点控件的点击行为。很多设备上 `DPAD_CENTER` 和 `ENTER` 都可能表示确认，需要同时考虑。
- 返回键要保持可预期。弹窗、播放器控制层、详情页、首页退出等场景要明确返回优先级。
- 长按、双击、组合键等高级交互要慎用，因为不同遥控器和设备厂商处理不完全一致。

<a id="常用控件和页面结构"></a>
###### 常用控件和页面结构

TV 端控件选择的核心不是“能不能显示”，而是“能不能被遥控器稳定聚焦和触发”。同一个页面可以继续使用 Android View 体系，但每个可操作控件都要明确焦点态、点击行为和方向路径。

| 控件 / 组件                                   | 常见用途           | 编程重点                                                                    |
| ----------------------------------------- | -------------- | ----------------------------------------------------------------------- |
| `TextView`                                | 标题、标签、Tab、按钮文案 | 作为按钮使用时要设置 `focusable`、`clickable` 和焦点背景                                |
| `Button` / `MaterialButton`               | 确认、取消、重试、登录    | TV 上要有明显焦点态，不要只依赖触摸 ripple                                              |
| `ImageView`                               | 海报、图标、背景图      | 图片尺寸固定，焦点态通常放在外层容器                                                      |
| `FrameLayout` / `ConstraintLayout`        | 卡片根布局、浮层容器     | 常作为 item 的可聚焦根节点                                                        |
| `RecyclerView`                            | 首页、频道页、搜索结果、选集 | item 身份稳定、焦点恢复、滚动到可见                                                    |
| `HorizontalGridView` / `VerticalGridView` | Leanback 列表    | TV 焦点支持更完整，适合传统 Leanback 项目，相对于recycleview更加焦点支持比如焦点滑动类型，滑动距离，item展示方向等 |
| `PlayerView`                              | 播放页            | 视频根容器和控制层焦点要分层管理                                                        |
| `DialogFragment`                          | 确认框、筛选、清晰度面板   | 显示后下发弹窗焦点，关闭后恢复来源焦点                                                     |

RecyclerView和HorizontalGridView / VerticalGridView的区别：
**RecyclerView 是“列表控件”，HorizontalGridView / VerticalGridView 是“带 TV 焦点策略的列表控件”。**
- RecyclerView 默认不懂 TV 焦点体验，默认只是依赖 Android 系统的 FocusFinder 去找下一个可聚焦 View，所以存在问题，系统找最近的view，会导致焦点可能丢失或者跑偏。
- HorizontalGridView / VerticalGridView 更主动去管理焦点和滚动策略，比如焦点移动后根据position去计算目标适合滚动的目标，算出来后再让目标获取焦点
- 焦点滚动对其不同，recycleview是只要view显示就直接移动焦点，HorizontalGridView / VerticalGridView会移动焦点并且列表计算滚动距离，并且有不同的焦点滚动策略去处理
- 嵌套列表焦点表现不同
- 焦点恢复不同，比如焦点 item 被移出屏幕、数据刷新、页面切换，recycleview焦点需要新增代码维护，HorizontalGridView / VerticalGridView不用
- 方向目标不可见 recycleview焦点可能跳到外面去，HorizontalGridView / VerticalGridView会等待item可见后再聚焦
- recycleview适合处理一些比较复杂的列表页面自己去定义焦点走向，HorizontalGridView / VerticalGridView 适合稍微正常普通点的列表
- android:descendantFocusability属性设置
	beforeDescendants：父优先
	afterDescendants：子优先，父兜底
	blocksDescendants：只要父，不要子


一个内容卡片通常让卡片根布局获得焦点，而不是让图片、标题、角标都分别获得焦点：

```xml
<FrameLayout
    android:id="@+id/cardRoot"
    android:layout_width="180dp"
    android:layout_height="260dp"
    android:clickable="true"
    android:focusable="true"
    android:foreground="@drawable/bg_tv_card_focus">

    <ImageView
        android:id="@+id/poster"
        android:layout_width="match_parent"
        android:layout_height="220dp"
        android:scaleType="centerCrop" />

    <TextView
        android:id="@+id/title"
        android:layout_width="match_parent"
        android:layout_height="40dp"
        android:layout_gravity="bottom"
        android:gravity="center_vertical"
        android:singleLine="true" />
</FrameLayout>
```

ViewHolder 里绑定焦点态和点击：

```kotlin
class ContentViewHolder(
    itemView: View,
    private val onClick: (Content) -> Unit,
    private val onFocus: (Content) -> Unit
) : RecyclerView.ViewHolder(itemView) {

    private val title = itemView.findViewById<TextView>(R.id.title)

    fun bind(item: Content) {
        title.text = item.title

        itemView.setOnClickListener {
            onClick(item)
        }

        itemView.setOnFocusChangeListener { view, hasFocus ->
            view.animate()
                .scaleX(if (hasFocus) 1.08f else 1f)
                .scaleY(if (hasFocus) 1.08f else 1f)
                .setDuration(120L)
                .start()

            if (hasFocus) {
                onFocus(item)
            }
        }
    }
}
```

Compose for TV 中也要显式处理焦点和按键。常见写法是给卡片绑定 `focusRequester`、`onFocusChanged` 和 `onKeyEvent`：

```kotlin
@Composable
fun TvContentCard(
    item: Content,
    modifier: Modifier = Modifier,
    onClick: (Content) -> Unit
) {
    var focused by remember { mutableStateOf(false) }

    Box(
        modifier = modifier
            .size(width = 180.dp, height = 260.dp)
            .focusable()
            .onFocusChanged { focused = it.isFocused }
            .onKeyEvent { event ->
                if (event.type == KeyEventType.KeyUp &&
                    (event.key == Key.DirectionCenter || event.key == Key.Enter)
                ) {
                    onClick(item)
                    true
                } else {
                    false
                }
            }
            .graphicsLayer {
                scaleX = if (focused) 1.08f else 1f
                scaleY = if (focused) 1.08f else 1f
            }
    ) {
        // poster + title
    }
}
```

控件设计上可以按下面的粒度拆分：

- 内容卡片：根布局聚焦，确认键进入详情或播放。
- Tab / 分类：Tab 自己聚焦，确认键切换业务选中态，不要在获得焦点时立即切换。
- 播放控制按钮：按钮聚焦，确认键触发播放、暂停、快进、清晰度等动作。
- 错误页：重试按钮默认聚焦，返回按钮作为次要焦点。
- 空态页：如果只有提示文案，不要让文案聚焦；如果有重试或返回，聚焦可操作按钮。

<a id="页面跳转和数据下发"></a>
###### 页面跳转和数据下发

TV 页面跳转和手机端一样可以用 Activity、Fragment、Navigation 或 Router，但要额外保存“从哪个焦点进入”和“返回后恢复到哪里”。数据下发建议传稳定业务 id，不建议只传 adapter position。

从列表进入详情时，至少保存内容 id 和所在栏目 id：

```kotlin
data class TvFocusAnchor(
    val rowId: String,
    val contentId: String,
    val rowPosition: Int,
    val itemPosition: Int
)

class HomeViewModel : ViewModel() {
    var lastFocusAnchor: TvFocusAnchor? = null
        private set

    fun onCardFocused(row: RowUiModel, item: Content, rowPos: Int, itemPos: Int) {
        lastFocusAnchor = TvFocusAnchor(
            rowId = row.id,
            contentId = item.id,
            rowPosition = rowPos,
            itemPosition = itemPos
        )
    }
}
```

跳转详情时传内容 id，而不是把整个大对象塞进 Intent：

```kotlin
fun openDetail(context: Context, item: Content) {
    val intent = Intent(context, DetailActivity::class.java)
        .putExtra("content_id", item.id)
    context.startActivity(intent)
}
```

Fragment Navigation 可以用 arguments 或 Safe Args，原则一样：传稳定 id，详情页自己拉取或从共享仓库读取详情数据。

```kotlin
findNavController().navigate(
    R.id.action_home_to_detail,
    bundleOf("content_id" to item.id)
)
```

返回列表页时的恢复顺序：

1. 恢复页面数据。
2. 用 `rowId/contentId` 找到新的 position。
3. 先滚动外层行，再滚动内层列表。
4. 等目标 item attach 或布局完成。
5. 调用 `requestFocus()`。

不要在 `onResume()` 里无条件恢复焦点。只有从详情、弹窗、登录页等明确场景返回时才恢复，否则用户在当前页移动焦点会被抢回去。

<a id="工程和-manifest"></a>
###### 工程和 Manifest

- TV 应用需要明确声明 TV 入口和相关特性。常见配置包括 TV Launcher 入口、横屏、banner 图、Leanback 特性等。
- TV Launcher 通常需要能在电视桌面展示应用入口，应用图标、banner、名称要适合大屏。
- 如果应用只面向 TV，应避免依赖触摸屏能力。触摸屏是手机/平板常见能力，但 TV 设备通常没有触摸屏。
- 如果应用同时支持手机和 TV，要明确区分资源、布局、导航和交互，不要让 TV 端走手机端触摸逻辑。
- `minSdk`、Java 版本、媒体库版本、desugaring、ABI、屏幕资源目录都要结合项目目标设备决定。
- 发布到应用市场或 Google Play TV 时，清单、截图、banner、遥控器可操作性、无触摸依赖等要求需要按最新官方规则核对。

<a id="leanback-和-compose-for-tv"></a>
###### Leanback 和 Compose for TV

- Leanback 是 Android TV 传统开发中常见的 UI 支持库，提供 Browse、Details、Rows、Cards 等面向 TV 的页面结构。
- Leanback 适合维护老项目或快速搭建传统 TV 视频类界面，但自定义复杂交互时需要理解它的焦点和 Presenter 机制。
- Compose for TV 是面向 TV 的 Compose 组件体系，适合新项目或已经采用 Compose 技术栈的团队。
- Compose for TV 里也要关注焦点管理、焦点恢复、遥控器按键和大屏布局，不是用了 Compose 就自动解决 TV 交互问题。
- 如果项目已经是 View 体系，短期内可以先用 View / RecyclerView / Leanback 稳定交付；如果项目要长期演进，可以评估 Compose for TV。
- 技术选型要结合团队经验、项目生命周期、性能要求、已有组件、测试能力和设备覆盖范围。

<a id="设备适配"></a>
###### 设备适配

- Android TV 设备形态包括电视、机顶盒、投影、车载大屏、定制系统盒子等，不同厂商系统差异可能很大。
- 常见适配问题包括：按键码差异、系统返回行为差异、播放器硬解能力差异、分辨率和缩放差异、内存限制、低端 CPU/GPU 性能不足。
- 真实设备测试很重要。模拟器可以覆盖基本流程，但焦点、遥控器、播放、性能和厂商 ROM 问题通常要真机验证。
- TV 端网络环境可能不稳定，视频类应用要关注弱网、断网重连、清晰度切换、缓存和错误提示。
- TV 端页面生命周期要结合播放状态、后台恢复、屏保、系统休眠、遥控器 Home 键等场景一起验证。

<a id="开发边界"></a>
###### 开发边界

- 不要把 TV 当成“大号手机”。TV 端要先设计焦点路径，再实现 UI。
- 不要让用户必须触摸、拖拽、长按或多指操作。
- 不要把过多小操作入口塞进页面。入口越多，焦点路径越难控制。
- 不要只在鼠标或键盘环境测试。必须用遥控器方向键完整走通。
- 不要只看页面静态截图。TV 端更要看焦点移动、按键响应、列表滚动和返回路径。
- 不确定的发布规则、上架规范、设备认证要求要按官方文档和目标市场最新要求核对。

<a id="面试可能怎么问"></a>
###### 面试可能怎么问

- [Android TV 和手机 App 开发有什么区别](../面试/TV开发基础面试题.md#android-tv-和手机-app-开发有什么区别)
- [什么是 10-foot UI](../面试/TV开发基础面试题.md#什么是-10-foot-ui)
- [TV 应用为什么要重点关注焦点](../面试/TV开发基础面试题.md#tv-应用为什么要重点关注焦点)
- [Leanback 和 Compose for TV 怎么选](../面试/TV开发基础面试题.md#leanback-和-compose-for-tv-怎么选)
- [TV 应用 Manifest 和发布要注意什么](../面试/TV开发基础面试题.md#tv-应用-manifest-和发布要注意什么)
