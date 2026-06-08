---
name: interview-note-manage
description: Use this skill when maintaining interview-focused Markdown notes in this Android technical knowledge repository. Trigger on requests like 整理面试题, 生成面试题, 面试复盘, 简答版, 深入追问, 高频面试点, 同步知识点到面试题, or updating docs/<module>/面试/*.md.
---

# Interview Note Manage

This skill handles interview-focused notes and interview synchronization.

## First Steps

1. Work from the repository root.
2. Read `AGENT.md` and `docs/knowledge-rules.md`.
3. Inspect the related module README and nearby notes before creating or editing
   interview content.
4. If the task starts from a knowledge note, find the matching interview note in
   the same module, for example:

```text
docs/java/知识点梳理/集合.md -> docs/java/面试/集合面试题.md
```

## Interview Note Structure

- Use `templates/interview-template.md` for new interview notes.
- Keep question navigation near the top.
- Every question in navigation must point to an explicit HTML anchor.
- Each question section should use a small heading, usually `###### 面试题`.
- Prefer this answer rhythm:
  - 简答版：先给可直接面试回答的短答案。
  - 深入追问：再补原理、边界、常见坑和关联知识点。

## Content Rules

- Do not invent project-specific facts.
- Mark uncertain details as `待验证`.
- Keep answers useful for Android interview review, not generic encyclopedia text.
- Link back to corresponding knowledge-point notes when it helps review.
- If the user only asked for formatting or typo fixes, do not expand interview
  content silently.

## Sync Rules

When a topic note gains interview-worthy content:

- Update the topic note's `###### 面试可能怎么问` section.
- Update or create the matching interview note when the user requested broad
  content maintenance.
- Ask before creating a new interview note when the user's request was narrow.

## Verification

After creating, moving, or editing interview notes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-knowledge.ps1
```

If failures are unrelated to the current task, report them without rewriting
unrelated notes.
