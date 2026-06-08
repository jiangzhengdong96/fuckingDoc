---
name: knowledge-check
description: Use this skill when checking, validating, or cleaning this Markdown knowledge repository. Trigger on requests like 检查文档, 检查链接, 检查锚点, 更新索引, 查重, 检查 README 导航, 修复本地 Markdown 链接, validate notes, or run repository quality checks.
---

# Knowledge Check

This skill verifies repository health after note maintenance.

## First Steps

1. Work from the repository root.
2. Read `AGENT.md` and `docs/knowledge-rules.md`.
3. Check the relevant module before making fixes.
4. Keep fixes scoped to the current task.

## Standard Commands

Refresh generated navigation after adding, moving, or deleting notes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
```

Run repository validation before finishing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-knowledge.ps1
```

## Manual Checks

When script output is not enough, inspect:

- Broken local Markdown links.
- Cross-file links with `#` fragments.
- Missing explicit HTML anchors before linked headings.
- Module `README.md` navigation drift.
- Duplicate notes with similar title, slug, or nearby keywords.
- Notes that cover too many independent topics and should be split.

## Fix Rules

- Prefer fixing the script or the source Markdown rather than manually editing
  generated navigation.
- Do not rewrite unrelated note content.
- If validation failures come from existing unrelated work, report them clearly.
- If a note should be split, propose the split first unless the user asked for a
  full reorganization.

## Completion

Final responses should mention:

- Which checks were run.
- Which files were changed.
- Whether remaining failures are related or unrelated.
