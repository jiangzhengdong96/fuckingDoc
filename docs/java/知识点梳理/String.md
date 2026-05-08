# Java String 知识点清单

## 目录

- [String 基础](#string-基础)
- [不可变性](#不可变性)
- [字符串常量池](#字符串常量池)
- [字符串拼接](#字符串拼接)
- [StringBuilder 和 StringBuffer](#stringbuilder-和-stringbuffer)
- [常见坑](#常见坑)
- [关联面试题](#关联面试题)

## String 基础

- `String`。
- 引用数据类型。
- 不可变对象。
- 字符串字面量。
- `equals()`。
- `==`。

## 不可变性

- 字符串内容不可变。
- 修改操作返回新对象。
- 便于常量池复用。
- 便于安全共享。
- 待验证：不同 JDK 版本的底层存储差异。

## 字符串常量池

- 字符串字面量入池。
- `new String("abc")`。
- `intern()`。
- 常量池复用。
- 常量池位置和 JDK 版本有关。

## 字符串拼接

- 纯常量拼接。
- 变量参与拼接。
- 编译期优化。
- 运行期创建对象。

## StringBuilder 和 StringBuffer

- `StringBuilder` 可变。
- `StringBuilder` 非线程安全。
- `StringBuffer` 可变。
- `StringBuffer` 线程安全。
- 大量拼接优先考虑 `StringBuilder`。

## 常见坑

- 字符串内容比较用 `equals()`。
- 循环中大量 `+` 拼接可能产生额外对象。
- `new String("abc")` 创建对象数量要说明前提。
- `intern()` 行为要考虑 JDK 版本。

## 关联面试题

- [String 为什么不可变](../面试/String面试题.md#string-为什么不可变)
- [new String abc 创建几个对象](../面试/String面试题.md#new-string-abc-创建几个对象)
- [StringBuilder 和 StringBuffer 有什么区别](../面试/String面试题.md#stringbuilder-和-stringbuffer-有什么区别)
- [字符串拼接什么时候会创建新对象](../面试/String面试题.md#字符串拼接什么时候会创建新对象)
- [intern 有什么作用](../面试/String面试题.md#intern-有什么作用)
