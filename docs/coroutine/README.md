### Coroutine

<!-- page-toc:start -->
**目录**

- [模块说明](#section-模块说明)
- [导航](#section-导航)
- [学习重点](#section-学习重点)
- [待整理](#section-待整理)
<!-- page-toc:end -->


<a id="section-模块说明"></a>
###### 模块说明

记录 Kotlin 协程专题知识，覆盖 Android 使用方式、作用域与底层对象、Flow 冷热流和共享策略、取消超时、StateFlow 更新、并发控制及对应面试题。源码阅读继续按专题补充。

<a id="section-导航"></a>
###### 导航

- [Coroutine 总结](./coroutine总结.md)
- [Coroutine 面试](./面试/)
- [Coroutine 知识点梳理](./知识点梳理/)

<a id="section-学习重点"></a>
###### 学习重点

- launch、async、withContext 的区别
- 结构化并发和作用域管理
- CoroutineScope、CoroutineContext、Job、Dispatcher、Continuation 的关系
- 协程异常传播规则
- Flow 冷流、操作符和生命周期收集
- Android 中 viewModelScope、lifecycleScope、repeatOnLifecycle 的使用

<a id="section-待整理"></a>
###### 待整理

- [ ] Flow 基础操作符
- [ ] StateFlow / SharedFlow / Channel 对比
- [ ] 协程调度器源码阅读
- [ ] suspend 状态机源码阅读
