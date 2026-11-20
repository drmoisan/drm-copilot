# Pester Phase 0 baseline (issue #1162)

Timestamp: 2026-11-11T04-32
Command: sh SCRATCH/issue-1162-pester.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode); figures read by SCRATCH/issue-1162-pester-figures.ps1 from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 1758.23 s, every shard exited 0; the merged JUnit and coverage reports were written.
- JUnit totals: tests=21311, failures=0, errors=0, disabled (skipped)=10, passed=21301.
- Pre-existing failures: none (0 failures, 0 errors).
- Repository-wide line coverage: 37558 covered, 1645 missed, 95.80%.
- .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1: 136/136 lines, 100.00%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1: 107/111 lines, 96.40%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1: 73/73 lines, 100.00%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1: 203/203 lines, 100.00%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CriticalPath.ps1: 102/102 lines, 100.00%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1: 222/222 lines, 100.00%.
- The run started at 2026-11-11T03-59 UTC on a fresh tree; the earlier interrupted run's shard output was replaced by this run.
