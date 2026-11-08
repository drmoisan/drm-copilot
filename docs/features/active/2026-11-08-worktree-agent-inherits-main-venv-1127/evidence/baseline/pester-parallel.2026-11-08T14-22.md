# Phase 0 baseline: Pester parallel gate (P0-T3)

Timestamp: 2026-11-08T14-22
Command: sh SCRATCH/issue-1127-pester.sh p0 (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, wall-clock 805.9 s; run started 2026-11-08T14-07 UTC)
- Counts from artifacts/pester/pester-junit.xml: 674 suites, 19584 tests, 0 failures, 0 errors, 10 skipped (19574 passed)
- Failing tests: none
- Repo-wide line coverage from artifacts/pester/powershell-coverage.xml: 95.56% (35308 covered, 1639 missed)
- Per-file baseline rows: none required. No existing production PowerShell file is modified by this plan; the four new files have no pre-change run and are judged against the 85% threshold at P4-T4.
- Baseline JUnit and coverage files copied to SCRATCH/p0-pester/ for the P4-T4 comparison.
