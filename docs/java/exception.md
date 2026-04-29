# Java 异常

## 一句话总结

Java 异常体系以 `Throwable` 为根，核心分为 `Error`、checked exception 和 unchecked exception。

## 背景 / 使用场景

- 处理文件、网络、数据库等外部不稳定因素。
- 表达业务失败或参数错误。
- 保证资源正确释放。
- 让调用方知道方法可能失败。

## 核心概念

```text
Throwable
  ├─ Error
  └─ Exception
      ├─ RuntimeException
      └─ Checked Exception
```

| 类型 | 特点 | 示例 |
|---|---|---|
| `Error` | JVM 或系统级严重问题 | `OutOfMemoryError` |
| checked exception | 编译期强制处理 | `IOException` |
| unchecked exception | 编译期不强制处理 | `NullPointerException` |

## 关键问题

- checked exception 和 unchecked exception 有什么区别？
- `throw` 和 `throws` 有什么区别？
- `finally` 一定会执行吗？
- 为什么不建议在 finally 中 return？
- 什么是异常链？

## 示例代码

```java
try {
    readFile();
} catch (IOException e) {
    throw new RuntimeException("读取文件失败", e);
} finally {
    System.out.println("释放资源");
}
```

## 常见坑

- catch 顺序要先子类后父类。
- finally 中 return 会覆盖 try/catch 的 return。
- finally 中抛异常会覆盖前面的异常。
- 捕获异常后只打印不处理，可能掩盖真实问题。

## 和相关知识的区别

- `throw` 是抛出一个异常对象。
- `throws` 是声明方法可能抛出异常。
- 业务失败不一定都要用异常表达，要看项目错误处理约定。

## 实战经验

- 文件、网络、数据库等资源操作优先考虑 try-with-resources。
- 保留原始异常作为 cause，方便排查。
- Android 中异常处理要避免吞掉崩溃根因。

## 面试可能怎么问

- Java 异常体系是什么？
- `Exception` 和 `Error` 区别是什么？
- `RuntimeException` 是否必须捕获？
- finally 中 return 会发生什么？
- try-with-resources 原理是什么？

## 延伸阅读

- `java.lang.Throwable`
- `java.lang.Exception`
- `java.lang.RuntimeException`
- try-with-resources
