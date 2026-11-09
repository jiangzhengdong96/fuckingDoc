# 知识库协作入口

本项目是以 Android 为主、兼容其他兴趣主题的中文个人知识库，用于记录、学习、总结、生成初稿和持续纠错。

## 工作约定

- 普通提问先在对话中讲解；用户要求记录、生成、补充或修改时再落盘。明确的生成请求就是授权，只有明确要求空模板时才只建骨架。
- 同主题先搜索已有笔记，优先修订原章节。是否拆分取决于主题是否独立；需要改变既有组织方式时先说明方案。
- 讲解先给结论、最小例子和执行过程。用户看不懂时改用同一个例子的伪代码与状态变化，再按需映射源码。
- 核实用户和旧笔记的判断。纠正结论时同时检查相关摘要、示例及已有面试答案，不把矛盾说法追加到文末。
- 区分官方约定、版本实现、项目实践与推测。GitHub 示例用于对照实践，关键结论注明来源和适用条件。
- 保留无关工作区修改。生成笔记不等于已掌握；学习进度由用户决定。

## 按任务读取

- 写入或组织笔记：`.agents/skills/knowledge-note-manage/SKILL.md`。
- 解释概念、源码看不懂、练习复习：`.agents/skills/knowledge-teach/SKILL.md`。
- 核实结论、检查内容、纠错或查询 GitHub 实践：`.agents/skills/knowledge-review/SKILL.md`。
- 面试题维护：`.agents/skills/interview-note-manage/SKILL.md`。
- 目录、链接、索引与检查脚本：`.agents/skills/knowledge-check/SKILL.md`。
- 用户要求复盘工作流，或当前会话反复出现重复建文档、漏同步、解释过深等问题：读取 `.agents/references/workflow-retro.md`。
- 落盘前读取 `docs/knowledge-rules.md`；查询外部证据时读取 `.agents/references/research.md`。

## 完成条件

文档改动后按 `knowledge-check` 执行生成与检查，检查差异并说明验证范围。结构检查不能证明知识正确，伪代码也不能冒充已运行代码。
