# Pass-After: Aggregate Regression Run (W23, W24, W25, W26, W27, W29, W30)

Timestamp: 2026-10-08T19-28
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P8-T1.ps1
EXIT_CODE: 0
Output Summary: Passed=167 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. No FAILED lines, so every ID required by P1-T9..P1-T15 now passes: W2a, W2b, W3a, W3b, W7a, W9 (and W5a, W7b, W8a, W8b); C2a, C2b, C3a, C3b, C7 (and C5a); D2a, D2b, D3a, D3b, D7, D8 (and D5a); the rewritten drift-gate case; M2a, M2b, M3a, M3b, M7, M7d, M5, M9 on both surfaces; F1, F2, F3.

```
Passed=167 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
