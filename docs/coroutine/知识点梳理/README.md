### Coroutine 知识点梳理

<!-- page-toc:start -->
**目录**

- [模块说明](#section-模块说明)
- [导航](#section-导航)
- [学习重点](#section-学习重点)
- [待整理](#section-待整理)
<!-- page-toc:end -->


<a id="section-模块说明"></a>
###### 模块说明

这里放 Kotlin 协程各专题的知识点清单。每个文件聚焦一个明确方向，优先记录 Android 开发中常用写法、适用场景、注意点和面试高频结论。

<a id="section-导航"></a>
###### 导航


- [挂起函数与状态机场景详解](./挂起函数与状态机场景详解.md)

- [协程作用域与常用方法](./协程作用域与常用方法.md)

- [Android 协程](./Android协程.md)
- [Android 协程工程规范](./Android协程工程规范.md)
- [Flow 冷流热流与操作符](./Flow冷流热流与操作符.md)
- [StateFlow 状态更新细节](./StateFlow状态更新细节.md)
- [协程取消与超时](./协程取消与超时.md)
- [协程和传统方案对比](./协程和传统方案对比.md)
- [协程并发控制与共享状态](./协程并发控制与共享状态.md)
- [协程核心对象和底层实现](./协程核心对象和底层实现.md)
- [小计](./小计.md)

<a id="section-学习重点"></a>
###### 学习重点

- 先理解协程不是线程，而是轻量级并发任务模型。
- Android 中优先使用 lifecycle-aware 的作用域管理协程生命周期。
- 进阶理解 `CoroutineScope`、`CoroutineContext`、`Job`、`Dispatcher`、`Continuation` 的关系。
- 区分主线程更新 UI、IO 线程执行阻塞操作、Default 处理 CPU 密集任务。
- Flow 收集要绑定生命周期，避免后台无意义收集和页面泄漏。
- 从工程分层角度约束协程使用，避免把异步逻辑散落在 UI 层。

<a id="section-待整理"></a>
###### 待整理

- [ ] launch / async / withContext
- [ ] 协程异常处理
- [ ] Flow 基础
- [ ] StateFlow 和 SharedFlow
- [ ] 协程调度器源码阅读
- [ ] suspend 状态机源码阅读
