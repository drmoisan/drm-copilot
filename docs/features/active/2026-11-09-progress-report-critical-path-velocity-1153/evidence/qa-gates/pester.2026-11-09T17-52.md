# Remediation cycle 1 final Pester gate (P2-T2)

Timestamp: 2026-11-09T17-44
Command: sh SCRATCH/issue-1153-pester.sh (new PowerShell 7 process in the worktree root; imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree root> with the default worker count; the launcher exits with the ExitCode property of the returned object; the merged JUnit and coverage files were deleted before the run). Counts and coverage read by sh SCRATCH/issue-1153-summary.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml.
EXIT_CODE: 0
Output Summary:
  One run. Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 484.86 s; all 8 shards exited 0; merged reports written).
  JUnit (testsuites root): 21216 tests, 0 failures, 0 errors, 10 disabled. Passed: 21206. Failing tests: none.
  Main final gate (evidence/qa-gates/pester.2026-11-09T16-54.md): 21204 tests, 0 failures. No test that passed there fails here (0 failures in this run).
  Test-count difference +12: the cases added in P1-T4 (3 rows of `returns a non-finite average below one interval and a finite one from one interval` and `returns a non-finite average when every interval overlaps a pause span`) and P1-T5 (6 cases of Describe `Select-EpicProgressRetainedPauseSpan (CR4)`, the State.V3 case `drops a pause span ending one second before the earliest stored instant and writes one ending at it (CR4)`, and the CriticalPath case `drops a stored span ending before the start, the samples, and the anchor and prints the same velocity line (CR4)`).
  Repo-wide line coverage: 37492 covered, 1645 missed, 95.80% (main final gate 95.79%). Per-file figures: evidence/qa-gates/coverage-comparison.<timestamp>.md (P2-T3).
