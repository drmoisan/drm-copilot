# Final Pester gate, re-run after the P6-T3 coverage test (P6-T2)

Timestamp: 2026-11-09T16-54
Command: sh SCRATCH/issue-1153-pester.sh (new PowerShell 7.6.9 process in the worktree root; imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree root> with the default worker count; the launcher exits with the ExitCode property of the returned object; the merged JUnit and coverage files were deleted before the run). Counts and coverage read by sh SCRATCH/issue-1153-summary.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml.
EXIT_CODE: 0
Output Summary:
  Re-run because P6-T3 added the State.V3 case `writes the features of a sample given as an object, sorted by issue` (Get-EpicProgressReport.State.ps1 had read 151/152 against its 100% Phase 0 figure); P6-T1 was re-run first (evidence/qa-gates/poshqc-static.2026-11-09T16-46.md).
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 480.54 s; all 8 shards exited 0; merged reports written).
  JUnit (testsuites root): 21204 tests, 0 failures, 0 errors, 10 disabled. Passed: 21194. Failing tests: none.
  Phase 0 baseline (evidence/baseline/pester.2026-11-09T15-50.md): 21052 tests, 0 failures; no test that passed there fails here.
  Repo-wide line coverage: 37475 covered, 1645 missed, 95.79% (baseline 95.73%).
