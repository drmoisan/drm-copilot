# Fail-Before: Existing Drift-Gate Suite with the Rewritten Case (W29)

Timestamp: 2026-10-08T18-12
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T12.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=47 Failed=1 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The only FAILED line is the rewritten case naming "reports two distinct folders as Ambiguous". The P0-T20 failing set contains no line for this file.

```
Passed=47 Failed=1 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: enforce-parallel-drift-gate.ps1.Find-ParallelDriftGateFeatureFolderFromPrompt helper.accepts a backslash-separated token and reports two distinct folders as Ambiguous
```
