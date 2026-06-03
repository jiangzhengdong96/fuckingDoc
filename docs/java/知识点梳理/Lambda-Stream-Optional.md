### Java Lambda / Stream / Optional 知识点清单

###### 内容概述

本文件记录 Java 8 常用现代语法和 API，包括 Lambda 表达式、函数式接口、方法引用、Stream 流式处理、Optional 空值表达方式、Android 使用场景和关联面试题。

###### 使用场景

- Lambda 常用于点击监听、回调、排序规则、集合遍历、异步任务结果处理等场景，用来减少匿名内部类样板代码。
- Stream 适合对集合数据做过滤、转换、分组、聚合和查找，让“数据怎么处理”的表达更清晰。
- Optional 适合表达“这个方法可能没有结果”，减少调用方遗漏空值判断的概率。
- Android 项目中使用 Lambda、Stream、Optional 要注意最低 API、desugaring、可读性和性能，不要为了语法新而牺牲简单直接的代码。

一级栏目导航：

- [Lambda 基础](#lambda-基础)
- [函数式接口](#函数式接口)
- [方法引用](#方法引用)
- [Stream 基础](#stream-基础)
- [Stream 常用操作](#stream-常用操作)
- [Optional 基础](#optional-基础)
- [Android 使用场景和注意点](#android-使用场景和注意点)
- [常见坑](#常见坑)
- [面试可能怎么问](#面试可能怎么问)

###### Lambda 基础

- Lambda 表达式可以理解为“把一段行为当作参数传递”。它主要用于替代只有一个抽象方法的接口实现，例如点击监听、排序规则、回调处理。
- 传统匿名内部类写法：

```java
button.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        submit();
    }
});
```

- Lambda 写法：

```java
button.setOnClickListener(v -> submit());
```

- Lambda 的基本形式：

```java
(参数列表) -> { 方法体 }
```

- 如果只有一个参数，参数括号可以省略：`value -> value.length()`。
- 如果方法体只有一行表达式，可以省略 `{}` 和 `return`：`a -> a + 1`。
- 如果方法体有多行，必须使用 `{}`，需要返回值时显式写 `return`。
- Lambda 的参数类型通常可以由编译器根据目标类型推断出来，所以多数情况下不用手写参数类型。
- Lambda 必须依附于一个目标类型，目标类型通常是函数式接口。单独写一个 Lambda 没有意义，编译器需要知道它要转换成哪个接口。
- Lambda 可以访问外部局部变量，但这个变量必须是 final 或 effectively final，也就是赋值后不能再修改。

```java
String prefix = "user:";
list.forEach(item -> System.out.println(prefix + item));
```

- Lambda 和匿名内部类都能表达回调，但 Lambda 更强调“行为”，匿名内部类更强调“对象”。如果需要定义多个方法、保存复杂状态或重写 `equals()` 等对象行为，匿名内部类仍然更合适。

###### 函数式接口

- 函数式接口是只包含一个抽象方法的接口，Lambda 最终会被转换成这种接口的实例。
- `@FunctionalInterface` 注解不是必须的，但推荐加上。它可以让编译器检查这个接口是否真的只有一个抽象方法。

```java
@FunctionalInterface
public interface Mapper<T, R> {
    R map(T value);
}
```

- 函数式接口可以有默认方法和静态方法，只要抽象方法只有一个即可。
- 常见函数式接口：

| 接口 | 作用 |
|---|---|
| `Runnable` | 无参数、无返回值任务 |
| `Callable<V>` | 无参数、有返回值任务，可以抛异常 |
| `Comparator<T>` | 比较两个对象，用于排序 |
| `Consumer<T>` | 消费一个参数，无返回值 |
| `Supplier<T>` | 不接收参数，提供一个返回值 |
| `Function<T, R>` | 接收一个参数，返回一个结果 |
| `Predicate<T>` | 接收一个参数，返回 boolean |
| `BiFunction<T, U, R>` | 接收两个参数，返回一个结果 |

- Android 开发里，点击监听、文本变化监听、异步回调、数据转换器、DiffUtil 比较器等都可以用函数式接口理解。
- 如果项目里自己定义回调接口，并且这个接口只有一个回调方法，可以考虑加 `@FunctionalInterface`，让调用方能用 Lambda 简化代码。
- 函数式接口的命名要表达清楚语义。不要为了能用 Lambda，把本来包含多个职责的接口强行拆成难懂的小接口。

###### 方法引用

- 方法引用是 Lambda 的简写形式，适合 Lambda 只是简单调用一个已有方法的场景。
- 方法引用不是新的执行机制，本质上仍然要匹配一个函数式接口。
- 常见形式：

| 形式 | 示例 | 含义 |
|---|---|---|
| 静态方法引用 | `Integer::parseInt` | 调用某个类的静态方法 |
| 指定对象的实例方法引用 | `logger::log` | 调用某个已有对象的方法 |
| 某类对象的实例方法引用 | `String::trim` | 对传入对象调用实例方法 |
| 构造方法引用 | `User::new` | 调用构造方法创建对象 |

- Lambda：

```java
list.stream()
        .map(value -> value.trim())
        .forEach(value -> System.out.println(value));
```

- 方法引用：

```java
list.stream()
        .map(String::trim)
        .forEach(System.out::println);
```

- 方法引用能提升可读性，但前提是读者能一眼看出引用的方法是什么。复杂参数转换、条件判断、多步逻辑不要强行改成方法引用。

###### Stream 基础

- Stream 是对数据处理流程的抽象，不是集合本身，也不会存储数据。
- Stream 关注的是“从数据源开始，经过一系列操作，最后得到结果”。常见数据源包括集合、数组、文件行、生成器等。

```java
List<String> names = users.stream()
        .filter(user -> user.isActive())
        .map(User::getName)
        .collect(Collectors.toList());
```

- Stream 操作分为中间操作和终止操作。
- 中间操作返回新的 Stream，例如 `filter`、`map`、`sorted`、`distinct`，它们通常是惰性的，不会立刻执行。
- 终止操作会触发整个处理流程，例如 `collect`、`forEach`、`count`、`findFirst`、`anyMatch`。
- Stream 只能被消费一次。执行过终止操作后，不能继续复用同一个 Stream。

```java
Stream<String> stream = list.stream();
long count = stream.count();
// stream.forEach(System.out::println); // 错误：Stream 已经被消费
```

- Stream 不会自动修改原集合。大多数操作返回的是处理后的新结果，如果需要保存结果，要用 `collect`、`reduce` 等终止操作。
- Stream 管道里的操作应该尽量保持无副作用。不要在 `map`、`filter` 中修改外部集合、更新 UI 或改变共享状态，否则代码会变得难以推理。
- `parallelStream()` 会把任务拆到多个线程执行，适合数据量大、计算密集、无共享状态的场景。Android 业务代码里通常要慎用，因为线程调度、公共线程池、UI 线程约束和数据量不足都可能让它得不偿失。

###### Stream 常用操作

- `filter`：过滤元素，只保留满足条件的数据。

```java
List<User> activeUsers = users.stream()
        .filter(User::isActive)
        .collect(Collectors.toList());
```

- `map`：把一种元素转换成另一种元素。

```java
List<String> names = users.stream()
        .map(User::getName)
        .collect(Collectors.toList());
```

- `flatMap`：把每个元素转换成一个 Stream，再把多个 Stream 展平成一个 Stream。常用于一对多结构。

```java
List<String> tags = articles.stream()
        .flatMap(article -> article.getTags().stream())
        .collect(Collectors.toList());
```

- `distinct`：去重，依赖元素的 `equals()` 和 `hashCode()`。
- `sorted`：排序，可以使用自然顺序，也可以传入 `Comparator`。
- `limit`：限制最多取多少个元素。
- `skip`：跳过前几个元素。
- `peek`：查看流经元素，主要用于调试，不建议写业务副作用逻辑。
- `forEach`：遍历每个元素，是终止操作。并行流里 `forEach` 不保证顺序，如果要保序可以使用 `forEachOrdered`。
- `collect`：收集结果，常见是转成 `List`、`Set`、`Map`，或者分组、分区、拼接字符串。

```java
Map<Integer, List<User>> groupByAge = users.stream()
        .collect(Collectors.groupingBy(User::getAge));
```

- `reduce`：把多个元素归约成一个结果，例如求和、累乘、拼接。

```java
int total = numbers.stream()
        .reduce(0, Integer::sum);
```

- `count`：统计元素数量。
- `anyMatch`：是否存在任意元素满足条件。
- `allMatch`：是否所有元素都满足条件。
- `noneMatch`：是否没有元素满足条件。
- `findFirst`：返回第一个元素，适合有顺序要求的流。
- `findAny`：返回任意一个元素，并行流里可能更容易优化。
- 基本类型流 `IntStream`、`LongStream`、`DoubleStream` 可以减少装箱拆箱开销，适合数值计算。

###### Optional 基础

- Optional 是一个容器，用来表达“这个值可能存在，也可能不存在”。
- Optional 主要适合作为方法返回值，让调用方意识到结果可能为空。

```java
public Optional<User> findUser(String id) {
    User user = cache.get(id);
    return Optional.ofNullable(user);
}
```

- 常见创建方式：

| 方法 | 作用 |
|---|---|
| `Optional.empty()` | 创建空 Optional |
| `Optional.of(value)` | 创建非空 Optional，value 为 null 会抛 `NullPointerException` |
| `Optional.ofNullable(value)` | value 可以为 null，null 时得到空 Optional |

- 常见使用方式：

```java
String name = findUser(id)
        .map(User::getName)
        .orElse("unknown");
```

- `isPresent()` 可以判断是否有值，但如果只是 `isPresent()` 后再 `get()`，容易写回传统 null 判断风格。
- `ifPresent()` 适合有值时执行动作。
- `map()` 适合把 Optional 内部值转换成另一个值。
- `flatMap()` 适合转换函数本身就返回 Optional 的场景，避免嵌套成 `Optional<Optional<T>>`。
- `orElse(defaultValue)` 会提前计算默认值，即使 Optional 里有值也会先把默认值表达式算出来。
- `orElseGet(supplier)` 是懒加载，只有 Optional 为空时才调用 supplier，默认值创建成本较高时更合适。
- `orElseThrow()` 适合没有值时抛出明确异常。
- `get()` 在 Optional 为空时会抛 `NoSuchElementException`，一般不建议直接使用。
- Optional 不是为了完全消灭 null，而是让“可能为空”在 API 上更明确。字段、参数、集合元素里滥用 Optional 往往会增加复杂度。

###### Android 使用场景和注意点

- Lambda 在 Android 中很常见，点击监听、Adapter 事件、回调传递、排序、集合处理都可以使用。
- Stream 可以用于 ViewModel、Repository、数据转换层等非 UI 热路径代码，让列表过滤和转换更清晰。
- Optional 可以用于 Repository 查询、缓存读取、配置查找等“可能没有结果”的返回值。
- 如果项目需要兼容较低 Android 版本，要确认 Gradle Java 版本、D8/R8 desugaring 和 core library desugaring 配置。Lambda 本身通常可以被 desugar，`java.util.stream`、`java.util.Optional` 等标准库 API 在低版本上可能需要 core library desugaring 支持。
- UI 线程里不要对大集合做复杂 Stream 链式处理，避免卡顿。数据量较大时应放到后台线程、协程、RxJava、Executor 或业务已有异步框架里处理。
- Android 里不建议为了炫技写过长的 Stream 链。超过几步、包含复杂分支或副作用时，普通 `for` 循环可能更清晰。
- `parallelStream()` 通常不适合 Android 日常业务代码。它使用公共线程池，线程调度不可控，也不能直接更新 UI。
- Kotlin 项目里很多场景可以用 Kotlin 的集合操作和空安全替代 Java Stream / Optional，但 Java 代码里仍然需要理解这些 API。

###### 常见坑

- Lambda 捕获的局部变量必须是 final 或 effectively final，不能在 Lambda 内修改外部局部变量。
- Lambda 不是“没有对象成本”。具体成本和编译器、运行环境、捕获变量情况有关，不要简单认为它一定比匿名内部类更快。
- 函数式接口只能有一个抽象方法。接口继承、默认方法、`Object` 方法等情况要区分清楚。
- Stream 的中间操作是惰性的，没有终止操作就不会真正执行。
- Stream 执行终止操作后不能复用。
- `map` 是一对一转换，`flatMap` 是一对多再展平，不要混用。
- `peek` 主要用于调试，不建议在里面写业务副作用。
- `forEach` 是终止操作，不适合当作链式中间处理节点。
- `Collectors.toMap()` 遇到重复 key 默认会抛异常，需要提供合并函数。
- `Optional.of(null)` 会直接抛异常，可能为空时应该用 `Optional.ofNullable()`。
- `Optional.get()` 之前如果没判断，和直接空指针风险类似。
- `orElse()` 的默认值会提前求值，默认值创建成本高或带副作用时要用 `orElseGet()`。
- Optional 不适合作为序列化模型字段、数据库实体字段或 Android Intent 参数字段，容易和框架反射、序列化、Parcelable 处理产生额外复杂度。

###### 面试可能怎么问

- [Lambda 表达式解决了什么问题](../面试/Lambda-Stream-Optional面试题.md#lambda-表达式解决了什么问题)
- [Lambda 和匿名内部类有什么区别](../面试/Lambda-Stream-Optional面试题.md#lambda-和匿名内部类有什么区别)
- [什么是函数式接口](../面试/Lambda-Stream-Optional面试题.md#什么是函数式接口)
- [方法引用是什么](../面试/Lambda-Stream-Optional面试题.md#方法引用是什么)
- [Stream 和集合遍历有什么区别](../面试/Lambda-Stream-Optional面试题.md#stream-和集合遍历有什么区别)
- [Stream 的中间操作和终止操作有什么区别](../面试/Lambda-Stream-Optional面试题.md#stream-的中间操作和终止操作有什么区别)
- [map 和 flatMap 有什么区别](../面试/Lambda-Stream-Optional面试题.md#map-和-flatmap-有什么区别)
- [parallelStream 为什么在 Android 中慎用](../面试/Lambda-Stream-Optional面试题.md#parallelstream-为什么在-android-中慎用)
- [Optional 解决了什么问题](../面试/Lambda-Stream-Optional面试题.md#optional-解决了什么问题)
- [orElse 和 orElseGet 有什么区别](../面试/Lambda-Stream-Optional面试题.md#orelse-和-orelseget-有什么区别)
- [Optional 能不能完全替代 null](../面试/Lambda-Stream-Optional面试题.md#optional-能不能完全替代-null)
