# Existing Barrier Suites after the CR-4 Wording Change (R-EXISTING-BARRIER, 8 suites)

Timestamp: 2026-10-08T20-33
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T13.ps1
EXIT_CODE: 0
Output Summary: Passed=185 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. No existing barrier suite pins the old wording; none was edited.

```
Passed=185 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
