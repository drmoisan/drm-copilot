# Pass-After: Feature-Folder-Order (W30, issue #568)

Timestamp: 2026-10-08T19-14
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P6-T7.ps1
EXIT_CODE: 0
Output Summary: Passed=44 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. F1-F3, which failed in regression-testing/fail-before-feature-folder-order.2026-10-08T18-15.md, now pass; F4-F19 and E1-E3 pass; the pre-existing cases pass with the issue-content seam mocked.

```
Passed=44 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
