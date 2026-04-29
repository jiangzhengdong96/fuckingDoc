---
name: knowledge-note-manage
description: Use this skill whenever the user wants to create, organize, update, index, check, or generate Markdown notes in this Android technical knowledge repository. Trigger on requests like 新增知识点, 记录笔记, 创建 md, 整理面试题, 问题排查记录, 源码阅读笔记, 学习记录, 更新索引, 查重, 检查文档, 标记学习进度, or maintaining docs/README navigation. This skill should be used even when the user does not explicitly name the skill, because it preserves templates, naming rules, duplicate checks, roadmap and learning-record linkage, module layout, and automatic index behavior.
---

# Knowledge Note Manage

This project skill maintains the Android technical knowledge repository.

## First Steps

1. Work from the repository root.
2. Read `docs/knowledge-rules.md` before creating or moving notes.
3. Inspect the relevant module `README.md` before deciding where a note belongs.
4. Prefer the repository scripts over hand-written file creation:
   - `scripts/new-note.ps1`
   - `scripts/update-index.ps1`
   - `scripts/check-knowledge.ps1`

## Note Types

Choose the note type from the user's intent:

| Intent | Type | Template |
|---|---|---|
| General technical knowledge point | `topic` | `templates/topic-template.md` |
| Bug, crash, build issue, runtime issue, investigation | `troubleshooting` | `templates/troubleshooting-template.md` |
| Library or framework source code reading | `source-reading` | `templates/source-reading-template.md` |
| Interview-focused knowledge point or Q&A | `interview` | `templates/interview-template.md` |
| Personal learning progress, review, daily or stage record | `learning-record` | `templates/learning-record-template.md` |

## Creation Workflow

When the user asks to create a note:

1. Determine the target module under `docs/`.
2. Determine the note type.
3. Search for similar existing notes by title, slug, and nearby keywords.
4. If a similar note exists, ask whether to append/organize the existing note or create a separate note.
5. Generate an English lowercase kebab-case slug.
6. Create the note with `scripts/new-note.ps1`.
7. Let the script update `docs/index.md` and module navigation.
8. Ask whether to generate substantial knowledge content if the user did not explicitly request it.
9. Ask whether to create a learning record or update `docs/roadmap.md` when the note represents active learning progress.
10. Run the quality check before the final response.

Example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module kotlin -Title "协程异常处理" -Slug coroutine-exception -Type topic
```

For learning records, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new-note.ps1 -Module learning-records -Title "协程学习记录" -Slug coroutine-learning -Type learning-record
```

## Content Generation Rule

If the user only asks to create a Markdown note, create a template-filled skeleton first.

Before generating substantial knowledge content, ask whether they want the content generated. A concise question is enough, for example:

> 要不要我顺手把这篇的核心知识点也先生成一版？

Only generate the knowledge content after the user agrees, unless they already explicitly asked for generated content in the same request.

When generating content:

- Preserve any user-provided content.
- Do not invent project-specific facts.
- Mark uncertain details as `待验证`.
- Keep one file focused on one knowledge point.
- Split large topics into multiple notes or a topic directory.
- For interview notes, include both short-answer and deeper follow-up sections.

## Indexing Rules

After adding, moving, or deleting notes, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-index.ps1
```

The script refreshes:

- `docs/index.md`
- `## 导航` sections for modules that contain actual child notes or topic directories

Do not manually duplicate index logic unless the script fails. If it fails, fix the script or explain the blocker.

## Quality Check Rules

Before final response after creating, moving, or deleting notes, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-knowledge.ps1
```

The check verifies module README structure, level-1 headings, local Markdown links, and lowercase kebab-case file names.

If the check fails, fix issues that are part of the current task. If the failure comes from unrelated existing user work, report it clearly and do not rewrite unrelated content.

## Learning Progress Rules

When a note represents something the user is currently learning:

- Offer to create a matching note under `docs/learning-records/`.
- If the user agrees, create it with `Type learning-record`.
- Link the learning record back to the knowledge note.
- If the topic exists in `docs/roadmap.md`, offer to mark it as `[-]` learning or `[x]` completed.

Do not change `docs/roadmap.md` silently. It is a personal progress tracker, so ask before changing status.

## Module Routing

Use the existing module list under `docs/` as the source of truth. Common routing:

- Android app APIs and components: `android`
- Android system internals: `android-framework`
- View drawing, touch, animation: `ui-rendering`
- API contracts, pagination, idempotency, compatibility: `api-design`
- Code review, refactoring, maintainability: `code-quality`
- Kotlin language: `kotlin`
- Coroutines and Flow: `coroutine`
- Java language: `java`
- JVM, ART, GC, class loading, JMM: `jvm`
- Threads, locks, CAS, thread pools: `concurrency`
- Architecture patterns: `architecture`
- Design patterns: `design-patterns`
- Jetpack libraries: `jetpack`
- Compose: `compose`
- Performance: `performance`
- Android network libraries: `network`
- TCP/IP, HTTP, HTTPS, DNS, TLS: `computer-network`
- Local storage: `database`
- Debugging methods and tool workflows: `debugging`
- Dependency governance, BOM, version conflicts: `dependency-management`
- App security: `security`
- Gradle and AGP: `gradle`
- General build concepts: `build-system`
- Tools and commands: `tools`
- Git: `git`
- Linux and Shell: `linux`
- Testing: `testing`
- CI/CD: `ci-cd`
- Logs, Crash, ANR, metrics: `observability`
- Release management: `release`
- Privacy, permission, SDK, app-store compliance: `privacy-compliance`
- NDK, JNI, C/C++, native crashes, SO: `ndk`
- Third-party library usage and practice: `third-party-libraries`
- Larger client/business system design: `system-design`
- Algorithms: `algorithms`
- Computer science basics: `computer-science`
- Source reading: `source-reading`
- Interview notes: `interview`
- Troubleshooting records: `troubleshooting`
- Project retrospectives: `project-review`
- Reusable snippets: `snippets`
- Learning progress records: `learning-records`

If two modules fit, choose the module that matches the primary purpose. For example, "OkHttp interceptor usage" belongs in `network`, while "OkHttp interceptor chain source reading" belongs in `source-reading`.

## Completion Checklist

Before final response:

- The target note exists and uses the correct template.
- `docs/index.md` is refreshed.
- The relevant module README navigation is refreshed when there is an actual child note.
- Any content generation was explicitly requested or approved.
- Duplicate handling was considered before creating a new note.
- Learning record and roadmap updates were offered when relevant.
- `scripts/check-knowledge.ps1` passes or any unrelated failure is reported.
- The final response lists created and updated files concisely.
