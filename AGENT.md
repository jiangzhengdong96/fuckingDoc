# AGENT.md

<!-- page-toc:start -->
**目录**

- [Project](#section-project)
- [Core Rules](#section-core-rules)
- [Repository Workflow](#section-repository-workflow)
- [Hooks](#section-hooks)
- [Skill Routing](#section-skill-routing)
- [Boundaries](#section-boundaries)
<!-- page-toc:end -->


<a id="section-project"></a>
## Project

This repository is a personal Android technical knowledge base. It is used for
long-term note taking, review, interview preparation, troubleshooting records,
and source-reading summaries.

<a id="section-core-rules"></a>
## Core Rules

- Write main note content in Chinese.
- Follow `docs/knowledge-rules.md` when creating, moving, deleting, or
  reorganizing notes.
- Keep each note focused on one clear knowledge point. Split large topics into
  multiple notes or a topic directory.
- Prefer existing templates under `templates/` instead of creating ad hoc note
  structures.
- Use explicit HTML anchors for in-page navigation and cross-file Markdown links
  with `#` fragments.
- Put images and screenshots under `assets/`, grouped by module when possible.
- Do not silently change personal learning progress in `docs/roadmap.md`; ask
  before marking items as learning or completed.

<a id="section-repository-workflow"></a>
## Repository Workflow

- Create new notes with `scripts/new-note.ps1` when possible.
- After adding, moving, or deleting notes, run `scripts/update-index.ps1`.
- Before finishing note maintenance work, run `scripts/check-knowledge.ps1`.
- If PowerShell execution policy blocks a script, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\<script-name>.ps1
```

<a id="section-hooks"></a>
## Hooks

- Project-local Codex hooks live in `.codex/hooks.json`.
- Hook scripts live under `.codex/hooks/`.
- The current `Stop` hook runs `.codex/hooks/knowledge-stop-check.ps1`.
- The hook only acts when knowledge-repository files changed, such as `docs/`,
  `templates/`, `AGENT.md`, `CONTRIBUTING.md`, or `.agents/skills/`.
- When triggered, it runs `scripts/update-index.ps1` and
  `scripts/check-knowledge.ps1`, then reports the result back to Codex.
- If Codex asks to review or trust project hooks, inspect them with `/hooks`
  before enabling them.

<a id="section-skill-routing"></a>
## Skill Routing

- For creating, organizing, updating, indexing, checking, or generating Markdown
  notes, use the `knowledge-note-manage` skill.
- For interview-question notes, interview review content, short-answer/deep-dive
  answer structure, or syncing topic notes to interview notes, use the
  `interview-note-manage` skill.
- For repository checks, broken Markdown links, anchor validation, README
  navigation, duplicate-note checks, or script verification, use the
  `knowledge-check` skill.
- Use skills for execution details such as module routing, duplicate checks,
  template selection, interview-note synchronization, learning-record handling,
  and final verification.

<a id="section-boundaries"></a>
## Boundaries

- Do not rewrite unrelated notes while working on a specific note.
- Preserve user-provided wording when organizing raw notes unless the user asks
  for rewriting.
- Do not generate substantial knowledge content when the user only asked to
  create an empty Markdown skeleton. Ask first.
