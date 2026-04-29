# Java 线程

## 一句话总结

Java 线程用于并发执行任务，基础知识包括线程创建、生命周期、线程安全和线程协作。

## 背景 / 使用场景

- 耗时任务不能阻塞主线程。
- 多个任务可以并发执行。
- 后台任务、网络请求、文件读写、定时任务都可能涉及线程。

## 核心概念

- `Thread`：线程对象。
- `Runnable`：无返回值任务。
- `Callable`：有返回值任务。
- `Future`：异步结果。
- `synchronized`：内置锁。
- `volatile`：保证可见性。
- `wait/notify`：线程等待和唤醒。

## 线程生命周期

```text
NEW -> RUNNABLE -> BLOCKED / WAITING / TIMED_WAITING -> TERMINATED
```

## 关键问题

- `Thread` 和 `Runnable` 有什么区别？
- `start()` 和 `run()` 有什么区别？
- 什么是线程安全？
- `synchronized` 和 `volatile` 有什么区别？
- 为什么推荐线程池而不是频繁 new Thread？

## 示例代码

```java
Thread thread = new Thread(new Runnable() {
    @Override
    public void run() {
        System.out.println("run in background");
    }
});
thread.start();
```

## 常见坑

- 直接调用 `run()` 不会启动新线程。
- 多线程共享变量不加保护可能出现数据竞争。
- 线程创建和销毁有成本，不适合频繁创建。
- Android 中不能在子线程直接更新 UI。

## 和相关知识的区别

- 线程是执行单元，进程是资源分配单位。
- 并发不等于并行；并发强调任务交替推进，并行强调同时执行。
- Java 线程基础偏 API 使用，锁、CAS、线程池等深入内容可以继续放到 `concurrency/`。

## 实战经验

- 简单后台任务可以从线程基础学起。
- 工程中更常用线程池、协程、RxJava 或框架封装。
- Android 项目中要重点关注主线程阻塞、线程泄漏和生命周期。

## 面试可能怎么问

- Java 线程有哪几种状态？
- `sleep()` 和 `wait()` 有什么区别？
- `synchronized` 锁的是什么？
- `volatile` 能不能保证原子性？
- 线程池核心参数有哪些？

## 延伸阅读

- `java.lang.Thread`
- `java.lang.Runnable`
- `java.util.concurrent.Callable`
- `java.util.concurrent.ExecutorService`
