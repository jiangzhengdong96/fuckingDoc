# Android 技术知识库

这个仓库用于沉淀 Android 开发工程师的技术知识点，覆盖 Android、Kotlin、Java、JVM、AI、Flutter、设计模式、Git、性能优化、工程实践和面试复盘等方向。

## 常用入口

- [知识库规则](./docs/knowledge-rules.md)
- [学习路线表](./docs/roadmap.md)
- [学习记录](./docs/learning-records/)
- [全局索引](./docs/index.md)
- [术语表](./docs/glossary.md)

## 自动化脚本

创建新笔记：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module kotlin -Title "协程异常处理" -Slug coroutine-exception -Type topic
```

更新索引：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
```

质量检查：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-knowledge.ps1
```

## 模板

- [专题知识模板](./templates/topic-template.md)
- [问题排查模板](./templates/troubleshooting-template.md)
- [源码阅读模板](./templates/source-reading-template.md)
- [面试知识点模板](./templates/interview-template.md)
- [学习记录模板](./templates/learning-record-template.md)
