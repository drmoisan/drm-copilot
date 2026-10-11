# Targeted Tests: Shared Resolver, Codex Surface (W22)

Timestamp: 2026-10-08T18-26
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P2-T8.ps1
EXIT_CODE: 0
Output Summary: Passed=61 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The Codex copy (.codex/hooks/feature-folder-resolution.ps1) passes all 34 CAT-SR IDs, including H01 hash equality; no FAILED lines.

```
Passed=61 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
