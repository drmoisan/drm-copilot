# Pass-After: Parallel Cohort Barrier Folder Resolution (W24)

Timestamp: 2026-10-08T18-41
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P4-T3.ps1
EXIT_CODE: 0
Output Summary: Passed=13 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. All 13 CAT-CB cases pass, including C4b (the canonical issue-number line resolves the otherwise ambiguous pair). Fail-before reference: regression-testing/fail-before-cohort-barrier.2026-10-08T18-10.md (9 failed).

```
Passed=13 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
