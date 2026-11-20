# QA Gate: PowerShell Analyze — Issue #1093

Timestamp: 2026-11-07T00-23
Command: sh SCRATCH/issue-1093-qc.sh Analyze <19 files> (PowerShell 7: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` per file)
EXIT_CODE: 0
Output Summary: 0 findings across 19 files (the 14 files of P6-T1 plus the five bundle script copies); TOTAL_FINDINGS: 0.

| File | Findings |
|---|---|
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | 0 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | 0 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | 0 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | 0 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | 0 |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 0 |
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | 0 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 0 |
| `tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | 0 |
