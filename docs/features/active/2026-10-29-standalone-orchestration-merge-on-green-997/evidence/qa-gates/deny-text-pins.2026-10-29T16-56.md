# Deny-Text Pins (issue #997)

Timestamp: 2026-10-29T16-56
Command: git add -- <five new files by literal path>; git grep -c -F -e 'has merge_status == "ci_green". No checkpoint' -- tests/scripts/claude-hooks .claude/hooks; git grep -l -F -e 'or a standalone per-feature checkpoint (epic_mode absent or false' -- tests/scripts/claude-hooks .claude/hooks; git status --porcelain
EXIT_CODE: 0
Output Summary:
- Prior-text search: no match (git grep exit 1, no output). The prior final deny text no longer appears under `tests/scripts/claude-hooks` or `.claude/hooks`.
- New-text search lists exactly five files: `.claude/hooks/enforce-epic-merge-gate.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`.
- Staging: the five new files (`.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`, its bundle copy, and the three new suites) were staged by literal path so `git grep` sees them; `git status --porcelain` shows them as `A ` and every other changed file as ` M`, with the feature folder untracked. Nothing was committed.
