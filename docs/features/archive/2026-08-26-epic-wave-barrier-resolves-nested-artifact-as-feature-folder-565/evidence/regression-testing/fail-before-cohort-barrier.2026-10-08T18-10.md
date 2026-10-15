# Fail-Before: Parallel Cohort Barrier Folder Resolution (W24)

Timestamp: 2026-10-08T18-10
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T10.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=4 Failed=9 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Required failures present: C2a, C2b, C3a, C3b, C7. Additional observed failures: C4a, C5a, C5b, C6b. Passing before the fix: C1, C4b, C6a, C8.

The `FAILED:` prefix `enforce-parallel-cohort-barrier.ps1 feature-folder resolution (issue #565).` is abbreviated to `...` below.

```
Passed=4 Failed=9 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: ...nested-artifact citations resolve to the target folder.C2a: allows the target folder cited together with a research artifact
FAILED: ...nested-artifact citations resolve to the target folder.C2b: allows the target folder cited together with an evidence artifact
FAILED: ...nested-artifact citations resolve to the target folder.C3a: allows a research artifact cited alone
FAILED: ...nested-artifact citations resolve to the target folder.C3b: allows an evidence artifact cited alone
FAILED: ...another run member cited alongside the target.C4a: denies as ambiguous and names both folders when no canonical issue-number line is present
FAILED: ...two non-member folders are ambiguous.C5a: denies as ambiguous and names both candidates
FAILED: ...two non-member folders are ambiguous.C5b: denies as ambiguous for the reversed order with the longer slug first
FAILED: ...tokens that truncate to fewer than four segments.C6b: denies a docs/features/active/. token as naming no folder
FAILED: ...shared resolver import failure.C7: denies naming feature-folder-resolution.ps1 and guards the dot-source
```
