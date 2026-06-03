### Lambda / Stream / Optional 面试题

###### 内容概述

这里记录 Java Lambda、函数式接口、方法引用、Stream、Optional 相关面试题，用来复盘 Java 8 现代语法、流式处理、空值表达以及 Android 项目中的使用边界。

面试题导航：

- [Lambda 表达式解决了什么问题](#lambda-表达式解决了什么问题)
- [Lambda 和匿名内部类有什么区别](#lambda-和匿名内部类有什么区别)
- [什么是函数式接口](#什么是函数式接口)
- [方法引用是什么](#方法引用是什么)
- [Stream 和集合遍历有什么区别](#stream-和集合遍历有什么区别)
- [Stream 的中间操作和终止操作有什么区别](#stream-的中间操作和终止操作有什么区别)
- [map 和 flatMap 有什么区别](#map-和-flatmap-有什么区别)
- [forEach 和 peek 有什么区别](#foreach-和-peek-有什么区别)
- [findFirst 和 findAny 有什么区别](#findfirst-和-findany-有什么区别)
- [parallelStream 为什么在 Android 中慎用](#parallelstream-为什么在-android-中慎用)
- [Optional 解决了什么问题](#optional-解决了什么问题)
- [orElse 和 orElseGet 有什么区别](#orelse-和-orelseget-有什么区别)
- [Optional 能不能完全替代 null](#optional-能不能完全替代-null)
- [Android 低版本使用 Stream 和 Optional 要注意什么](#android-低版本使用-stream-和-optional-要注意什么)

###### Lambda 表达式解决了什么问题

答案：

**简答：** Lambda 主要解决匿名内部类样板代码过多的问题，让“把行为作为参数传递”更简洁。

**展开回答：** 在 Java 8 之前，点击监听、回调、排序规则等场景经常要写匿名内部类。Lambda 可以把只有一个抽象方法的接口实现简化成 `(参数) -> 表达式` 或 `(参数) -> { 代码块 }`，代码更关注行为本身。

**易错点：** Lambda 不是独立类型，它必须匹配一个函数式接口。没有目标类型时，编译器不知道 Lambda 要转换成什么。

**关联知识点：** [Lambda 基础](../知识点梳理/Lambda-Stream-Optional.md#lambda-基础)

###### Lambda 和匿名内部类有什么区别

答案：

**简答：** Lambda 更像函数式接口的一段行为实现，匿名内部类是创建一个匿名对象。

**展开回答：** 匿名内部类可以实现包含多个方法的接口或继承类，内部的 `this` 指向匿名内部类对象。Lambda 只能用于函数式接口，Lambda 内部的 `this` 指向外层对象。Lambda 语法更轻量，但不适合表达复杂对象状态和多个重写方法。

**易错点：** 不要把 Lambda 简单理解成匿名内部类的纯语法糖。编译和运行实现细节可能不同，尤其在不同 JDK、Android desugaring 和是否捕获变量时会有差异。

**关联知识点：** [Lambda 基础](../知识点梳理/Lambda-Stream-Optional.md#lambda-基础)

###### 什么是函数式接口

答案：

**简答：** 函数式接口是只有一个抽象方法的接口，Lambda 必须匹配函数式接口。

**展开回答：** `Runnable`、`Callable`、`Comparator`、`Function`、`Consumer`、`Supplier`、`Predicate` 都是常见函数式接口。`@FunctionalInterface` 不是必须的，但推荐加上，因为它能让编译器检查接口是否满足函数式接口要求。

**易错点：** 函数式接口可以有默认方法和静态方法，只要抽象方法只有一个即可。

**关联知识点：** [函数式接口](../知识点梳理/Lambda-Stream-Optional.md#函数式接口)

###### 方法引用是什么

答案：

**简答：** 方法引用是 Lambda 的简写形式，用来引用已有方法或构造方法。

**展开回答：** 如果 Lambda 只是简单调用一个已有方法，就可以用方法引用，例如 `value -> value.trim()` 可以写成 `String::trim`，`value -> System.out.println(value)` 可以写成 `System.out::println`。方法引用常见形式包括静态方法引用、指定对象实例方法引用、某类对象实例方法引用和构造方法引用。

**易错点：** 方法引用必须能匹配目标函数式接口的参数和返回值。复杂逻辑强行改成方法引用，反而会降低可读性。

**关联知识点：** [方法引用](../知识点梳理/Lambda-Stream-Optional.md#方法引用)

###### Stream 和集合遍历有什么区别

答案：

**简答：** 集合关注数据存储，Stream 关注数据处理流程。

**展开回答：** 普通 `for` 循环是命令式写法，强调一步步怎么做；Stream 是声明式写法，强调过滤、转换、聚合等处理意图。Stream 本身不存储数据，数据来自集合、数组等数据源。它适合表达过滤、映射、分组、统计等链式处理。

**易错点：** Stream 不一定比 `for` 循环更快。小数据量、简单逻辑、UI 热路径里，普通循环可能更直接也更容易调试。

**关联知识点：** [Stream 基础](../知识点梳理/Lambda-Stream-Optional.md#stream-基础)

###### Stream 的中间操作和终止操作有什么区别

答案：

**简答：** 中间操作返回新的 Stream，通常是惰性的；终止操作会触发执行并返回最终结果或副作用。

**展开回答：** `filter`、`map`、`sorted`、`distinct`、`limit` 是中间操作，单独调用不会马上处理数据。`collect`、`forEach`、`count`、`reduce`、`findFirst`、`anyMatch` 是终止操作，会触发前面的整个管道执行。

**易错点：** Stream 执行终止操作后不能复用，同一个 Stream 再执行第二个终止操作会报错。

**关联知识点：** [Stream 基础](../知识点梳理/Lambda-Stream-Optional.md#stream-基础)

###### map 和 flatMap 有什么区别

答案：

**简答：** `map` 是一对一转换，`flatMap` 是一对多转换后再展平。

**展开回答：** `map(User::getName)` 会把 `User` 转成 `String`。`flatMap(article -> article.getTags().stream())` 会把每篇文章的 tag 列表展开成一个整体 tag 流。需要把嵌套集合、嵌套 Optional 展开时，通常会用 `flatMap`。

**易错点：** 如果转换函数返回的是集合或 Stream，再用 `map` 可能得到 `Stream<List<T>>` 或 `Stream<Stream<T>>`；想要一层元素时应考虑 `flatMap`。

**关联知识点：** [Stream 常用操作](../知识点梳理/Lambda-Stream-Optional.md#stream-常用操作)

###### forEach 和 peek 有什么区别

答案：

**简答：** `forEach` 是终止操作，`peek` 是中间操作。

**展开回答：** `forEach` 会消费 Stream 并执行动作，通常用于最终遍历。`peek` 会返回 Stream，设计上主要用于观察流经元素，比如调试日志，不建议在里面写修改外部状态、更新 UI 等业务副作用。

**易错点：** 没有终止操作时，`peek` 不会执行。把业务逻辑藏在 `peek` 中很容易造成“为什么代码没跑”的误解。

**关联知识点：** [Stream 常用操作](../知识点梳理/Lambda-Stream-Optional.md#stream-常用操作)

###### findFirst 和 findAny 有什么区别

答案：

**简答：** `findFirst` 返回第一个元素，强调顺序；`findAny` 返回任意一个元素，强调可以更自由地优化。

**展开回答：** 在顺序流中，二者经常表现相同；在并行流中，`findAny` 不要求返回遇到顺序的第一个元素，可能更容易获得性能优化。需要顺序语义时用 `findFirst`，不关心顺序时可以用 `findAny`。

**易错点：** 如果业务上依赖“第一个匹配项”，不要为了看起来更快而改成 `findAny`。

**关联知识点：** [Stream 常用操作](../知识点梳理/Lambda-Stream-Optional.md#stream-常用操作)

###### parallelStream 为什么在 Android 中慎用

答案：

**简答：** 因为 Android 业务数据量通常不大，线程调度成本和公共线程池不可控可能抵消收益，还容易引入线程安全和 UI 线程问题。

**展开回答：** `parallelStream()` 会把任务拆到多个线程执行，适合大数据量、计算密集、无共享状态的场景。Android 中很多操作数据量不大，还经常涉及生命周期、UI 线程、数据库、网络和共享状态，盲目并行可能导致调度开销、竞争问题或难以定位的 bug。

**易错点：** 并行不等于更快。并行流里不要更新 UI，也不要修改非线程安全集合或共享变量。

**关联知识点：** [Android 使用场景和注意点](../知识点梳理/Lambda-Stream-Optional.md#android-使用场景和注意点)

###### Optional 解决了什么问题

答案：

**简答：** Optional 用 API 形式表达“结果可能不存在”，减少调用方忘记处理 null 的概率。

**展开回答：** 方法返回 `Optional<User>` 时，调用方能从类型上看到结果可能为空，并通过 `map`、`orElse`、`orElseGet`、`orElseThrow` 等方法处理缺失情况。它更适合作为返回值，而不是随处替代字段、参数和集合元素。

**易错点：** Optional 不能自动防止空指针。`Optional.of(null)` 会抛异常，`Optional.get()` 在为空时也会抛异常。

**关联知识点：** [Optional 基础](../知识点梳理/Lambda-Stream-Optional.md#optional-基础)

###### orElse 和 orElseGet 有什么区别

答案：

**简答：** `orElse` 的默认值会提前计算，`orElseGet` 只有在 Optional 为空时才会调用 supplier。

**展开回答：** 如果默认值只是常量，`orElse("unknown")` 没问题。如果默认值需要创建对象、查数据库、打日志或调用接口，应该用 `orElseGet(() -> createDefault())`，避免 Optional 已经有值时仍然执行默认值逻辑。

**易错点：** 默认值表达式有副作用时，误用 `orElse` 可能导致额外调用。

**关联知识点：** [Optional 基础](../知识点梳理/Lambda-Stream-Optional.md#optional-基础)

###### Optional 能不能完全替代 null

答案：

**简答：** 不能。Optional 更适合表达方法返回值可能为空，不适合在所有地方替代 null。

**展开回答：** Optional 用在返回值上能提醒调用方处理缺失情况。但如果把字段、方法参数、数据库实体、序列化模型都改成 Optional，可能增加框架兼容、序列化、反射和可读性成本。集合返回值通常也不需要 `Optional<List<T>>`，直接返回空集合更清晰。

**易错点：** Optional 本身也可能被错误地赋值为 null，所以团队仍然需要统一空值规范。

**关联知识点：** [Optional 基础](../知识点梳理/Lambda-Stream-Optional.md#optional-基础)

###### Android 低版本使用 Stream 和 Optional 要注意什么

答案：

**简答：** 要确认 Java 版本、D8/R8 desugaring 和 core library desugaring 配置。

**展开回答：** Lambda 语法通常可以通过 desugaring 支持较低 Android 版本，但 `java.util.stream`、`java.util.Optional` 等 Java 标准库 API 在低版本设备上可能需要 core library desugaring。否则可能出现编译或运行时兼容问题。

**易错点：** 语法能编译不代表所有 Java 8 标准库 API 都能在目标设备上直接运行。项目需要按 AGP 和 minSdk 配置确认支持范围。

**关联知识点：** [Android 使用场景和注意点](../知识点梳理/Lambda-Stream-Optional.md#android-使用场景和注意点)
