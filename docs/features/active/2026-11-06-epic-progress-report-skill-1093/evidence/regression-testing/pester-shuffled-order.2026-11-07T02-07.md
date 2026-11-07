# Regression: Seeded Shuffled File Order (remediation cycle 1) — Issue #1093

Timestamp: 2026-11-07T02-07
Command: sh SCRATCH/issue-1093-run.sh issue-1093-shuffle.ps1 -Seed <seed> for seeds 7, 41 and 1093 (PowerShell 7, Pester 6.2.0: the seven touched suites ordered by a Fisher-Yates shuffle driven by `[System.Random]::new(<seed>)` and run in one `Invoke-Pester` process; counts from the result object; the runner sets no strict mode or preference)
EXIT_CODE: 0
Output Summary: seed 7 164 passed 0 failed; seed 41 164 passed 0 failed; seed 1093 164 passed 0 failed. Run after the F1 entry-suite case was added; no order dependence observed.

Suite keys: SC = `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1`; LG = `.../Get-EpicProgressReport.Logic.Tests.ps1`; MT = `.../Get-EpicProgressReport.Metrics.Tests.ps1`; RD = `.../Get-EpicProgressReport.Render.Tests.ps1`; ST = `.../Get-EpicProgressReport.State.Tests.ps1`; EN = `.../Get-EpicProgressReport.Tests.ps1` (`ENTRY_SUITE`); FW = `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (forwarder suite).

| Seed | File order | Passed | Failed |
|---|---|---|---|
| 7 | ST, FW, LG, SC, RD, EN, MT | 164 | 0 |
| 41 | RD, SC, ST, FW, MT, EN, LG | 164 | 0 |
| 1093 | SC, LG, MT, ST, FW, RD, EN | 164 | 0 |

Per-container counts were identical in every seed: SC 17, LG 38, MT 20, RD 14, ST 31, EN 36, FW 8 passed, 0 failed.
