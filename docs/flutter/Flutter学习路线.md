### Flutter 学习路线

<!-- page-toc:start -->
**目录**

- [学习目标与阅读顺序](#overview)
- [分阶段学习内容](#stages)
- [Dart 优先学习顺序](#dart-order)
- [用同一个收藏小项目串起知识](#project)
- [Android 经验可以迁移什么，不能直接等同什么](#android-map)
- [后续待展开主题](#pending)
<!-- page-toc:end -->


<a id="overview"></a>
###### 学习目标与阅读顺序

目标是从 Android/Kotlin 开发经验出发，逐步具备用 Flutter 独立完成列表、详情、收藏、接口加载、状态管理和原生交互的能力。先学 Dart，再学 Flutter 的布局与状态模型；会写语法并不等于理解 Widget 生命周期。

本轮先展开 [Dart 基础详解](./Dart基础详解.md)。下面是学习顺序和可观察的阶段目标，不代表已经学习或掌握，也不自动更新全库学习进度。

<a id="stages"></a>
###### 分阶段学习内容

| 阶段 | 核心内容 | 为什么先学这些 | 可以完成什么 |
|---|---|---|---|
| 1：Dart 基础 | 类型、变量、空安全、函数、集合、控制流 | Flutter 构造 Widget、回调与转换数据都用这些语法 | 看懂命名参数和回调，独立处理列表数据 |
| 2：Dart 建模与异步 | 类、构造、接口、泛型、JSON、Future、Stream、Isolate | 网络数据、仓库和页面状态需要这部分 | 写一个可运行的收藏数据仓库，处理成功与失败 |
| 3：环境与最小应用 | Flutter SDK、doctor、设备运行、pubspec、热重载/热重启 | 能排查环境问题，而不是直接抄完整项目 | 在设备或模拟器运行应用，解释热重载保留状态的含义 |
| 4：Widget 与布局 | Widget/Element/RenderObject 入门、约束、Row/Column、Flex、Stack、滚动、图片和资源 | 布局靠约束传递，不能直接照搬 Android XML 思维 | 完成适应不同屏幕的列表与详情；解释溢出、无界约束 |
| 5：状态与生命周期 | StatelessWidget、StatefulWidget、State、setState、Key、initState、didUpdateWidget、dispose、mounted | 重建 UI、保留状态和释放订阅是常见难点 | 收藏按钮正确更新，切换列表后状态不串位，页面退出后停止监听 |
| 6：交互与路由 | 手势、文本输入、表单校验、焦点、Navigator、参数和返回值、深链 | 完成真实页面间交互 | 列表进入详情并带回结果；处理返回栈 |
| 7：数据与状态管理 | HTTP、JSON、错误映射、Repository、缓存、依赖注入；先理解本地状态，再选择 Provider/Riverpod 等 | 先明确谁拥有数据和生命周期，再选库 | 列表与详情共享收藏状态，覆盖 loading/empty/error/data |
| 8：持久化与平台能力 | 键值存储/数据库、权限、Platform Channel、插件、Android 生命周期 | 应用内存不能代替持久化；跨平台仍需处理平台差异 | 重启后收藏仍存在，完成一个 Android 原生能力调用 |
| 9：质量与交付 | 单元/Widget/集成测试、DevTools、性能分析、构建模式、签名、发布 | debug 的速度不等于 release 性能 | 验证业务行为，定位一次重建或卡顿问题，产出可安装包 |
| 10：进阶专项 | 动画、自定义绘制、渲染流程、复杂滚动、无障碍、国际化、混合开发 | 基础页面熟悉后按需求深入 | 能解释实际业务中的一个性能或架构问题 |

资料入口：[Flutter 学习入口](https://docs.flutter.dev/learn)、[官方学习路径](https://docs.flutter.dev/learn/pathway)、[Android 开发者迁移指南](https://docs.flutter.dev/get-started/flutter-for/android-devs)。路线按问题组织，不依赖某个状态管理库版本。

<a id="dart-order"></a>
###### Dart 优先学习顺序

1. 阅读 [运行与类型](./Dart基础详解.md#start)，运行自己的 main。
2. 理解 [final/const/late](./Dart基础详解.md#variables) 和 [空安全](./Dart基础详解.md#null-safety)，先减少强制断言。
3. 掌握 [函数与回调](./Dart基础详解.md#functions)、[集合](./Dart基础详解.md#collections)，能看懂 Flutter 的参数和 children 写法。
4. 学 [类与构造](./Dart基础详解.md#classes)、[继承与接口](./Dart基础详解.md#interfaces)、[泛型](./Dart基础详解.md#generics)，能定义数据与仓库边界。
5. 学 [Future 的执行顺序](./Dart基础详解.md#future)、[Stream](./Dart基础详解.md#stream)、[Isolate](./Dart基础详解.md#isolate)，区分异步等待与 CPU 并行。
6. 跟完 [收藏列表综合例子](./Dart基础详解.md#example)，再开始 Flutter 页面。

Records、模式匹配和类修饰符先能读懂即可；初学不需要先研究编译器状态机、框架源码或全部第三方状态库。

<a id="project"></a>
###### 用同一个收藏小项目串起知识

| 迭代 | 增加的功能 | 需要明确的设计问题 |
|---|---|---|
| Dart 控制台 | 模拟加载文章、筛选收藏、更新模型 | 数据类型、不可变模型、异步错误怎么表达 |
| Flutter 单页 | 列表展示与收藏按钮 | 谁持有状态，哪个操作触发重建 |
| 列表与详情 | 共享收藏数据 | 页面局部状态与共享业务数据怎样分开 |
| 接口和本地存储 | 加载失败、刷新、重启恢复 | 内存、数据库、服务端谁是数据来源，失败怎样处理 |
| 原生能力和交付 | Android 通道、权限、测试、安装包 | 生命周期和平台边界在哪里 |

不要一开始同时接入多个状态框架、代码生成、数据库和复杂路由；每次加一项能力，再解释它解决的问题。Repository 是否共享取决于数据生命周期；依赖注入本身不等于单例。详情页销毁，也不意味着应用级收藏应该丢失。

<a id="android-map"></a>
###### Android 经验可以迁移什么，不能直接等同什么

| 熟悉的概念 | Flutter/Dart 中的对应学习点 | 需要重新理解的部分 |
|---|---|---|
| Kotlin 数据类 | Dart 普通类、不可变模型、Record、代码生成 | 普通 Dart 类不会自动生成值相等和 copyWith |
| 协程等待结果 | Future、async/await | 不自动获得 Kotlin Job 树和结构化取消 |
| Flow/事件订阅 | Stream、StreamSubscription | 单订阅/广播语义不同，不能直接套 StateFlow 的当前值语义 |
| View 布局 | Widget 与约束布局 | Widget 是配置描述，不等于持久存在的 Android View 对象 |
| Activity/Fragment 生命周期 | State 生命周期和应用生命周期 | 页面 State 与应用前后台是不同维度 |
| ViewModel/Repository | UI 状态持有者与数据层 | 先设计所有权和生命周期，再选择框架；没有一一对应的强制类名 |

<a id="pending"></a>
###### 后续待展开主题

当前已生成 Dart 基础正文。后续优先补充 Widget 与布局、State 生命周期与 Key，再用收藏项目展开共享状态与 Repository。路由、持久化、平台通道、测试和发布按路线继续；这里不为未展开的主题批量创建空文档。
