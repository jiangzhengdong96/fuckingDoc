### 贡献和维护规则

本仓库用于长期沉淀个人技术知识。新增内容时优先遵循 [docs/knowledge-rules.md](./docs/knowledge-rules.md)。

###### 基本要求

- 目录名优先使用英文小写加短横线，例如 `android-framework/`。
- 笔记文件名允许中文或英文，多个词之间用短横线，例如 `java基础.md`、`java基础-总结.md`、`activity-lifecycle.md`。
- 正文使用中文。
- 普通笔记和模块 `README.md` 都按模板使用较小标题层级，不强制使用一级标题。
- 新增知识点时优先使用 `scripts/new-note.ps1` 创建文件。
- 新增、移动或删除笔记后运行 `scripts/update-index.ps1`。
- 如果 PowerShell 执行策略禁止直接运行脚本，使用 `powershell -NoProfile -ExecutionPolicy Bypass -File ...`。
- 单篇笔记保持聚焦；内容变长时拆成多个知识点文件或专题目录。

###### 模板选择

- 普通知识点：`templates/topic-template.md`
- 问题排查：`templates/troubleshooting-template.md`
- 源码阅读：`templates/source-reading-template.md`
- 面试知识点：`templates/interview-template.md`
- 学习记录：`templates/learning-record-template.md`
