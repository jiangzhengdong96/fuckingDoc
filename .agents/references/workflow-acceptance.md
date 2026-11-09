# 工作流验收场景

这些是行为验收标准；结构脚本通过不代表模型已经通过教学或事实审查测试。

| 请求 | 预期行为 |
|---|---|
| 补充到挂起函数与状态机场景详解 | 搜索并更新原文，保留锚点，不新建同题文档 |
| 源码看不懂，给伪代码 | 同一例子拆步骤，标注伪代码，按需对应源码 |
| Dialog 都没有生命周期，对吗 | 区分具体类和版本，不一概而论；要求落盘时同步原答案 |
| 只创建一个空模板 | 创建骨架，不扩写知识 |
| 按模板生成线程池知识点 | 直接生成，无需重复授权；按任务说明边界和来源 |
| 整理一个非 Android 兴趣主题 | 使用合适模块，不强加 Android 场景和面试题 |
| GitHub 上别人如何实现 | 读取具体实现，附固定链接和适用性；MCP 不可用时明确降级 |
| 我明白了 | 不自动修改 roadmap 或创建学习记录 |
| 检查链接 | 检测页内和跨文件锚点、重复 ID；不宣称技术事实已验证 |
| 复盘为什么反复新建同题笔记 | 从实际会话定位规则或触发问题，按 workflow-retro 修订原流程并补验收场景 |
| 纠正一个已有结论 | 修改原位置，检索摘要、示例和已有面试问答中的相同错误 |

规则调整完成时记录静态核对和实际运行的区别；有真实会话失败后再按 Matt retro 的思路改进规则或确定性检查。

## 本次落地核对（2026-11-09）

已静态核对上表各请求在五个 skill 和公共规则中的路由与完成条件；这不是独立模型的行为评测。已实际运行链接/锚点及 hook 的 9 个回归测试、全库结构检查和真实仓库 hook。教学是否易懂仍以之后的真实会话反馈修订。

采用的方法来自 Matt 仓库，而非整体安装工程交付流程：

- [writing-for-agents](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/writing-for-agents/SKILL.md)：单一规则来源和按需读取。
- [teach](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/teach/SKILL.md)：循序教学与反馈。
- [wait-what](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/wait-what/SKILL.md)：解释未奏效时重新组织。
- [research](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/research/SKILL.md)：原始资料和可追溯证据。
- [retro](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/retro/SKILL.md)：把反复错误转为环境改进。

这些方法已适配到项目本地 skill；全局 Matt 安装包保持原状，避免只更新路由而使未安装的工程流程失配。
