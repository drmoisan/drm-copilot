# Coverage Baseline — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-08
Task: P0-T5
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r3-p0t5.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0
Output Summary: Get-EpicProgressReport.ps1 line coverage 91.18% (covered=93 missed=9); Get-EpicProgressReport.Logic.ps1 100% (covered=218 missed=0). Pester over tests/scripts/dev-tools: Tests=821 Passed=819 Failed=0 Skipped=2. Source: artifacts/pester/powershell-coverage.xml from the branch-current PoshQC module.

## Printed lines

```text
PESTER Tests=821 Passed=819 Failed=0 Skipped=2 NotRun=0
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
COVERAGE scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100 (covered=218 missed=0)
EXIT_CODE=0
```

## Missed lines by holder

| Missed line | Holder |
|---|---|
| 202 | `Invoke-GitExe` (native `git` call; mocked in tests) |
| 216 | `Invoke-GhExe` (native `gh` call; mocked in tests) |
| 230 | `Invoke-CswapExe` (native `cswap` call; mocked in tests) |
| 303 | `Get-EpicProgressUtcNow` (clock seam; mocked in tests) |
| 467, 468, 469, 471, 473 | script entry point after the function definitions (Push-Location, call, Pop-Location; not run when the tests dot-source the script) |

No missed line lies in `ConvertFrom-EpicProgressKickoffRow`.
