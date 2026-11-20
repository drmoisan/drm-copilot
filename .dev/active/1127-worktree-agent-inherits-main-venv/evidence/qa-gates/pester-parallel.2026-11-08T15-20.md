# Final QA: Pester parallel gate (P4-T4)

Timestamp: 2026-11-08T15-20
Command: sh SCRATCH/issue-1127-pester.sh final (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, wall-clock 1158.25 s; run started 2026-11-08T14-59 UTC)
- Counts from artifacts/pester/pester-junit.xml: 676 suites, 19774 tests, 0 failures, 0 errors, 10 skipped (19764 passed)
- Phase 0 baseline (pester-parallel.2026-11-08T14-22.md): 674 suites, 19584 tests, 0 failures, 10 skipped. No test that passed in the baseline fails here; the 190 added tests come from the two new suites and the new rows of existing tables.
- Repo-wide line coverage from artifacts/pester/powershell-coverage.xml: 95.60% (35614 covered, 1640 missed) vs baseline 95.56% (35308 covered, 1639 missed): not below the baseline.
- Per-file line coverage of the new files:
  - .claude/hooks/worktree-poetry-venv-policy.ps1: 100% (117 of 117)
  - .claude/hooks/enforce-worktree-poetry-venv.ps1: 100% (35 of 35)
  - .codex/hooks/worktree-poetry-venv-policy.ps1: 100% (117 of 117)
  - .codex/hooks/enforce-worktree-poetry-venv.ps1: 100% (38 of 38)
- Per-file comparison with the baseline for existing files (SCRATCH/issue-1127-covdiff.ps1): one unchanged file differs. .claude/lib/orchestrator-state/OrchestratorState.psm1 went from 113 of 113 to 112 of 113 lines; the one missed line is the lazy `Import-Module` of OrchestratorStateUnconditional.psm1 inside the default `-Invoker` scriptblock, which runs only when `Get-OrchestratorStateUnconditionalError` is not already loaded in the shard process. The branch does not change that file; the line's coverage depends on which suites share a shard, and adding two test files changed the shard assignment. Recorded here, not fixed (outside the plan).
- No coverage exclusion was added for a production path (config/poshqc-coverage.json is unchanged).
