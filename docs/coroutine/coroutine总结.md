### Coroutine 总结

###### 目录

- [模块结构](#模块结构)
- [知识点梳理](#知识点梳理)
- [面试题](#面试题)
- [学习主线](#学习主线)
- [后续待补充](#后续待补充)

<a id="模块结构"></a>
###### 模块结构

```text
docs/coroutine/
  README.md
  coroutine总结.md
  知识点梳理/
  面试/
```

<a id="知识点梳理"></a>
###### 知识点梳理

| 文件 | 内容 |
|---|---|
| [Android协程.md](./知识点梳理/Android协程.md) | Android 中协程的使用方式、作用域、调度器、生命周期收集、异常处理和常见坑 |
| [协程和传统方案对比.md](./知识点梳理/协程和传统方案对比.md) | 协程和 Thread、Handler、Executor、RxJava、LiveData 等传统异步方案的对比 |
| [Android协程工程规范.md](./知识点梳理/Android协程工程规范.md) | Android 项目中协程分层、作用域、Dispatcher 注入、状态建模、错误处理和测试规范 |

<a id="面试题"></a>
###### 面试题

| 文件 | 内容 |
|---|---|
| [Android协程面试题.md](./面试/Android协程面试题.md) | Android 协程作用域、结构化并发、调度器、取消、异常、Flow 生命周期收集和常见实践问题 |

<a id="学习主线"></a>
###### 学习主线

| 阶段 | 目标 | 入口 |
|---|---|---|
| 入门 | 理解协程解决什么问题，以及在 Android 中放在哪些层使用 | [Android协程.md](./知识点梳理/Android协程.md) |
| 使用 | 掌握 viewModelScope、lifecycleScope、withContext、repeatOnLifecycle 的写法 | [Android协程.md](./知识点梳理/Android协程.md#android-常用使用方式) |
| 对比 | 理解协程相对 Thread、Handler、Executor、RxJava、LiveData 的取舍 | [协程和传统方案对比.md](./知识点梳理/协程和传统方案对比.md) |
| 工程 | 建立 Android 项目里的协程分层和验证规范 | [Android协程工程规范.md](./知识点梳理/Android协程工程规范.md) |
| 进阶 | 理解结构化并发、取消、异常传播和 Flow 生命周期收集 | [Android协程面试题.md](./面试/Android协程面试题.md) |

<a id="后续待补充"></a>
###### 后续待补充

- launch、async、withContext 的独立知识点。
- Job、SupervisorJob、CoroutineExceptionHandler 的异常专题。
- Flow、StateFlow、SharedFlow 和 Channel 的对比。
- 协程源码阅读和调度器原理。
