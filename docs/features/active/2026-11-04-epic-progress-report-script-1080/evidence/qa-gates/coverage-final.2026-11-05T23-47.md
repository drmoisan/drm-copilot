# QA Gate: Final Coverage (Issue #1080, remediation cycle 1, P2-T4)

Timestamp: 2026-11-05T23-47
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r1-p2t4.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0

## Route

Branch-current `scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCTest -ScanFolders tests/scripts/dev-tools` with an `-InvokePester` seam (JUnit and exit disabled, PassThru enabled); LINE counters read from `artifacts/pester/powershell-coverage.xml`. Pester run: Tests=818 Passed=816 Failed=0 Skipped=2 NotRun=0.

## Per-file line coverage

| File | P0-T5 baseline | Final | Threshold |
|---|---|---|---|
| scripts/dev-tools/Get-EpicProgressReport.ps1 | 90.82 (covered=89 missed=9) | 91.18 (covered=93 missed=9) | 85, met |
| scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 | 100 (covered=210 missed=0) | 100 (covered=213 missed=0) | 85, met |

## Missed lines with the function that holds them

| Line | Holder | Reason |
|---|---|---|
| 201 | Invoke-GitExe | native git call; tests never start git |
| 215 | Invoke-GhExe | native gh call; tests never start gh |
| 229 | Invoke-CswapExe | native cswap call; tests never start cswap |
| 302 | Get-EpicProgressUtcNow | real clock read; tests never read the clock |
| 466 | entry-point block (script scope) | skipped when dot-sourced |
| 467 | entry-point block (script scope) | skipped when dot-sourced |
| 468 | entry-point block (script scope) | skipped when dot-sourced |
| 470 | entry-point block (script scope) | skipped when dot-sourced |
| 472 | entry-point block (script scope) | skipped when dot-sourced |

The same nine statements were missed at baseline; the entry-point lines moved from 448-454 to 466-472 because the new seam and help added 18 lines above them. No missed line lies inside `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressSummary`, `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressLastExitCode`, or the fetch-warning statements of `Invoke-EpicProgressReport`, so changed-line coverage is 100%. Covered lines grew by 4 in the main script (seam return, exit-code read, `if`, `Write-Warning`) and by 3 in the logic file (wave-cell check, throw, invariant parse).

Output Summary: final line coverage 91.18% (93/102) for Get-EpicProgressReport.ps1 (baseline 90.82%) and 100% (213/213) for Get-EpicProgressReport.Logic.ps1 (baseline 100%); both at or above 85%; every missed line is a native wrapper, the clock seam, or the entry-point block; changed-line coverage 100%.
