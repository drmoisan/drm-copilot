# Regression: Seeded Shuffled File Order — Issue #1093

Timestamp: 2026-11-07T00-26
Command: sh SCRATCH/issue-1093-run.sh issue-1093-shuffle.ps1 -Seed <seed> for seeds 7, 41 and 1093 (PowerShell 7, Pester 6.2.0: the seven touched suites are ordered by a Fisher-Yates shuffle driven by `[System.Random]::new(<seed>)` and run in one `Invoke-Pester` process with `Run.PassThru`; no strict mode or preference is set by the runner)
EXIT_CODE: 0
Output Summary: seed 7 161 passed 0 failed; seed 41 161 passed 0 failed; seed 1093 161 passed 0 failed. No order dependence observed.

Suite keys: SC = `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1`; LG = `.../Get-EpicProgressReport.Logic.Tests.ps1`; MT = `.../Get-EpicProgressReport.Metrics.Tests.ps1`; RD = `.../Get-EpicProgressReport.Render.Tests.ps1`; ST = `.../Get-EpicProgressReport.State.Tests.ps1`; EN = `.../Get-EpicProgressReport.Tests.ps1` (entry suite under `tests/scripts/claude-skills/epic-progress-report/`); FW = `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (forwarder suite).

| Seed | File order | Passed | Failed |
|---|---|---|---|
| 7 | ST, FW, LG, SC, RD, EN, MT | 161 | 0 |
| 41 | RD, SC, ST, FW, MT, EN, LG | 161 | 0 |
| 1093 | SC, LG, MT, ST, FW, RD, EN | 161 | 0 |

Per-container counts were identical in every seed: SC 17, LG 38, MT 20, RD 14, ST 31, EN 33, FW 8 passed, 0 failed.
