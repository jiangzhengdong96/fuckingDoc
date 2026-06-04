### 知识库维护规则

###### 目标

这个仓库用于记录 Android 开发工程师的长期技术积累。内容要方便检索、持续补充和复盘，不追求一次写满。

###### 目录分层

- `docs/<module>/README.md`：模块说明、导航、学习重点、待整理。
- `docs/<module>/<note>.md`：具体知识点笔记。
- `docs/<module>/<topic>/README.md`：内容较大的专题目录导航。
- `docs/learning-records/`：个人学习记录。
- `templates/`：笔记模板。
- `scripts/`：创建笔记和更新索引的脚本。

###### 命名规则

- 目录名优先使用英文小写加短横线，例如 `android-framework/`。
- 笔记文件名允许中文或英文，多个词之间用短横线，例如 `java基础.md`、`java基础-总结.md`、`activity-lifecycle.md`。
- 标题使用中文。普通笔记和模块 `README.md` 都使用较小标题层级，例如 `### Activity 生命周期`。
- 图片和截图放到 `assets/`，按模块继续建子目录。

###### 笔记类型和模板

| 类型    | 参数值               | 模板                                      |
| ----- | ----------------- | --------------------------------------- |
| 普通知识点 | `topic`           | `templates/topic-template.md`           |
| 问题排查  | `troubleshooting` | `templates/troubleshooting-template.md` |
| 源码阅读  | `source-reading`  | `templates/source-reading-template.md`  |
| 面试知识点 | `interview`       | `templates/interview-template.md`       |
| 学习记录  | `learning-record` | `templates/learning-record-template.md` |

###### 导航锚点规则

所有文件内导航和带 `#` 的跨文件跳转，都要使用显式 HTML anchor，不依赖 Markdown 渲染器自动生成标题锚点。

原因是中文标题、空格、斜杠、点号、括号、问号等字符在不同工具里的自动锚点规则不完全一致，容易出现点击目录无法跳转的问题。

推荐格式：

```markdown
- [知识点1](#知识点1)

<a id="知识点1"></a>
###### 知识点1
```

面试题同样适用：

```markdown
- [面试题1](#面试题1)

<a id="面试题1"></a>
###### 面试题1
```

如果是跨文件链接，例如链接目标是：

```markdown
../面试/集合面试题.md#hashmap-底层结构
```

目标文件中必须存在：

```markdown
<a id="hashmap-底层结构"></a>
###### HashMap 底层结构
```

###### 创建笔记流程

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

###### 自动索引规则

新增、移动、删除笔记后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
```

脚本会：

- 更新有实际子笔记的模块 `README.md` 的 `导航` 区域，并保留当前标题层级。
- 更新 `docs/index.md` 的模块表。
- 不修改正文内容。

###### AI 生成内容规则

当只需要创建 Markdown 文件时，先使用模板生成空骨架。

当用户希望生成相关知识点内容时，需要先确认用户同意。用户同意后再补充正文，生成时遵守：

- 不编造项目事实。
- 不确定的内容标记为待验证。
- 技术结论尽量写清适用条件。
- 面试内容区分“简答版”和“深入追问”。

更新知识点笔记时，需要同步扫描同模块下是否存在对应面试题文件。例如：

```text
docs/java/知识点梳理/集合.md -> docs/java/面试/集合面试题.md
```

- 如果知识点新增了适合面试复盘的内容，同步更新知识点内的 `面试可能怎么问` 和对应面试题文件。
- 如果对应面试题文件不存在，但该知识点明显适合面试复盘，根据本次任务范围决定创建或提示待补。
- 如果用户明确要求只改格式、只改错别字或不要更新面试内容，则不强行扩展面试题。

###### 拆分规则

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
