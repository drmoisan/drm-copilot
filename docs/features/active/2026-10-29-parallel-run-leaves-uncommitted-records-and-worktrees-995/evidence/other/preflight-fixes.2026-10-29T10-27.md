# Preflight Fixes

Timestamp: 2026-10-29T10-27
Plan: docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/plan.2026-10-29T05-58.md

## Fixes

1. [P4-T1] | acceptance made satisfiable | The [P1-T6] staging check keys on the capitalized word `Never`, while P4-T1 wrote lowercase `never`. P4-T1 now states that the sentence forbidding `git add -A` and `git add .` opens with `Never`.
2. [P6-T1] | unobservable write-mode acceptance | A formatter rewriting an already-modified or untracked file leaves `git status --porcelain` unchanged, so identical status listings could not fail. The task now also records `git hash-object` values of every new and changed PowerShell file before and after, and requires both hash lists to match. Meaning (formatter makes no change) is unchanged.
3. [P3-T5] | validator-blind search class (git grep on untracked file) | The family search now uses plain `grep -r`, because `WorktreeRunRecordPath.psm1` is untracked until committed and invisible to `git grep`.

## Checks with no defect found

- Plan validator (Python CLI, plan subcommand): passed, exit 0, no warnings.
- Spec carries 20 acceptance criteria, matching AC-1 through AC-20.
- Cited functions, contexts, tests (B3, B5, B11, B12, B14, U1 to U3, X1), headings, and files exist; Test-WorktreeRunPathEqual is not exported and has no external caller or test.
- Other callers of Resolve-WorktreeRunTargetByRecord use pr_number only, so the worktree_path change reaches only the two removal gates.
- Codex hook is independent of the .claude lib; no Codex agent variant exists for parallel-orchestrator.
- Hyphen-leading patterns, CRLF fixtures, jest thresholds: none present. No TypeScript change.
