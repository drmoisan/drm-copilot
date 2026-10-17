# Targeted Tests: Existing Parallel Cohort Barrier Suites

Timestamp: 2026-10-08T18-41
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P4-T4.ps1
EXIT_CODE: 0
Output Summary: Passed=66 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The unchanged existing cohort-barrier suites pass against the edited hook, including the WorktreeRunResolution import-failure case with the two-module import guard.

```
Passed=66 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
