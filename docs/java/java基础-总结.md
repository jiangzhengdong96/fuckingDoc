# Java 基础总结

> 这个文件负责整体归纳和引用展示；纯知识点列表见 [Java 基础知识点清单](./java基础.md)。

## 一句话总结

Java 基础可以按“语法规则 -> 类型和内存 -> 字符串和数组 -> 方法和异常 -> 面向对象 -> 常用专题”这条线来学习。

## 学习主线

| 阶段    | 关注点              | 对应知识点                                                                                                    |
| ----- | ---------------- | -------------------------------------------------------------------------------------------------------- |
| 语法入门  | 会写合法 Java 代码     | [基础语法和编码规范](./java基础.md#基础语法和编码规范)、[修饰符](./java基础.md#修饰符)                                                |
| 类型基础  | 理解变量、类型、转换       | [变量](./java基础.md#变量)、[数据类型](./java基础.md#数据类型)                                                            |
| 常用对象  | 掌握 String、数组、包装类 | [String](./java基础.md#string)、[数组和 Arrays](./java基础.md#数组和-arrays)、[Number 和包装类](./java基础.md#number-和包装类) |
| 方法和流程 | 理解方法、重载、参数传递     | [方法](./java基础.md#方法)、[拷贝和参数传递](./java基础.md#拷贝和参数传递)                                                      |
| 异常处理  | 能表达和处理失败         | [异常](./java基础.md#异常)、[Java 异常](./exception.md)                                                           |
| 面向对象  | 理解类之间的关系和多态      | [面向对象](./java基础.md#面向对象)、[Java 面向对象](./oop.md)                                                           |
| 常用专题  | 能进入工程实践          | [集合](./collections.md)、[线程](./thread.md)、[泛型](./generic.md)                                              |

## 基础知识归纳

### 1. 语法和命名是入口

先掌握大小写敏感、类名、方法名、常量名、标识符、源文件声明规则。这些知识点不难，但决定代码是否规范。

引用：[基础语法和编码规范](./java基础.md#基础语法和编码规范)

### 2. 修饰符决定可见性和行为边界

访问控制修饰符控制“谁能访问”，非访问控制修饰符控制“能不能继承、能不能重写、是不是静态、是不是抽象”。

引用：[修饰符](./java基础.md#修饰符)

### 3. 变量和数据类型是内存理解的起点

局部变量、实例变量、静态变量的生命周期和默认值不同。基本数据类型保存值，引用数据类型保存对象引用。

引用：[变量](./java基础.md#变量)、[数据类型](./java基础.md#数据类型)

### 4. String 是 Java 基础里的高频重点

`String` 不可变、字符串常量池、`new String()`、字符串拼接、`StringBuilder` 和 `StringBuffer` 都是基础和面试高频点。

引用：[String](./java基础.md#string)、[Java String](./string.md)

### 5. 方法、重载和参数传递要一起理解

方法参数本质是局部变量。Java 是值传递，对象作为参数传递时，传递的是对象引用的拷贝。

引用：[方法](./java基础.md#方法)、[拷贝和参数传递](./java基础.md#拷贝和参数传递)

### 6. 异常是失败处理模型

异常体系从 `Throwable` 开始，分为 `Error`、运行时异常和编译时异常。`try-catch-finally`、`throw`、`throws`、异常链是核心。

引用：[异常](./java基础.md#异常)、[Java 异常](./exception.md)

### 7. 面向对象是 Java 的组织方式

继承用于复用和建立层级，多态用于降低调用方与具体实现的耦合，接口和抽象类用于抽象行为和模板。

引用：[面向对象](./java基础.md#面向对象)、[Java 面向对象](./oop.md)

## 已拆分专题引用

- [Java 集合](./collections.md)：List、Set、Map、Queue、HashMap、ConcurrentHashMap。
- [Java 线程](./thread.md)：线程创建、生命周期、线程安全、线程池入口。
- [Java 泛型](./generic.md)：类型擦除、通配符、上下界、PECS。
- [Java String](./string.md)：不可变性、常量池、拼接、`intern()`。
- [Java 异常](./exception.md)：异常体系、throw/throws、finally、异常链。
- [Java 面向对象](./oop.md)：继承、多态、接口、抽象类、重载/重写。

## Review 后建议补充

这些内容建议后续继续拆成独立 MD：

- IO / NIO
- 反射
- 注解
- 枚举
- Lambda / Stream
- Optional
- `Object` 常用方法
- `equals` / `hashCode`
- 日期时间 API
- 序列化
- 类加载基础

## 关联

- [Java 基础知识点清单](./java基础.md)
- [Java 基础笔记 Review](./java-knowledge-review.md)
- [Java 集合](./collections.md)
- [Java 线程](./thread.md)
- [Java 泛型](./generic.md)
