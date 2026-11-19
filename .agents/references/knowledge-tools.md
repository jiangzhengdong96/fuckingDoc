# 知识库辅助工具

现有五个本地 skill 负责内容和结构；下列引入的官方 skill 提供工具操作方法，按场景加载。它们保存在项目 `.agents/skills/` 并随 Git 仓库分发；另一台机器只需另行准备程序依赖。

## 网页正文提取：defuddle

- 用户提供文章 URL，希望提取、总结或归档正文时读取 [defuddle skill](../skills/defuddle/SKILL.md)。普通概念问答无需抓取网页。
- 先执行 `defuddle --help` 确认工具，再按 skill 提取 Markdown。源码文件直接使用 GitHub/AOSP 原始内容，避免正文提取破坏代码结构。
- 提取结果作为资料，保留原 URL、标题、作者（可得时）和查阅日期。核对关键代码块、表格及上下文是否完整；提取成功不表示技术结论正确。
- 只要求讲解时在对话中处理；要求记录时先搜索同主题原文，再交给 knowledge-note-manage 更新。需要保留原始资料时沿用 `assets/<module>/`，知识正文保留自己的解释与来源。
- 动态或登录页面无法提取时使用可用浏览器读取，或说明缺失范围；不把空白输出当成功。

## Obsidian 操作：obsidian-cli

- 查询反向链接、通过应用移动/重命名笔记、检查实际渲染时读取 [obsidian-cli skill](../skills/obsidian-cli/SKILL.md)。普通 Markdown 修改仍可直接编辑文件。
- 使用 Obsidian 自带 CLI，先检查 `obsidian help` 的实际输出；命令退出码为 0 也可能失败。Windows 不在 PATH 时可定位安装目录内的 `Obsidian.com`。
- Obsidian 需运行且启用 CLI；未启用时提示“设置 → 通用 → 高级 → 命令行接口”。CLI 不可用时继续可完成的文件检索和静态检查，明确哪些应用内操作未验证。
- 操作前确认当前知识库路径，指定目标 vault/path。移动或重命名优先通过应用维护链接，完成后仍执行 knowledge-check。
- 沿用本项目 Markdown 链接、显式 HTML 锚点和自动目录。工具操作不改变正文归属、学习进度或归档规则。

## 安装来源与复现

2026-11-19 接入 Obsidian 官方仓库的两个 skill；Canvas、Bases 和 Markdown 格式 skill 暂未安装，按后续具体需求接入。

- [defuddle](https://github.com/obsidianmd/obsidian-skills/tree/main/plugins/obsidian/skills/defuddle)
- [obsidian-cli](https://github.com/obsidianmd/obsidian-skills/tree/main/plugins/obsidian/skills/obsidian-cli)
- [Obsidian CLI 官方说明](https://help.obsidian.md/cli)

克隆仓库即可获得 `.agents/skills/defuddle/SKILL.md` 和 `.agents/skills/obsidian-cli/SKILL.md`，无需重复安装用户级副本。后续更新从上述官方来源核对变更后更新项目文件，保留项目工作流约定。

Defuddle 的程序依赖另用 `npm install -g defuddle` 安装。Obsidian CLI 随桌面应用提供，不使用同名第三方 npm 包。安装 skill 不等于依赖可用，工具使用前仍检查环境。
