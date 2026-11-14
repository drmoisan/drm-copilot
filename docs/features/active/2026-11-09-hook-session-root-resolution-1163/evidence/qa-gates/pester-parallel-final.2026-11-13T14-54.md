# Pester Parallel Final Gate, remediation cycle 1 (issue #1163, [P0-T1], finding F1)

Timestamp: 2026-11-13T14-37
Command: sh SCRATCH/issue-1163-pester.sh f1final (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode); counts and coverage read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1163-summary.sh; changed-line coverage of this cycle through SCRATCH/issue-1163-f1-changed-lines.sh against the pre-cycle head (the review-inputs commit "docs(1163): record feature review and light remediation inputs")
EXIT_CODE: 0
Output Summary: One Invoke-PoshQCParallelTest run on the head carrying "fix(1163): name the full stale branch in the repair detail (F1)", started 2026-11-13T14-37 and ended 2026-11-13T14-53 (8 workers, wall clock 955.78 s), exit 0, merged JUnit and coverage written at 14:53Z. JUnit: 21666 tests, 0 failures, 0 errors, 722 suites; the summary script read 0 for the disabled/skipped attribute in this run (pester-parallel-final.2026-11-13T14-09.md recorded 10 from the same script; the test and suite counts are equal). Repo-wide line coverage 95.83% (37807 covered, 1647 missed), equal to the 2026-11-13T14-09 run and above the Phase 0 baseline of 95.80% (baseline/pester-parallel.2026-11-10T04-07.md). `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` 98.77% (80 covered, 1 missed) and `.codex/hooks/agent-target-worktree.ps1` 98.72% (77 covered, 1 missed), both equal to the 2026-11-13T14-09 run (no drop) and above 85%; the one missed line in each is the default `WorktreeListInvoker` body. Changed-line coverage of this cycle: 4 of 4 instrumented changed lines covered in each of the two files (100.00%). All 20 listed files are at or above 85%, each equal to the 2026-11-13T14-09 run. SCRATCH here is the item worktree's gitignored scratch folder for issue 1163, except issue-1163-f1-changed-lines.sh, which is in the session SCRATCH. Earlier pester-parallel-final artifacts stay as history.

## Required suites confirmed in the run

| Suite | Tests | Failures |
|---|---|---|
| HookTargetWorktree.Tests.ps1 | 83 | 0 |
| hook-target-worktree.Tests.ps1 | 83 | 0 |
| hook-dependency-guard-completeness.Tests.ps1 | 731 | 0 |
| enforcement-hooks-no-python-invocation.Tests.ps1 | 35 | 0 |
| AgentTargetWorktree.Tests.ps1 | 77 | 0 |
| agent-target-worktree.Tests.ps1 | 26 | 0 |

The two F1 rows ('prunable a command branch registered only at a prunable root is not derivable and names the repair' and 'prunable a prompt branch registered only at a prunable root fails closed and names the repair') run in both of the last two suites and pass. AC-23 rows: 'S2-9 returns a rooted runbook path unchanged' and 'blocks when an exception requirement has no existing runbook (injected FileExistsCheck returns false)' passed.

## Per-file line coverage (powershell-coverage.xml), compared with 2026-11-13T14-09

| Line % | Covered | Missed | File | 14-09 % |
|---|---|---|---|---|
| 100.00 | 99 | 0 | `.claude/hooks/subagentstop-target-worktree.ps1` | 100.00 |
| 98.33 | 118 | 2 | `.claude/hooks/validate-task-researcher-output.ps1` | 98.33 |
| 100.00 | 80 | 0 | `.claude/hooks/validate-prd-feature-output.ps1` | 100.00 |
| 98.73 | 78 | 1 | `.claude/hooks/validate-required-artifact-output.ps1` | 98.73 |
| 99.55 | 219 | 1 | `.claude/hooks/validate-planner-output.ps1` | 99.55 |
| 100.00 | 164 | 0 | `.claude/hooks/validate-executor-output.ps1` | 100.00 |
| 93.10 | 54 | 4 | `.claude/hooks/validate-human-exception-runbook-output.ps1` | 93.10 |
| 95.60 | 152 | 7 | `.claude/hooks/enforce-completion-consistency.ps1` | 95.60 |
| 100.00 | 160 | 0 | `.codex/hooks/enforce-completion-consistency.ps1` | 100.00 |
| 100.00 | 79 | 0 | `.claude/hooks/enforce-file-size-limit.ps1` | 100.00 |
| 100.00 | 94 | 0 | `.codex/hooks/enforce-file-size-limit.ps1` | 100.00 |
| 100.00 | 41 | 0 | `.claude/hooks/validate-docs-role-output.ps1` | 100.00 |
| 94.57 | 87 | 5 | `.claude/hooks/enforce-docs-complete-gate.ps1` | 94.57 |
| 100.00 | 43 | 0 | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | 100.00 |
| 100.00 | 151 | 0 | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 100.00 |
| 95.12 | 117 | 6 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 95.12 |
| 96.55 | 56 | 2 | `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 96.55 |
| 95.83 | 115 | 5 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 95.83 |
| 98.77 | 80 | 1 | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | 98.77 |
| 98.72 | 77 | 1 | `.codex/hooks/agent-target-worktree.ps1` | 98.72 |
