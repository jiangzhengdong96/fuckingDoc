# 知识库维护规则

## 目标

这个仓库用于记录 Android 开发工程师的长期技术积累。内容要方便检索、持续补充和复盘，不追求一次写满。

## 目录分层

- `docs/<module>/README.md`：模块说明、导航、学习重点、待整理。
- `docs/<module>/<note>.md`：具体知识点笔记。
- `docs/<module>/<topic>/README.md`：内容较大的专题目录导航。
- `docs/learning-records/`：个人学习记录。
- `templates/`：笔记模板。
- `scripts/`：创建笔记和更新索引的脚本。

## 命名规则

- 目录和文件名使用英文小写加短横线，例如 `activity-lifecycle.md`。
- 标题使用中文，例如 `# Activity 生命周期`。
- 如果标题是中文，创建文件时需要提供英文 `Slug`。
- 图片和截图放到 `assets/`，按模块继续建子目录。

## 笔记类型和模板

| 类型 | 参数值 | 模板 |
|---|---|---|
| 普通知识点 | `topic` | `templates/topic-template.md` |
| 问题排查 | `troubleshooting` | `templates/troubleshooting-template.md` |
| 源码阅读 | `source-reading` | `templates/source-reading-template.md` |
| 面试知识点 | `interview` | `templates/interview-template.md` |
| 学习记录 | `learning-record` | `templates/learning-record-template.md` |

## 创建笔记流程

创建前先查重：

- 搜索相似标题、slug 和关键词。
- 如果已有笔记能承载当前内容，优先追加或整理已有笔记。
- 如果确实是独立知识点，再创建新笔记。

优先使用脚本创建笔记：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module kotlin -Title "协程异常处理" -Slug coroutine-exception -Type topic
```

创建问题排查记录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module troubleshooting -Title "Gradle 依赖冲突排查" -Slug gradle-dependency-conflict -Type troubleshooting
```

创建源码阅读记录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module source-reading -Title "OkHttp 责任链源码阅读" -Slug okhttp-interceptor-chain -Type source-reading
```

创建面试知识点：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module interview -Title "HashMap 高频面试点" -Slug hashmap-interview -Type interview
```

创建学习记录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module learning-records -Title "协程学习记录" -Slug coroutine-learning -Type learning-record
```

## 自动索引规则

新增、移动、删除笔记后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
```

脚本会：

- 更新有实际子笔记的模块 `README.md` 的 `## 导航` 区域。
- 更新 `docs/index.md` 的模块表。
- 不修改正文内容。

## 质量检查规则

新增、移动、删除或整理笔记后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-knowledge.ps1
```

检查内容：

- 每个一级目录都有 `README.md`。
- 模块 README 包含“模块说明 / 导航 / 学习重点 / 待整理”。
- Markdown 文件有一级标题。
- 本地 Markdown 链接能解析。
- Markdown 文件名符合英文小写短横线规则。

## Roadmap 和学习记录联动

新增知识点后，如果对应主题已经在 `docs/roadmap.md` 中，询问是否标记为学习中或已完成。

新增知识点后，可以询问是否创建学习记录。用户同意后，在 `docs/learning-records/` 中创建学习记录，并在记录中链接回知识点。

## AI 生成内容规则

当只需要创建 Markdown 文件时，先使用模板生成空骨架。

当用户希望生成相关知识点内容时，需要先确认用户同意。用户同意后再补充正文，生成时遵守：

- 不编造项目事实。
- 不确定的内容标记为待验证。
- 技术结论尽量写清适用条件。
- 面试内容区分“简答版”和“深入追问”。

## 拆分规则

一个 Markdown 文件只记录一个相对明确的知识点。出现下面情况时优先拆分：

- 同一文件开始覆盖多个独立主题。
- 代码、问题、面试、源码分析混在一起。
- 导航目录超过 8 个大章节。
- 后续内容需要持续追加。

拆分后用专题目录承载，例如：

```text
docs/coroutine/
  README.md
  coroutine-basic.md
  coroutine-exception.md
  flow-basic.md
```

## 模块补充说明

- `third-party-libraries/`：三方库使用、接入、升级和实践。
- `code-quality/`：代码规范、重构、Code Review 和可维护性。
- `debugging/`：调试方法论和工具技巧。
- `dependency-management/`：依赖治理、版本冲突、BOM 和升级策略。
- `privacy-compliance/`：权限、隐私、SDK 和应用市场合规。
- `ndk/`：JNI、C/C++、Native 崩溃、SO 和交叉编译。
- `api-design/`：接口设计、错误码、分页、幂等和兼容性。
- `system-design/`：登录态、缓存、消息、配置、离线和灰度系统设计。
