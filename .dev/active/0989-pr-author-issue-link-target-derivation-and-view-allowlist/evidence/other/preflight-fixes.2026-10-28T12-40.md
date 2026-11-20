# Preflight Fixes (Round 2)

Timestamp: 2026-10-28T12-40
Plan: docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/plan.2026-10-28T07-38.md

## Fix 1 — [P4-T3]

- Defect class: validator-blind literal-formatting defect that does not change what is asserted.
- Finding: PC-03 to PC-06 read a section through `Get-SkillSection`, which collapses whitespace, and assert each literal with `.Contains`. A literal written with inner code spans, for example `--head` and `gh pr edit` each in its own span, places backticks inside the asserted run, so the row fails although the prose states the same thing.
- Change: the task now states that each PC-asserted literal is written as one contiguous run with no backtick inside it, and that a code span around the whole literal is permitted. No PC row, token, or acceptance condition changed.

## Fix 2 — [P4-T4]

- Defect class: validator-blind literal-formatting defect that does not change what is asserted (same mechanism as Fix 1, applied to `.claude/agents/pr-author.md`).
- Change: the `--head` section update now names the same contiguous-literal rule. No PC row, token, or acceptance condition changed.
