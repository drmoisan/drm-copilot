# Coverage Gate — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-16
Task: P2-T4
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r3-p2t4.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0
Output Summary: Get-EpicProgressReport.ps1 91.18% (93/102; baseline 91.18%); Get-EpicProgressReport.Logic.ps1 100% (227/227; baseline 100%, 218/218). Both at or above 85%. No MISSED line inside ConvertFrom-EpicProgressKickoffRow: changed-line coverage 100%. Pester over tests/scripts/dev-tools: Tests=828 Passed=826 Failed=0 Skipped=2.

## Printed lines

```text
PESTER Tests=828 Passed=826 Failed=0 Skipped=2 NotRun=0
COVERAGE scripts/dev-tools/Get-EpicProgressReport.ps1 91.18 (covered=93 missed=9)
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 202
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 216
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 230
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 303
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 467
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 468
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 469
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 471
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 473
COVERAGE scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100 (covered=227 missed=0)
EXIT_CODE=0
```

## Baseline comparison

| File | P0-T5 baseline | Final | Threshold |
|---|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 91.18 (93/102) | 91.18 (93/102) | 85 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 100 (218/218) | 100 (227/227) | 85 |

The logic file gained 9 instrumented lines (the trim, the cell count and its adjustment, the two count-check lines, the two blank-plan lines, and the two post-loop lines); all are covered.

## MISSED lines by holder

| Missed line | Function |
|---|---|
| 202 | `Invoke-GitExe` |
| 216 | `Invoke-GhExe` |
| 230 | `Invoke-CswapExe` |
| 303 | `Get-EpicProgressUtcNow` |
| 467, 468, 469, 471, 473 | script entry point (top level, outside any function) |

None is inside `ConvertFrom-EpicProgressKickoffRow`. The set is identical to the P0-T5 baseline.
