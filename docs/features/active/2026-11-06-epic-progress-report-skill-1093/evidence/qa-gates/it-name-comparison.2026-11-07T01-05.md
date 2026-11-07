# QA Gate: It-Name Comparison (loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-05
Command: sh SCRATCH/issue-1093-itcompare.sh <two merged suites at the merge base> <five relocated and split suites under tests/scripts/claude-skills/epic-progress-report/> (PowerShell 7: AST parse of every `It` name; set comparison)
EXIT_CODE: 0
Output Summary: 106 P0-T3 names; 105 present unchanged; the only absent name is `defaults the state path under the temporary root and outside the repository`, which maps to `defaults the state path under .claude/state of the repository root`; 33 names are new (the 31 of `it-name-comparison.2026-11-07T00-59.md` plus the two P6-T13 cases); no duplicates.

| File | It count |
|---|---|
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 38 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 20 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 14 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 31 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 35 |

New since loop pass 1: `creates the missing state directory before writing the state`, `writes the state without creating an existing directory` (entry suite, `I/O seams without side effects` Describe).
