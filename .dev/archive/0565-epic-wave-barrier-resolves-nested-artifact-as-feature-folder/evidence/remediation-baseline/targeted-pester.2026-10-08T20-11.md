# Remediation Baseline: Targeted Pester (R-TESTS, 5 suites)

Timestamp: 2026-10-08T20-11
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T18.ps1
EXIT_CODE: 0
Output Summary: Passed=75 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. No FAILED: lines. Baseline value for P5-T6: Passed=75 (expected after remediation: 93).

```
Passed=75 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
