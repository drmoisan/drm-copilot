# Targeted Tests: Get-PrdFeatureCheckpointFolder and Work-Mode Delegate (W28)

Timestamp: 2026-10-08T19-20
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P6-T11.ps1
EXIT_CODE: 0
Output Summary: Passed=10 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. K1-K6 (field present with exact-LiteralPath and -Raw invocation assertions, field missing, field empty, invalid JSON, Get-Content throwing, file absent with Get-Content not invoked) and P1-P4 (delegate behavior, including the -UnresolvedMode '' parameter filter) pass.

```
Passed=10 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
