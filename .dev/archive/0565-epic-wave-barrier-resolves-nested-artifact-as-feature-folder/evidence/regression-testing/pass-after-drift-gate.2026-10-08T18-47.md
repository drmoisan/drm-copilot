# Pass-After: Parallel Drift Gate Folder Resolution (W25)

Timestamp: 2026-10-08T18-47
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P4-T8.ps1
EXIT_CODE: 0
Output Summary: Passed=13 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. All 13 CAT-DG cases pass, including D8 (the finding probe receives the resolved basename for a nested evidence citation). Fail-before reference: regression-testing/fail-before-drift-gate.2026-10-08T18-11.md (10 failed).

```
Passed=13 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
