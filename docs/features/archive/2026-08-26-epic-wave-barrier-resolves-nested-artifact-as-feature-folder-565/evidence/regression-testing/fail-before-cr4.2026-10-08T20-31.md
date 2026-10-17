# Fail-Before: CR-4 Barrier Import-Failure Wording (RW17, RW18, RW19)

Timestamp: 2026-10-08T20-31
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T4.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: [expect-fail] Passed=40 Failed=3 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Exactly three FAILED: lines, for W9, C7, D7. Each fails on the new assertion because the current deny reason reads "the worktree-resolution module 'feature-folder-resolution.ps1' failed to import".

```
Passed=40 Failed=3 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: enforce-epic-wave-barrier.ps1 feature-folder resolution (issue #565).shared resolver import failure.W9: denies naming feature-folder-resolution.ps1 and guards the dot-source
FAILED: enforce-parallel-cohort-barrier.ps1 feature-folder resolution (issue #565).shared resolver import failure.C7: denies naming feature-folder-resolution.ps1 and guards the dot-source
FAILED: enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).shared resolver import failure.D7: denies naming feature-folder-resolution.ps1 and guards the dot-source
```
