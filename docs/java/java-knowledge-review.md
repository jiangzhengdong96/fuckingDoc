# Java 基础笔记 Review

## 一句话总结

当前 `java-basic.md` 已覆盖 Java 语法、变量、类型、String、数组、方法、异常、继承、多态、接口和抽象类，适合作为 Java 基础总览。后续建议把内容继续拆分到更聚焦的专题笔记，避免单篇越来越臃肿。

## 已覆盖知识点

- 基础语法和命名规范
- 修饰符、变量、源文件规则
- 基本数据类型和引用数据类型
- 运算符、`instanceof`、`Number`
- `String`、常量池、不可变性
- 数组、`Arrays`、正则表达式
- 方法、重载、可变参数、main 方法
- 垃圾回收、`finalize`
- 深拷贝和浅拷贝
- 值传递和引用传递
- 异常体系、try-catch-finally、throw/throws
- 继承、重写、重载、多态
- 接口和抽象类

## 建议校正或标记待验证

这些点建议后续回到原笔记中查资料确认后再改，当前没有直接改动原知识点：

- `String` 底层实现：Java 8 常见说法是 `char[]`，Java 9 之后是 `byte[] + coder` 的紧凑字符串实现。
- 字符串常量池位置：不同 JDK 版本位置有变化，建议拆到 JVM/字符串专题里按版本说明。
- 包装类缓存：`Integer/Long/Short/Byte` 常见缓存范围是 `-128~127`，`Character` 默认常见缓存范围不是完整 `0~65535`；`Float/Double` 的包装类缓存说法需要单独确认。
- `finalize()`：现代 Java 已经不推荐使用，建议补充“已废弃/不推荐依赖”的说明。
- `protected`：跨包子类访问有细节限制，建议单独补充示例。
- `static` 方法：不能被重写，子类同签名 static 方法属于隐藏，建议和“重写”拆开说明。
- 异常重写规则：子类重写方法不能抛出更宽的 checked exception，unchecked exception 规则需要单独说明。
- Java 值传递：当前结论是对的，建议补充对象引用拷贝示例，避免和“引用传递”混淆。

## 建议补充专题

- 集合：`List`、`Set`、`Map`、`Queue`、`HashMap`、`ArrayList`、`ConcurrentHashMap`
- 线程：线程生命周期、`Thread`、`Runnable`、`Callable`、线程安全、线程池
- 泛型：类型擦除、通配符、上下界、PECS
- 字符串：`String`、`StringBuilder`、`StringBuffer`、常量池、`intern`
- 异常：checked/unchecked、异常链、try-with-resources、finally 陷阱
- OOP：封装、继承、多态、抽象类、接口、重载/重写
- IO/NIO：字节流、字符流、缓冲流、NIO Buffer/Channel
- 反射和注解：运行时获取类信息、注解处理、Android/框架使用场景
- Lambda/Stream：函数式接口、Stream 操作、Optional
- 日期时间：`Date`、`Calendar`、`java.time`

## 拆分建议

- `java-basic.md` 保留为基础总览。
- 具体大主题拆到独立文件，例如 `collections.md`、`thread.md`、`generic.md`。
- JVM 细节不要继续堆到 Java 基础里，优先链接到 `docs/jvm/`。
- 并发底层细节可以链接到 `docs/concurrency/`，Java 目录保留 Java API 使用层。
