# Pester Parallel Baseline (issue #1163)

Timestamp: 2026-11-10T04-07
Command: sh SCRATCH/issue-1163-pester.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one Invoke-PoshQCParallelTest run (8 workers, wall clock 2549.72 s). JUnit (artifacts/pester/pester-junit.xml): 21311 tests, 0 failures, 0 errors, 10 disabled/skipped, 714 suites. Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.80% (37558 covered, 1645 missed). Per-file line coverage of the 18 in-scope files is listed below. No pre-existing failure.

Run started after the origin/main merge recorded in pre-change-context, against unmodified production code. Counts and percentages were read from the merged JUnit and JaCoCo files with SCRATCH/issue-1163-cov.sh.

## Counts

| Metric | Value |
|---|---|
| tests | 21311 |
| failures | 0 |
| errors | 0 |
| disabled / skipped | 10 |
| test suites | 714 |
| pre-existing failing tests | none |

## Repo-wide Line Coverage

95.80% (covered 37558, missed 1645)

## Per-file Line Coverage

| Line % | Covered | Missed | File |
|---|---|---|---|
| 100.00 | 92 | 0 | `.claude/hooks/subagentstop-target-worktree.ps1` |
| 98.33 | 118 | 2 | `.claude/hooks/validate-task-researcher-output.ps1` |
| 100.00 | 80 | 0 | `.claude/hooks/validate-prd-feature-output.ps1` |
| 98.73 | 78 | 1 | `.claude/hooks/validate-required-artifact-output.ps1` |
| 99.55 | 219 | 1 | `.claude/hooks/validate-planner-output.ps1` |
| 100.00 | 164 | 0 | `.claude/hooks/validate-executor-output.ps1` |
| 93.10 | 54 | 4 | `.claude/hooks/validate-human-exception-runbook-output.ps1` |
| 95.33 | 143 | 7 | `.claude/hooks/enforce-completion-consistency.ps1` |
| 100.00 | 153 | 0 | `.codex/hooks/enforce-completion-consistency.ps1` |
| 100.00 | 71 | 0 | `.claude/hooks/enforce-file-size-limit.ps1` |
| 100.00 | 83 | 0 | `.codex/hooks/enforce-file-size-limit.ps1` |
| 100.00 | 29 | 0 | `.claude/hooks/validate-docs-role-output.ps1` |
| 93.90 | 77 | 5 | `.claude/hooks/enforce-docs-complete-gate.ps1` |
| 100.00 | 37 | 0 | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` |
| 100.00 | 146 | 0 | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` |
| 94.92 | 112 | 6 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` |
| 96.23 | 51 | 2 | `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` |
| 95.58 | 108 | 5 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` |
