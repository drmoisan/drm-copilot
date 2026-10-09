# Final QC (Remediation Cycle 1, Iteration 1): Existing Suites (28 paths)

Timestamp: 2026-10-08T20-38
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @(<R-EXISTING-PRE (18), R-EXISTING-BARRIER (8), and R-CONTRACTS (2) paths, written literally in the body>) -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P5-T7.ps1 (path list identical to the union of the P0-T19 and P0-T20 bodies)
EXIT_CODE: 0
Output Summary: Passed=1007 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Passed= equals the sum of the P0-T19 (769) and P0-T20 (238) values.

```
Passed=1007 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
