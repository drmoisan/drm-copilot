# Targeted Tests: Existing Epic Wave Barrier Suites

Timestamp: 2026-10-08T18-34
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P3-T4.ps1
EXIT_CODE: 0
Output Summary: Passed=39 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The unchanged existing wave-barrier suites pass against the edited hook.

```
Passed=39 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
