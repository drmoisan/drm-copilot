# Pass-After: CR-4 Barrier Import-Failure Wording (RW17, RW18, RW19)

Timestamp: 2026-10-08T20-33
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T4.ps1 (same body as the fail-before run)
EXIT_CODE: 0
Output Summary: Passed=43 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Fail-before: regression-testing/fail-before-cr4.2026-10-08T20-31.md (Passed=40, Failed=3).

```
Passed=43 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
