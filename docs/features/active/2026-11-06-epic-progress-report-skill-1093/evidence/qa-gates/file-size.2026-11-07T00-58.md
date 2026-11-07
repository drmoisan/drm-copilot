# QA Gate: Physical Line Counts — Issue #1093

Timestamp: 2026-11-07T00-58
Command: sh SCRATCH/issue-1093-lines.sh <24 files> (PowerShell 7: `@(Get-Content -LiteralPath <path>).Count` per file)
EXIT_CODE: 0
Output Summary: every production and test file created or changed by this branch is below 700 physical lines; the largest is the entry suite at 533 and the largest production file is the canonical entry at 475.

## PowerShell production files

| File | Lines |
|---|---|
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | 475 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | 248 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | 286 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | 232 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | 196 |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` (forwarder) | 18 |
| bundle copy `.../Get-EpicProgressReport.ps1` | 475 |
| bundle copy `.../Get-EpicProgressReport.Logic.ps1` | 248 |
| bundle copy `.../Get-EpicProgressReport.State.ps1` | 286 |
| bundle copy `.../Get-EpicProgressReport.Metrics.ps1` | 232 |
| bundle copy `.../Get-EpicProgressReport.Render.ps1` | 196 |

Bundle copies are under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/`.

## Test files and fixture

| File | Lines |
|---|---|
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 323 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 188 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 202 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 338 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 533 |
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | 252 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (forwarder suite) | 121 |
| `tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1` | 39 |

## Skill, configuration and documentation

| File | Lines |
|---|---|
| `.claude/skills/epic-progress-report/SKILL.md` | 338 |
| bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md` | 338 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 295 |
| `config/poshqc-coverage.json` | 12 |
| `extensions/drm-copilot/CHANGELOG.md` | 76 |

The baseline Logic suite (702 lines) is split into the Logic, Metrics, Render and State suites, all below 500 lines.
