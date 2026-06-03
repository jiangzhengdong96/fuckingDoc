### Java 总结

###### 目录

- [模块结构](#模块结构)
- [知识点梳理](#知识点梳理)
- [面试题](#面试题)
- [问题集](#问题集)
- [学习主线](#学习主线)
- [后续待补充](#后续待补充)

###### 模块结构

```text
docs/java/
  README.md
  java总结.md
  知识点梳理/
  面试/
  问题集/
  _archive/
```

###### 知识点梳理

知识点梳理文件只列知识点和关键引用，不写成长篇解释。

| 文件                             | 内容                                             |
| ------------------------------ | ---------------------------------------------- |
| [java基础.md](./知识点梳理/java基础.md) | Java 基础语法、修饰符、变量、数据类型、运算符、包装器类、数组、正则、代码块、主方法、递归、GC、拷贝和值传递 |
| [集合.md](./知识点梳理/集合.md)         | 集合体系、底层数据结构、List、Set、Map、Queue、Iterator、Collections、排序、Android 常见集合、常见坑 |
| [线程.md](./知识点梳理/线程.md)         | Thread、Runnable、Callable、线程状态、线程安全、synchronized、volatile、线程协作、中断、守护线程、Lock、并发工具、线程池、网络编程和线程、ThreadLocal、Android 主线程 |
| [泛型.md](./知识点梳理/泛型.md)         | 泛型基础、泛型类和方法、泛型接口、通配符、类型擦除、泛型限制、泛型数组、泛型和反射、Android 泛型场景 |
| [String.md](./知识点梳理/String.md) | String 不可变、常量池、StringBuilder、StringBuffer      |
| [异常.md](./知识点梳理/异常.md)         | Throwable、Error、Exception、throw、throws、finally |
| [面向对象.md](./知识点梳理/面向对象.md)     | 封装、继承、多态、接口、抽象类、重载、重写                          |
| [IO-NIO.md](./知识点梳理/IO-NIO.md) | IO 流分类、常用流、缓冲流、字符编码、File/Path/Files、RandomAccessFile、BIO/NIO/AIO 概念 |
| [反射.md](./知识点梳理/反射.md) | Class 对象、动态加载、ClassLoader、类信息、构造方法、字段和方法调用、注解和泛型反射、动态代理、Android 使用限制 |
| [注解.md](./知识点梳理/注解.md) | 注解基础、注解参数、元注解、内置注解、运行时注解、编译期注解处理、Android 使用场景 |
| [枚举.md](./知识点梳理/枚举.md) | 枚举基础、字段和方法、构造方法、抽象方法、EnumSet、EnumMap、枚举单例、Android 使用场景 |
| [Lambda-Stream-Optional.md](./知识点梳理/Lambda-Stream-Optional.md) | Lambda、函数式接口、方法引用、Stream、Optional、Android 使用场景 |
| [日期时间.md](./知识点梳理/日期时间.md) | Date/Calendar 的问题，java.time 的推荐用法 |
| [序列化.md](./知识点梳理/序列化.md) | 序列化基础、Serializable、transient、serialVersionUID、自定义序列化、Parcelable 对比、Android 使用场景 |

###### 面试题

面试文件放对应专题的问答，知识点文件在关键位置引用面试题。

| 文件                                | 内容                                              |
| --------------------------------- | ----------------------------------------------- |
| [java基础面试题.md](./面试/java基础面试题.md) | 基础语法、修饰符、变量、类型转换、包装类、数组、代码块、GC、拷贝和值传递 |
| [集合面试题.md](./面试/集合面试题.md)         | HashMap、ArrayList、HashSet、ConcurrentHashMap     |
| [线程面试题.md](./面试/线程面试题.md)         | start/run、线程状态、sleep/wait、synchronized、volatile、wait/notify、中断、守护线程、Lock、Atomic、线程池、网络编程和线程、ThreadLocal、Android 主线程 |
| [泛型面试题.md](./面试/泛型面试题.md)         | 类型擦除、泛型继承、通配符、PECS、泛型限制、静态泛型方法、泛型数组、raw type、Android 泛型场景 |
| [String面试题.md](./面试/String面试题.md) | String 不可变、常量池、new String、intern                |
| [异常面试题.md](./面试/异常面试题.md)         | 异常体系、throw/throws、finally、try-with-resources    |
| [面向对象面试题.md](./面试/面向对象面试题.md)     | 封装、继承、this/super、初始化顺序、重载/重写、多态、接口/抽象类 |
| [反射面试题.md](./面试/反射面试题.md) | Class 对象、动态加载、ClassLoader、对象创建、字段和方法调用、注解、泛型反射、动态代理、Android 限制 |
| [注解面试题.md](./面试/注解面试题.md) | 元注解、保留策略、运行时读取、编译期处理、Android 注解场景 |
| [枚举面试题.md](./面试/枚举面试题.md) | 枚举优势、本质、字段和构造方法、ordinal 风险、EnumSet、EnumMap、枚举单例、Android IntDef |
| [序列化面试题.md](./面试/序列化面试题.md) | Serializable、transient、serialVersionUID、反序列化构造方法、Parcelable、安全风险 |
| [Lambda-Stream-Optional面试题.md](./面试/Lambda-Stream-Optional面试题.md) | Lambda、函数式接口、方法引用、Stream 中间操作和终止操作、Optional、Android 兼容 |

###### 问题集

问题集用于记录暂不展开成面试题的疑问、待验证点和自测题。

| 文件                                     | 内容                        |
| -------------------------------------- | ------------------------- |
| [java基础问题集.md](./问题集/java基础问题集.md)     | Java 基础自测和易错问题            |
| [集合问题集.md](./问题集/集合问题集.md)             | 集合专题自测和源码待确认问题            |
| [线程问题集.md](./问题集/线程问题集.md)             | 线程和并发基础自测问题               |
| [泛型问题集.md](./问题集/泛型问题集.md)             | 泛型类型擦除、通配符相关问题            |
| [java基础待补充问题.md](./问题集/java基础待补充问题.md) | 从原基础笔记 review 出来的待校正、待补充点 |

###### 学习主线

| 阶段   | 目标                  | 入口                                                                   |
| ---- | ------------------- | -------------------------------------------------------------------- |
| 基础语法 | 能写出规范 Java 代码       | [java基础.md](./知识点梳理/java基础.md)                                       |
| 常用类型 | 理解变量、数据类型、包装器类、String、数组 | [java基础.md](./知识点梳理/java基础.md)、[String.md](./知识点梳理/String.md)        |
| 面向对象 | 理解继承、多态、接口和抽象类      | [面向对象.md](./知识点梳理/面向对象.md)                                           |
| 异常处理 | 理解异常分类和处理方式         | [异常.md](./知识点梳理/异常.md)                                               |
| IO/NIO | 理解文件读写、编码、缓冲和随机访问文件 | [IO-NIO.md](./知识点梳理/IO-NIO.md) |
| 高频专题 | 掌握集合、线程、泛型          | [集合.md](./知识点梳理/集合.md)、[线程.md](./知识点梳理/线程.md)、[泛型.md](./知识点梳理/泛型.md) |
| 现代语法 | 理解 Lambda、Stream、Optional 的使用边界 | [Lambda-Stream-Optional.md](./知识点梳理/Lambda-Stream-Optional.md) |
| 进阶特性 | 理解反射、注解、枚举和序列化的边界 | [反射.md](./知识点梳理/反射.md)、[注解.md](./知识点梳理/注解.md)、[枚举.md](./知识点梳理/枚举.md)、[序列化.md](./知识点梳理/序列化.md) |
| 面试复盘 | 用问答方式检查理解深度         | [面试](./面试/)                                                          |

###### 后续待补充

- IO / NIO 面试题和实践示例
- `Object` 常用方法
- `equals` / `hashCode`
- 日期时间 API
- 类加载基础
