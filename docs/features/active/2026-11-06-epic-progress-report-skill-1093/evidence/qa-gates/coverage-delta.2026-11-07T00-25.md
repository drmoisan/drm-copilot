# QA Gate: Coverage Delta — Issue #1093

Timestamp: 2026-11-07T00-25
Command: comparison of `evidence/baseline/pester-coverage.2026-11-06T23-56.md` (P0-T6) with `evidence/qa-gates/pester-coverage.2026-11-07T00-25.md` (P6-T3); both read from `artifacts/pester/powershell-coverage.xml` of a branch-current `Invoke-PoshQCTest` run
EXIT_CODE: 0
Output Summary: PASS. Every new or changed PowerShell production file is at or above 85 percent line coverage: entry 86.73%, Logic 100%, State 100%, Metrics 100%, Render 100%, forwarder 100%.

## Baseline (P0-T6, merged tool at the merge base)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` (merged entry) | 93 | 9 | 91.18% |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (merged Logic) | 227 | 0 | 100% |

## Post-change (P6-T3)

| File | Status | Covered | Missed | Line coverage |
|---|---|---|---|---|
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | changed (moved entry) | 85 | 13 | 86.73% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | changed (moved, trimmed hub) | 66 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | new | 79 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | new (moved functions) | 52 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | new (moved functions) | 102 | 0 | 100% |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | changed (forwarder) | 5 | 0 | 100% |

## Comparison

- The merged Logic file's 227 covered lines are now split across the hub (66), State (the moved `Select-EpicProgressSample` and the new functions, 79 in total), Metrics (52), and Render (102); each split file is fully covered.
- The entry script moved from 91.18% to 86.73%. Its uncovered lines are unchanged in kind (native wrapper invocations, the clock read, the state write inside `ShouldProcess`, and the entry-point block skipped when dot-sourced); the change adds the directory-creation lines inside the same `ShouldProcess` block and moves `Resolve-EpicProgressSetting` (fully covered) out of the file, which lowers the covered share. The file stays above the 85 percent threshold.
- New and changed code: `ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline`, and `Merge-EpicProgressSamplePair` are fully covered (State 100%); the new wiring in `Invoke-EpicProgressReport` (state read before git, baseline resolution, reset, pairing, combined-switch error) is executed by the entry suite; the forwarder's five statements are all executed in process.

Verdict: PASS (every listed post-change file at or above 85 percent).
