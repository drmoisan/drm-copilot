# Fail-Before: Parallel Drift Gate Folder Resolution (W25)

Timestamp: 2026-10-08T18-11
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T11.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=3 Failed=10 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Required failures present: D2a, D2b, D3a, D3b, D7, D8. Additional observed failures: D4a, D5a, D5b, D6b. Passing before the fix: D1, D4b, D6a.

The `FAILED:` prefix `enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).` is abbreviated to `...` below.

```
Passed=3 Failed=10 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: ...nested-artifact citations resolve to the target folder.D2a: allows the target folder cited together with a research artifact
FAILED: ...nested-artifact citations resolve to the target folder.D2b: allows the target folder cited together with an evidence artifact
FAILED: ...nested-artifact citations resolve to the target folder.D3a: allows a research artifact cited alone
FAILED: ...nested-artifact citations resolve to the target folder.D3b: allows an evidence artifact cited alone
FAILED: ...another run item cited alongside the target.D4a: denies as ambiguous and names both folders when no canonical issue-number line is present
FAILED: ...two non-member folders are ambiguous.D5a: denies as ambiguous and names both candidates
FAILED: ...two non-member folders are ambiguous.D5b: denies as ambiguous for the reversed order with the longer slug first
FAILED: ...tokens that truncate to fewer than four segments.D6b: denies a docs/features/active/. token as naming no folder
FAILED: ...shared resolver import failure.D7: denies naming feature-folder-resolution.ps1 and guards the dot-source
FAILED: ...the finding-presence probe receives the resolved basename.D8: probes the target folder, not the nested evidence kind, for an unresolved drift event
```
