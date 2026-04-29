# 贡献和维护规则

本仓库用于长期沉淀个人技术知识。新增内容时优先遵循 [docs/knowledge-rules.md](./docs/knowledge-rules.md)。

## 基本要求

- 目录和文件名使用英文小写加短横线，例如 `activity-lifecycle.md`。
- 正文使用中文。
- 新增知识点时优先使用 `scripts/new-note.ps1` 创建文件。
- 新增、移动或删除笔记后运行 `scripts/update-index.ps1`。
- 提交前运行 `scripts/check-knowledge.ps1` 做结构和链接检查。
- 如果 PowerShell 执行策略禁止直接运行脚本，使用 `powershell -NoProfile -ExecutionPolicy Bypass -File ...`。
- 单篇笔记保持聚焦；内容变长时拆成多个知识点文件或专题目录。

## 模板选择

- 普通知识点：`templates/topic-template.md`
- 问题排查：`templates/troubleshooting-template.md`
- 源码阅读：`templates/source-reading-template.md`
- 面试知识点：`templates/interview-template.md`
- 学习记录：`templates/learning-record-template.md`

## 新增前检查

新增笔记前先查重。优先复用已有笔记；只有当前内容确实是独立知识点时再新建。

创建知识点后，可以按需同步：

- `docs/roadmap.md`：标记学习中或已完成。
- `docs/learning-records/`：记录这次学习过程。
