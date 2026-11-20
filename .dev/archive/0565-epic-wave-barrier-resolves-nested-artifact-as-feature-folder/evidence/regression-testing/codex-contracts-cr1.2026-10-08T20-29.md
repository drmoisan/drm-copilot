# Codex Contract Suites after the CR-1 Fix (R-CONTRACTS)

Timestamp: 2026-10-08T20-29
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1', 'tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T16.ps1
EXIT_CODE: 0
Output Summary: Passed=53 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The legacy contract suite (parse, 500-line cap, root/bundle byte identity for the changed Codex hooks) and the Codex epic runtime contract suite pass.

```
Passed=53 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
