# Fail-Before: Feature-Folder-Order Plan-Path Matching (W30, issue #568)

Timestamp: 2026-10-08T18-15
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T15.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=25 Failed=3 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The FAILED lines are exactly F1, F2, F3 (#568 timestamped plan-path regression). The P0-T20 failing set contains no line for this file. F4, F5, F6 (non-plan near-misses) pass before the fix.

```
Passed=25 Failed=3 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: enforce-feature-folder-order.ps1.issue #568 plan-path matching.F1: recognizes a timestamped plan file in an active feature folder
FAILED: enforce-feature-folder-order.ps1.issue #568 plan-path matching.F2: recognizes a timestamped plan file in an archive feature folder
FAILED: enforce-feature-folder-order.ps1.issue #568 plan-path matching.F3: denies a timestamped plan write when the prerequisite documents are missing
```
