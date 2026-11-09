# Phase 0 Pester baseline (P0-T2)

Timestamp: 2026-11-09T15-50
Command: sh SCRATCH/issue-1153-pester.sh (new PowerShell 7.6.9 process in the worktree root; imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree root> with the default worker count; the launcher exits with the ExitCode property of the returned object). Counts and coverage read by sh SCRATCH/issue-1153-summary.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml.
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 575.97 s; all 8 shards exited 0; merged reports written). The run overlapped the P0-T3 pytest run on the same host.
  JUnit (testsuites root): 21052 tests, 0 failures, 0 errors, 10 disabled. Passed: 21042. Failing tests: none.
  Repo-wide line coverage (report LINE counter): 36903 covered, 1645 missed, 95.73%.
  Per-file line coverage, .claude/skills/epic-progress-report/scripts/ (the coverage report names each file under the package prefix .claude/worktrees/progress-critical-path/, the worktree-relative location of the same file):
    Get-EpicProgressReport.ps1            86/90    95.56%
    Get-EpicProgressReport.Durations.ps1  122/124  98.39%
    Get-EpicProgressReport.Gather.ps1     145/146  99.32%
    Get-EpicProgressReport.Logic.ps1      70/70    100%
    Get-EpicProgressReport.Metrics.ps1    65/65    100%
    Get-EpicProgressReport.Render.ps1     152/152  100%
    Get-EpicProgressReport.Stages.ps1     60/60    100%
    Get-EpicProgressReport.State.ps1      117/117  100%
    Get-EpicProgressReport.Steps.ps1      135/137  98.54%
