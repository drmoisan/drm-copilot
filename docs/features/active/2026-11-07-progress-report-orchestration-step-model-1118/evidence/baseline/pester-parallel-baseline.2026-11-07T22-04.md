# Pester Parallel Baseline (Phase 0, issue #1118)

Timestamp: 2026-11-07T22-04
Command: sh SCRATCH/issue-1118-pester.sh baseline (pwsh -NoProfile -File SCRATCH/issue-1118-pester.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode), then sh SCRATCH/issue-1118-pester-summary.sh (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- Run: 8 shard processes, every shard exited 0, wall-clock 562.19 s; merged JUnit and coverage written.
- Counts (artifacts/pester/pester-junit.xml): 544 containers, 15994 tests, 15984 passed, 0 failed, 0 errors, 10 skipped.
- Failing containers: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml, LINE counter): 24578 covered, 1540 missed, 94.1%.
- Line coverage of the five skill scripts (.claude/skills/epic-progress-report/scripts/):
  - Get-EpicProgressReport.ps1: 89 covered, 9 missed, 90.82%
  - Get-EpicProgressReport.Logic.ps1: 66 covered, 0 missed, 100%
  - Get-EpicProgressReport.Metrics.ps1: 52 covered, 0 missed, 100%
  - Get-EpicProgressReport.Render.ps1: 102 covered, 0 missed, 100%
  - Get-EpicProgressReport.State.ps1: 79 covered, 0 missed, 100%
- Forwarder scripts/dev-tools/Get-EpicProgressReport.ps1: 5 covered, 0 missed, 100%.
