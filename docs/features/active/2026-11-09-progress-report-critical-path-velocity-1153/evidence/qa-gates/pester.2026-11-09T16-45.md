# Final Pester gate (P6-T2)

Timestamp: 2026-11-09T16-45
Command: sh SCRATCH/issue-1153-pester.sh (new PowerShell 7.6.9 process in the worktree root; imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree root> with the default worker count; the launcher exits with the ExitCode property of the returned object; the merged JUnit and coverage files were deleted before the run so no older report could be read). Counts and coverage read by sh SCRATCH/issue-1153-summary.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml.
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 487.78 s; all 8 shards exited 0; merged reports written).
  JUnit (testsuites root): 21203 tests, 0 failures, 0 errors, 10 disabled. Passed: 21193. Failing tests: none.
  Phase 0 baseline (evidence/baseline/pester.2026-11-09T15-50.md): 21052 tests, 0 failures, 10 disabled; no test that passed there fails here (0 failures in this run).
  Repo-wide line coverage (report LINE counter): 37474 covered, 1646 missed, 95.79% (baseline 95.73%).
  Per-file line coverage of .claude/skills/epic-progress-report/scripts/ is compared with the baseline in evidence/qa-gates/coverage-comparison.<timestamp>.md (P6-T3).
