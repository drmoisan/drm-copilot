# Coverage Baseline - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-33
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r2-p0t5.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0
Output Summary: Get-EpicProgressReport.ps1 line coverage 91.18% (93 covered, 9 missed); Get-EpicProgressReport.Logic.ps1 line coverage 100% (213 covered, 0 missed). Coverage read from artifacts/pester/powershell-coverage.xml written by the branch-current PoshQC module over tests/scripts/dev-tools (Tests=818 Passed=816 Failed=0 Skipped=2).

## Printed output

```
PESTER Tests=818 Passed=816 Failed=0 Skipped=2 NotRun=0
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
COVERAGE scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100 (covered=213 missed=0)
EXIT_CODE=0
```

## Missed lines by function (main script)

The `MISSED` values are run-time line positions printed by the coverage reader; the owning function is named for each.

| MISSED value | Function or region |
|---|---|
| 201 | `Invoke-GitExe` (executable seam body) |
| 215 | `Invoke-GhExe` (executable seam body) |
| 229 | `Invoke-CswapExe` (executable seam body) |
| 302 | `Get-EpicProgressUtcNow` (clock seam body) |
| 466, 467, 468, 470, 472 | script entry block (dot-source guard; runs only when the script is executed directly) |

All missed lines are thin I/O seams or the direct-execution entry block; none is in `ConvertFrom-EpicProgressKickoffRow`.
