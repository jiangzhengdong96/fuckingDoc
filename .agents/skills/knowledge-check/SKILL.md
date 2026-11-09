---
name: knowledge-check
description: 检查知识库目录、链接、锚点、索引或修改文档后的结构验证时使用；事实正确性由 knowledge-review 处理。
---

# 知识库结构检查

1. 检查工作区差异，识别本次修改及用户已有编辑。
2. 文档更新后运行：
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update-index.ps1
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-knowledge.ps1
   ```
3. 修改校验脚本时另运行 `python -m unittest discover -s scripts/tests`。检查 `git diff --check`。
4. 查看生成差异；修复本次引入的问题，既有无关问题单独报告。不要用整体还原覆盖用户修改。
5. 按 `.agents/references/workflow-acceptance.md` 核对规则变更后的典型请求行为。

检查覆盖文件结构、Markdown 行内/引用式链接、文件及显式锚点存在性和重复锚点；忽略代码块里的示例链接。外部 URL 可访问性、技术结论和运行行为不由结构脚本证明。

完成条件：检查成功，或明确列出剩余问题及其归属；报告不夸大验证范围。
