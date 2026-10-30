# Preflight Fixes (issue #1009)

Timestamp: 2026-10-30T12-51
Plan: docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/plan.2026-10-30T08-09.md

Each fix below edits task text only. No task was added, removed, or reordered, and no asserted value changed.

1. [P0-T2] | citation / brief reference | The R7 precondition now cites the exemption in the brief's `## Batch Budget` and states that the checkpoint the hooks read is the one in the worktree holding the executing session's hook scripts (the item worktree for a non-isolated execution delegation).
2. [P0-T3] | stale citation | "`.claude/hooks/enforce-batch-budget-route.ps1` (three copies)" corrected to four copies (`.claude/hooks/`, `.codex/hooks/`, and both bundles); all four exist in the tree and share one SHA-256.
3. Phase 1 preamble | validator-blind portability (Windows `Join-Path` separators) | Seams compare received paths after replacing `\` with `/`, so the checkpoint-path match under a slash-rooted synthetic root holds on Windows and Linux.
4. [P2-T7] | literal formatting | "key equality" clarified to algorithm equality: the `Get-PythonBatchBudgetSessionId` fallback is `worktree-` followed by the key; the mandatory `-SessionIdFilePath` argument is named.
5. [P7-T1] | citation completeness | The verbatim-preservation clause now also names `test_brief_preflight_classes_include_changed_existing_behavior` and `test_brief_preflight_classes_include_brief_maintenance`, which pin phrases in the `## Preflight Defect Classes the Validator Cannot See` section that this task edits.
6. [P9-T1] | write-mode observation that cannot fail (G7 class) | `git status --porcelain` before and after the formatter does not change when an already-modified file is rewritten; the observation is now the SHA-256 of each formatted file before and after.
7. [P4-T3], [P4-T4], [P9-T5] | Pester CI job citation | Named the CI jobs that run the suites (`poshqc / PowerShell QC`, and `poshqc / PowerShell hook suites (Linux)` for `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`).
8. [P9-T16] | unanchored-scope wording | The self-review diff `origin/main...HEAD` omits uncommitted and untracked changes; it now covers the diff from MOVED-BASE to the working tree plus untracked files from `git status --porcelain`.
