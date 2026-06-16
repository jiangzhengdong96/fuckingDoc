### Coroutine 知识点梳理

###### 模块说明

这里放 Kotlin 协程各专题的知识点清单。每个文件聚焦一个明确方向，优先记录 Android 开发中常用写法、适用场景、注意点和面试高频结论。

###### 导航

- [Android 协程](./Android协程.md)
- [协程和传统方案对比](./协程和传统方案对比.md)
- [Android 协程工程规范](./Android协程工程规范.md)

###### 学习重点

- 先理解协程不是线程，而是轻量级并发任务模型。
- Android 中优先使用 lifecycle-aware 的作用域管理协程生命周期。
- 区分主线程更新 UI、IO 线程执行阻塞操作、Default 处理 CPU 密集任务。
- Flow 收集要绑定生命周期，避免后台无意义收集和页面泄漏。
- 从工程分层角度约束协程使用，避免把异步逻辑散落在 UI 层。

###### 待整理

- [ ] launch / async / withContext
- [ ] 协程异常处理
- [ ] Flow 基础
- [ ] StateFlow 和 SharedFlow
