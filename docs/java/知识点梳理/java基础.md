# Java 基础知识点清单

> 这个文件只列 Java 基础知识点，不展开长篇解释；整体归纳和引用入口见 [Java 总结](../java总结.md)。

## 目录

- [基础语法和编码规范](#基础语法和编码规范)
- [修饰符](#修饰符)
- [变量](#变量)
- [数据类型](#数据类型)
- [运算符](#运算符)
- [Number 和包装类](#number-和包装类)
- [String](#string)
- [数组和 Arrays](#数组和-arrays)
- [正则表达式](#正则表达式)
- [方法](#方法)
- [垃圾回收](#垃圾回收)
- [拷贝和参数传递](#拷贝和参数传递)
- [异常](#异常)
- [面向对象](#面向对象)
- [已拆分专题](#已拆分专题)
- [待补充知识点](#待补充知识点)

## 基础语法和编码规范

- 大小写敏感。
- 类名首字母大写。
- 方法名首字母小写，后续单词驼峰。
- 常量名大写，单词之间用下划线。
- 标识符命名规则。
- `final` 修饰常量。
- 源文件中 public 类和文件名一致。
- 关联面试题：[Java 为什么大小写敏感](../面试/java基础面试题.md#java-为什么大小写敏感)。

## 修饰符

- 访问控制修饰符：default、public、protected、private。
- 非访问控制修饰符：final、abstract、static、synchronized。
- final 类。
- final 方法。
- final 变量。
- abstract 类。
- abstract 方法。
- static 方法。
- static 变量。
- 关联面试题：[final 可以修饰什么](../面试/java基础面试题.md#final-可以修饰什么)。

## 变量

- 局部变量。
- 成员变量 / 实例变量。
- 类变量 / 静态变量。
- 变量默认值。
- 变量生命周期。
- 变量内存位置。
- `object.变量名`。
- `class.变量名`。
- 静态变量持有大对象的风险。
- 关联面试题：[static 变量和实例变量有什么区别](../面试/java基础面试题.md#static-变量和实例变量有什么区别)。

## 数据类型

- 基本数据类型：byte、short、int、long、float、double、char、boolean。
- 引用数据类型：String、数组、自定义类、Java 自带类。
- 自动类型转换。
- 强制类型转换。
- 浮点数转整数。
- 关联面试题：[Java 有哪些数据类型](../面试/java基础面试题.md#java-有哪些数据类型)。

## 运算符

- 位运算符：`&`、`|`、`^`、`~`、`<<`、`>>`。
- 逻辑运算符：`&&`、`||`、`!`。
- 短路和非短路。
- 运算符优先级。
- `instanceof`。

## Number 和包装类

- `Number`。
- `Integer`、`Long`、`Byte`、`Double`、`Float`、`Short`。
- 包装类缓存。
- `Integer.valueOf`。
- `Character.valueOf`。
- 待验证：包装类缓存范围按 JDK 版本整理。

## String

- `String` 不可变。
- 字符串拼接。
- `StringBuilder`。
- `StringBuffer`。
- 字符串常量池。
- `new String("abc")`。
- 编译期常量拼接。
- 变量参与字符串拼接。
- `String.intern()`。
- String 不可变的底层原因。
- String 不可变的目的。
- 关联专题：[Java String](./String.md)。

## 数组和 Arrays

- 数组声明。
- 静态创建数组。
- 动态创建数组。
- 二维数组。
- `java.util.Arrays`。
- `sort`。
- `toString`。
- `fill`。

## 正则表达式

- `matches`。
- `replaceAll`。
- `split`。
- `Pattern`。
- `Matcher`。

## 方法

- 方法参数。
- 局部变量作用域。
- 方法重载。
- 可变参数。
- main 方法。
- 返回值。
- 访问修饰符。

## 垃圾回收

- 无引用对象回收。
- 堆内存对象回收。
- 常量池部分常量回收。
- 引用置为 null。
- `System.gc()`。
- `finalize()`。
- 待验证：`finalize()` 的废弃状态和替代方案。

## 拷贝和参数传递

- 浅拷贝。
- 深拷贝。
- 值传递。
- 对象引用拷贝。
- 引用传递对比。
- 关联面试题：[Java 是值传递还是引用传递](../面试/java基础面试题.md#java-是值传递还是引用传递)。

## 异常

- `Throwable`。
- `Error`。
- `Exception`。
- `RuntimeException`。
- Checked Exception。
- `try-catch-finally`。
- catch 顺序。
- finally 中 return。
- finally 中异常覆盖。
- `throw`。
- `throws`。
- 异常链化。
- 子类重写方法的异常规则。
- 线程异常独立性。
- 关联专题：[Java 异常](./异常.md)。

## 面向对象

- 继承。
- 子类。
- 父类。
- 构造方法。
- `this`。
- `super`。
- 方法重写。
- 方法重载。
- 多态。
- 父类引用指向子类对象。
- 虚函数 / 虚方法调用。
- 接口。
- 抽象类。
- 接口和抽象类对比。
- 关联专题：[Java 面向对象](./面向对象.md)。

## 已拆分专题

- [Java 集合](./集合.md)
- [Java 线程](./线程.md)
- [Java 泛型](./泛型.md)
- [Java String](./String.md)
- [Java 异常](./异常.md)
- [Java 面向对象](./面向对象.md)

## 待补充知识点

- IO / NIO。
- 反射。
- 注解。
- 枚举。
- Lambda。
- Stream。
- Optional。
- `Object` 常用方法。
- `equals` / `hashCode`。
- 日期时间 API。
- 序列化。
- 类加载基础。
