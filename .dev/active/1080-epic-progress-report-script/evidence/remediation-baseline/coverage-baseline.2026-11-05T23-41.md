# Coverage Baseline (Issue #1080, remediation cycle 1, P0-T5)

Timestamp: 2026-11-05T23-41
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-r1-p0t5.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
EXIT_CODE: 0

## Route

Branch-current `scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCTest -ScanFolders tests/scripts/dev-tools` with an `-InvokePester` seam (JUnit and exit disabled, PassThru enabled); per-file LINE counters and uncovered lines read from `artifacts/pester/powershell-coverage.xml` (JaCoCo, gitignored).

## Printed output

- PESTER Tests=811 Passed=809 Failed=0 Skipped=2 NotRun=0
- COVERAGE scripts/dev-tools/Get-EpicProgressReport.ps1 90.82 (covered=89 missed=9)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 201 (Invoke-GitExe native call)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 215 (Invoke-GhExe native call)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 229 (Invoke-CswapExe native call)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 302 (Get-EpicProgressUtcNow clock read)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 448 (entry-point block)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 449 (entry-point block)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 450 (entry-point block)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 452 (entry-point block)
- MISSED scripts/dev-tools/Get-EpicProgressReport.ps1 454 (entry-point block)
- COVERAGE scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100 (covered=210 missed=0)

Output Summary: baseline line coverage 90.82% (89/98) for Get-EpicProgressReport.ps1 and 100% (210/210) for Get-EpicProgressReport.Logic.ps1; the nine missed lines are the three native wrappers, the clock seam, and the entry-point block; 811 dev-tools tests, 0 failed.
