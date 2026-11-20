# Pester gate, second pass (P5-T6)

Timestamp: 2026-11-14T06-41
Command: sh SCRATCH/issue-1162-pester-gate.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode); figures read by SCRATCH/issue-1162-pester-figures.ps1 from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (both written at the end of this run)
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 786.23 s, every shard exited 0, ended 2026-11-14T06-54; the merged JUnit and coverage reports were written.
- JUnit totals: tests=24321, failures=0, errors=0, disabled (skipped)=10, passed=24311. Phase 0 baseline: tests=21311, failures=0, disabled=10.
- Repository-wide line coverage: 40622 covered, 1706 missed, 95.97% (Phase 0 baseline 95.80%).
- .claude/lib/epic-wave/EpicCrossDependency.psm1 (new): 349/356 lines, 98.03%.
- .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 (new): 5/5 lines, 100.00%.
- .claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1 (new): 52/52 lines, 100.00%.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1 (new): 56/56 lines, 100.00%.
- .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1: 139/139 lines, 100.00% (baseline 136/136, 100.00%).
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1: 110/114 lines, 96.49% (baseline 107/111, 96.40%).
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1: 74/74, 100.00% (baseline 100.00%).
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1: 210/210, 100.00% (baseline 100.00%).
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CriticalPath.ps1: 116/116, 100.00% (baseline 100.00%).
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1: 226/226, 100.00% (baseline 100.00%).
- Zero failures; each new or changed PowerShell file is at or above 85% line coverage. The first pass of this gate failed and is recorded in evidence/qa-gates/pester.2026-11-14T06-37.md with its two fixes.
