### Coroutine

###### 模块说明

记录 Kotlin 协程专题知识，用于整理协程基础、作用域、调度器、异常处理、Flow、底层对象模型和 Android 实战。当前重点覆盖 Android 使用方式、工程规范、核心对象关系和面试题，后续继续拆分 Flow 与源码阅读。

###### 导航

- [Coroutine 总结](./coroutine总结.md)
- [Coroutine 面试](./面试/)
- [Coroutine 知识点梳理](./知识点梳理/)

###### 学习重点

- launch、async、withContext 的区别
- 结构化并发和作用域管理
- CoroutineScope、CoroutineContext、Job、Dispatcher、Continuation 的关系
- 协程异常传播规则
- Flow 冷流、操作符和生命周期收集
- Android 中 viewModelScope、lifecycleScope、repeatOnLifecycle 的使用

###### 待整理

- [ ] Flow 基础操作符
- [ ] StateFlow / SharedFlow / Channel 对比
- [ ] 协程调度器源码阅读
- [ ] suspend 状态机源码阅读
