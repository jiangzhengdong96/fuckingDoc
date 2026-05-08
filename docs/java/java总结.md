# Java 总结

## 目录

- [模块结构](#模块结构)
- [知识点梳理](#知识点梳理)
- [面试题](#面试题)
- [问题集](#问题集)
- [学习主线](#学习主线)
- [后续待补充](#后续待补充)

## 模块结构

```text
docs/java/
  README.md
  java总结.md
  知识点梳理/
  面试/
  问题集/
  _archive/
```

## 知识点梳理

知识点梳理文件只列知识点和关键引用，不写成长篇解释。

| 文件 | 内容 |
|---|---|
| [java基础.md](./知识点梳理/java基础.md) | Java 基础语法、修饰符、变量、数据类型、异常、面向对象等总清单 |
| [集合.md](./知识点梳理/集合.md) | List、Set、Map、Queue、HashMap、ConcurrentHashMap |
| [线程.md](./知识点梳理/线程.md) | Thread、Runnable、Callable、线程状态、线程安全 |
| [泛型.md](./知识点梳理/泛型.md) | 泛型类、泛型方法、通配符、上下界、类型擦除 |
| [String.md](./知识点梳理/String.md) | String 不可变、常量池、StringBuilder、StringBuffer |
| [异常.md](./知识点梳理/异常.md) | Throwable、Error、Exception、throw、throws、finally |
| [面向对象.md](./知识点梳理/面向对象.md) | 封装、继承、多态、接口、抽象类、重载、重写 |

## 面试题

面试文件放对应专题的问答，知识点文件在关键位置引用面试题。

| 文件 | 内容 |
|---|---|
| [java基础面试题.md](./面试/java基础面试题.md) | Java 基础语法、变量、类型、值传递等问题 |
| [集合面试题.md](./面试/集合面试题.md) | HashMap、ArrayList、HashSet、ConcurrentHashMap |
| [线程面试题.md](./面试/线程面试题.md) | 线程状态、start/run、sleep/wait、volatile、synchronized |
| [泛型面试题.md](./面试/泛型面试题.md) | 类型擦除、通配符、PECS、泛型限制 |
| [String面试题.md](./面试/String面试题.md) | String 不可变、常量池、new String、intern |
| [异常面试题.md](./面试/异常面试题.md) | 异常体系、throw/throws、finally、try-with-resources |
| [面向对象面试题.md](./面试/面向对象面试题.md) | 重载/重写、接口/抽象类、多态、static 方法 |

## 问题集

问题集用于记录暂不展开成面试题的疑问、待验证点和自测题。

| 文件 | 内容 |
|---|---|
| [java基础问题集.md](./问题集/java基础问题集.md) | Java 基础自测和易错问题 |
| [集合问题集.md](./问题集/集合问题集.md) | 集合专题自测和源码待确认问题 |
| [线程问题集.md](./问题集/线程问题集.md) | 线程和并发基础自测问题 |
| [泛型问题集.md](./问题集/泛型问题集.md) | 泛型类型擦除、通配符相关问题 |
| [java基础待补充问题.md](./问题集/java基础待补充问题.md) | 从原基础笔记 review 出来的待校正、待补充点 |

## 学习主线

| 阶段 | 目标 | 入口 |
|---|---|---|
| 基础语法 | 能写出规范 Java 代码 | [java基础.md](./知识点梳理/java基础.md) |
| 常用类型 | 理解变量、数据类型、String、数组 | [java基础.md](./知识点梳理/java基础.md)、[String.md](./知识点梳理/String.md) |
| 面向对象 | 理解继承、多态、接口和抽象类 | [面向对象.md](./知识点梳理/面向对象.md) |
| 异常处理 | 理解异常分类和处理方式 | [异常.md](./知识点梳理/异常.md) |
| 高频专题 | 掌握集合、线程、泛型 | [集合.md](./知识点梳理/集合.md)、[线程.md](./知识点梳理/线程.md)、[泛型.md](./知识点梳理/泛型.md) |
| 面试复盘 | 用问答方式检查理解深度 | [面试](./面试/) |

## 后续待补充

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
