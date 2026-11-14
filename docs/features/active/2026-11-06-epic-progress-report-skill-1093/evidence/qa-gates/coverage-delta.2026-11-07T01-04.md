# QA Gate: Coverage Delta (loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-04
Command: comparison of `evidence/baseline/pester-coverage.2026-11-06T23-56.md` (P0-T6) with `evidence/qa-gates/pester-coverage.2026-11-07T01-04.md` (loop pass 2 after the P6-T13 self-review fix); both read from `artifacts/pester/powershell-coverage.xml` of a branch-current `Invoke-PoshQCTest` run
EXIT_CODE: 0
Output Summary: PASS. Every new or changed PowerShell production file is at or above 85 percent line coverage: entry 90.82%, Logic 100%, State 100%, Metrics 100%, Render 100%, forwarder 100%.

## Baseline (P0-T6, merged tool at the merge base)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` (merged entry) | 93 | 9 | 91.18% |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (merged Logic) | 227 | 0 | 100% |

## Post-change (loop pass 2)

| File | Status | Covered | Missed | Line coverage |
|---|---|---|---|---|
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | changed (moved entry) | 89 | 9 | 90.82% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | changed (moved, trimmed hub) | 66 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | new | 79 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | new (moved functions) | 52 | 0 | 100% |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | new (moved functions) | 102 | 0 | 100% |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | changed (forwarder) | 5 | 0 | 100% |

## Comparison

- The merged Logic file's covered lines are split across the hub, State, Metrics, and Render files; each split file is fully covered.
- Entry script: 91.18% at the baseline, 86.73% in loop pass 1, 90.82% now. Loop pass 1 left the new directory-creation and state-write lines inside `ShouldProcess` uncovered; the self-review recorded that as a FAIL on changed-line coverage, and the two mocked state-write cases added in P6-T13 cover them. The nine missed lines are the same kinds that were missed at the baseline (native wrapper invocations, the clock read, the entry-point block).
- New and changed code: the four new State functions are fully covered; the new wiring in `Invoke-EpicProgressReport` and the new lines of `Write-EpicProgressState` are executed; the forwarder's statements are all executed in process.

Verdict: PASS (every listed post-change file at or above 85 percent; no changed line that was covered at the baseline is uncovered).
