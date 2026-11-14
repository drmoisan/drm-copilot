# Preflight Fixes: Stage R Plan (Confirming Preflight)

Timestamp: 2026-11-07T17-42
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T12-03.md

Confirming single-pass preflight under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, after the planner revision that answered the first preflight's two defects. The fix below is a trivial defect fixed in task-adjacent text. No task was added, removed, or reordered.

1. `## Test Dispositions`, row `PRL-PARTIAL-REVERT-LINKED` | stale disposition wording after revision | The row stated that the `0006` `## Summary` is not edited, but the new [P0-T4] edits the `Merge commit:` line inside that section. The test asserts only that the `0006` summary names entry `0001`, so the disposition is unchanged. The row now states that the `0006` `## Summary` sentence naming entry `0001` is not edited and that the [P0-T4] back-fill changes only the `0006` `Merge commit:` line.

Revision checks:

- First defect (user-story criteria): [P1-T1] now adds the same five `- [ ] [R]` items to `## Acceptance Criteria` of `user-story.md` and asserts five such lines in each file. Both files currently hold zero `[R]` lines and matching criteria lists for stages A to J, and `issue.md` records `Work Mode: full-feature`.
- Second defect (merge-commit back-fill): [P0-T4] back-fills the `Merge commit:` line of entries `0004`, `0005`, and `0006`, one commit per entry with its token. PR #1110 reports state `MERGED` with a merge commit. Each of the three lines is outside every stored-patch hunk region (the only `0006` patch section on `0005` starts well below its `## Summary`), and the structure check accepts a 7-to-40-character lowercase hexadecimal identifier.
- Task-ID cross-references: every bracketed task ID in the plan names an existing task, and each reference matches the cited task's content.

Validation after the fix: the installed MCP validator and the branch-current Python CLI `plan` subcommand both passed, with the two expected G4 warnings on `--cov-branch`.
