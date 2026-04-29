# Java String

## 一句话总结

`String` 是不可变字符串类型，常见考点集中在不可变性、字符串常量池、拼接和 `StringBuilder/StringBuffer` 的区别。

## 背景 / 使用场景

- 字符串是 Java 最常用的引用类型之一。
- Android 开发中日志、网络参数、UI 文案、JSON 字段都会大量使用字符串。
- 字符串对象创建和拼接方式会影响内存和性能。

## 核心概念

- `String`：不可变字符串。
- `StringBuilder`：可变字符串，非线程安全，常用于单线程拼接。
- `StringBuffer`：可变字符串，线程安全。
- 字符串常量池：复用字符串字面量。
- `intern()`：尝试将字符串放入常量池并返回池中引用。

## 关键问题

- `String` 为什么不可变？
- `String s = "abc"` 和 `new String("abc")` 有什么区别？
- 字符串拼接什么时候会创建新对象？
- `StringBuilder` 和 `StringBuffer` 有什么区别？
- `intern()` 的作用是什么？

## 示例代码

```java
String a = "abc";
String b = "abc";
String c = new String("abc");

System.out.println(a == b);
System.out.println(a == c);
System.out.println(a.equals(c));
```

## 常见坑

- 使用 `==` 比较字符串内容是错误的，应该使用 `equals()`。
- 循环中大量字符串拼接建议使用 `StringBuilder`。
- 字符串常量池和堆对象的引用关系容易混淆。
- 不同 JDK 版本中 `String` 底层实现有差异，需要按版本说明。

## 和相关知识的区别

- `String` 不可变；`StringBuilder` 和 `StringBuffer` 可变。
- `StringBuilder` 性能通常更好；`StringBuffer` 方法带同步。
- 常量池属于 JVM 相关知识，深入内容可以链接到 `jvm/`。

## 实战经验

- 字符串内容比较统一使用 `equals()` 或安全写法 `"abc".equals(value)`。
- 日志和循环拼接中避免无意义创建大量临时字符串。
- 面试复盘时建议结合内存图解释字面量和 `new String()`。

## 面试可能怎么问

- `String` 为什么设计成不可变？
- `new String("abc")` 创建几个对象？
- `StringBuilder` 和 `StringBuffer` 区别是什么？
- `intern()` 在不同 JDK 版本有什么差异？

## 延伸阅读

- `java.lang.String`
- `java.lang.StringBuilder`
- `java.lang.StringBuffer`
