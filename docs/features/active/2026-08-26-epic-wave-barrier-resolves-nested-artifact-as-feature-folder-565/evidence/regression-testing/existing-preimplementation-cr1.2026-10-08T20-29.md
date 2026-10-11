# Existing Preimplementation Suites after the CR-1 Fix (R-EXISTING-PRE, 18 suites)

Timestamp: 2026-10-08T20-29
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @(<the 18 R-EXISTING-PRE paths, listed literally in the body>) -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T19.ps1 (identical body to the P0-T19 baseline; the full path list is recorded in remediation-baseline/existing-preimplementation-pester.2026-10-08T20-11.md)
EXIT_CODE: 0
Output Summary: Passed=769 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Passed= equals the P0-T19 baseline value (769). No existing suite was edited.

```
Passed=769 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
