# Coverage Final - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-41
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r2-p2t4.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0
Output Summary: Get-EpicProgressReport.ps1 91.18% (baseline 91.18%); Get-EpicProgressReport.Logic.ps1 100% (baseline 100%, now 218 covered lines, up from 213). Both at or above 85%. No MISSED line in ConvertFrom-EpicProgressKickoffRow; changed-line coverage 100%. Pester under coverage: Tests=821 Passed=819 Failed=0 Skipped=2.

## Printed output

```
PESTER Tests=821 Passed=819 Failed=0 Skipped=2 NotRun=0
COVERAGE scripts/dev-tools/Get-EpicProgressReport.ps1 91.18 (covered=93 missed=9)
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 201
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 215
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 229
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 302
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 466
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 467
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 468
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 470
MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 472
COVERAGE scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100 (covered=218 missed=0)
EXIT_CODE=0
```

## Comparison with baseline

| File | P0-T5 baseline (`coverage-baseline.2026-11-06T00-33.md`) | Final | Threshold |
|---|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 91.18 (93/102) | 91.18 (93/102) | >= 85: PASS |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 100 (213/213) | 100 (218/218) | >= 85: PASS |

## MISSED lines by function

| MISSED value | Function or region |
|---|---|
| 201 | `Invoke-GitExe` (executable seam body) |
| 215 | `Invoke-GhExe` (executable seam body) |
| 229 | `Invoke-CswapExe` (executable seam body) |
| 302 | `Get-EpicProgressUtcNow` (clock seam body) |
| 466, 467, 468, 470, 472 | script entry block (runs only when the script is executed directly) |

None is inside `ConvertFrom-EpicProgressKickoffRow`; the logic file has zero missed lines, so every changed line (the header gate, the `break`, the `TryParse` call, and its error path) is covered. Changed-line coverage: 100%. The missed set in the main script is identical to the baseline set.
