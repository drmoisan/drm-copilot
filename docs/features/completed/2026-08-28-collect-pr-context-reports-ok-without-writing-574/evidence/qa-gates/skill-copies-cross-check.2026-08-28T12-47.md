# Phase 6 — All Six Skill Copies Carry the Freshness Cross-Check

Timestamp: 2026-08-28T12-47

Task: [P6-T3]

Command: `git grep -F -l "Freshness Cross-Check" -- .claude/skills/pr-context-artifacts/SKILL.md .github/skills/pr-context-artifacts/SKILL.md .agents/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md` (working directory: repository root)

EXIT_CODE: 0

The recorded exit code is the exit code of the `git grep` command itself, captured directly and
not from a pipeline tail.

The six files were staged with `git add` before this command ran. That staging is what makes the
check non-vacuous: `git grep` searches the index and the tracked tree, so an unstaged edit to a
tracked file would not be seen and the search would report the pre-change content.

## Output Summary

The command listed exactly six paths, one per copy:

```
.agents/skills/pr-context-artifacts/SKILL.md
.claude/skills/pr-context-artifacts/SKILL.md
.github/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md
```

Six paths, matching the six copies enumerated in the plan's "Scope of the diff" items 8 through
13. The three self-hosted copies and the three bundled copies all carry the level-3 heading
`Freshness Cross-Check`.

The literal searched for is a single-line, non-interpolated token that the plan quotes verbatim in
its "Fixed literals this plan introduces" section, so it is a literal the plan instructed the
executor to create rather than one asserted to pre-exist.

## Content check beyond the heading

Both steps are present in every copy. The added wording was verified byte-identical across the
three self-hosted copies by comparing the section text of each, ignoring trailing blank lines:
all three produced the digest `f08c5fe274763c48a41bec9b729dd496`. The only difference among the
three files is a trailing blank line in the `.claude` copy that predates this change.

The three bundled copies were then made byte-identical to their self-hosted counterparts, verified
by three `diff` invocations that each produced empty output and exited 0, as recorded in
`push-down-parity.2026-08-28T12-47.md`.

The two steps documented are:

1. **Pair identity** — the generated-context timestamp must be byte-identical in the summary and
   in the appendix.
2. **Head binding** — the head SHA recorded in both files must equal the current head of the
   branch under review.

Each copy additionally states explicitly that file existence and file modification time are not
freshness signals.
