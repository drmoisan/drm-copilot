# PSScriptAnalyzer Baseline (Phase 0, issue #1118)

Timestamp: 2026-11-07T21-48
Command: sh SCRATCH/issue-1118-p0-static.sh (pwsh -NoProfile -File SCRATCH/issue-1118-pssa.ps1: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information for each of the eleven files)
EXIT_CODE: 0
Output Summary:
- Total findings: 0.
- Per file (finding count, rule names):
  - .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1: 0
  - .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1: 0
  - .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1: 0
  - .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1: 0
  - .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1: 0
  - tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1: 0
