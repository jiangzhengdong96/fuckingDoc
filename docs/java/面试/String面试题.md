### String 面试题

###### 内容概述

这里记录 String 为什么不可变、new String abc 创建几个对象、StringBuilder 和 StringBuffer 有什么区别、字符串拼接什么时候会创建新对象、intern 有什么作用 等面试题。

面试题导航：

- [String 为什么不可变](#string-为什么不可变)
- [new String abc 创建几个对象](#new-string-abc-创建几个对象)
- [StringBuilder 和 StringBuffer 有什么区别](#stringbuilder-和-stringbuffer-有什么区别)
- [字符串拼接什么时候会创建新对象](#字符串拼接什么时候会创建新对象)
- [intern 有什么作用](#intern-有什么作用)

<a id="string-为什么不可变"></a>
###### String 为什么不可变

答案：

**简答：** `String` 设计为不可变，便于复用、安全和作为常量池元素。

**展开回答：** 不可变对象可以安全共享，适合字符串常量池复用，也能减少被外部修改导致的问题。

**易错点：** 不同 JDK 版本中 `String` 底层存储实现有差异。

**关联知识点：** [Java String](../知识点梳理/String.md)

<a id="new-string-abc-创建几个对象"></a>
###### new String abc 创建几个对象

答案：

**简答：** 常见面试回答是可能创建两个对象。

**展开回答：** 一个是字符串常量池中的字面量对象，一个是堆上的 `String` 对象。若常量池中已存在该字面量，则不会重复创建池中对象。

**易错点：** 要说明“可能”和“已有常量池内容”的前提。

**关联知识点：** [Java String](../知识点梳理/String.md)

<a id="stringbuilder-和-stringbuffer-有什么区别"></a>
###### StringBuilder 和 StringBuffer 有什么区别

答案：

**简答：** `StringBuilder` 非线程安全，`StringBuffer` 线程安全。

**展开回答：** 单线程字符串拼接通常用 `StringBuilder`；需要同步时才考虑 `StringBuffer`。

**易错点：** 线程安全不一定代表性能更好。

**关联知识点：** [Java String](../知识点梳理/String.md)

<a id="字符串拼接什么时候会创建新对象"></a>
###### 字符串拼接什么时候会创建新对象

答案：

**简答：** 纯常量拼接通常编译期合并；变量参与拼接通常运行期创建新对象。

**展开回答：** 编译器能确定的字面量表达式会直接优化为常量，变量参与时结果运行期才能确定。

**易错点：** 不同编译器和 JDK 优化细节可能不同。

**关联知识点：** [Java String](../知识点梳理/String.md)

<a id="intern-有什么作用"></a>
###### intern 有什么作用

答案：

**简答：** `intern()` 返回字符串常量池中的引用。

**展开回答：** 如果池中已有相同内容字符串，返回池中引用；否则尝试将当前字符串放入池中并返回池中引用。

**易错点：** `intern()` 在不同 JDK 版本中细节有差异。

**关联知识点：** [Java String](../知识点梳理/String.md)
