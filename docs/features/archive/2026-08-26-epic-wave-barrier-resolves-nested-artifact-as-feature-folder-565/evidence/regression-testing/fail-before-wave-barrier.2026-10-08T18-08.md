# Fail-Before: Epic Wave Barrier Folder Resolution (W23)

Timestamp: 2026-10-08T18-08
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T9.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=3 Failed=14 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Required failures present: W2a, W2b, W3a, W3b (nested-artifact matrix), W9 (no guarded dot-source exists yet), W7a (#621/#508: the longest token is the 508 upstream plan citation ending in ';', whose basename matches no record). Additional observed failures: W4a, W4b, W5a, W5b, W6b, W7b, W8a, W10. Passing before the fix: W1, W6a, W8b.

The `FAILED:` prefix `enforce-epic-wave-barrier.ps1 feature-folder resolution (issue #565).` is abbreviated to `...` below.

```
Passed=3 Failed=14 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: ...nested-artifact citations resolve to the target folder.W2a: allows the target folder cited together with a research artifact
FAILED: ...nested-artifact citations resolve to the target folder.W2b: allows the target folder cited together with an evidence artifact
FAILED: ...nested-artifact citations resolve to the target folder.W3a: allows a research artifact cited alone
FAILED: ...nested-artifact citations resolve to the target folder.W3b: allows an evidence artifact cited alone
FAILED: ...upstream-dependency citation lines.W4a: prunes the cited upstream dependency and allows when it is merged
FAILED: ...upstream-dependency citation lines.W4b: evaluates the target, not the upstream, and denies when the dependency is pr_open
FAILED: ...two non-dependency folders are ambiguous.W5a: denies as ambiguous and names both candidates
FAILED: ...two non-dependency folders are ambiguous.W5b: denies as ambiguous for the reversed order with the longer slug first
FAILED: ...tokens that truncate to fewer than four segments.W6b: denies a docs/features/active/. token as naming no folder
FAILED: ...the #621/#508 regression fixture with integer depends_on edges.W7a: evaluates feature 621 and allows while 507 and 508 are merged
FAILED: ...the #621/#508 regression fixture with integer depends_on edges.W7b: evaluates feature 621 and denies when 508 is pr_open
FAILED: ...the #621/#508 regression fixture with integer depends_on edges.W8a: matches a minimal integer depends_on edge and allows when the dependency is merged
FAILED: ...shared resolver import failure.W9: denies naming feature-folder-resolution.ps1 and guards the dot-source
FAILED: ...lifecycle-prefixed record values.W10: matches records recorded with active/ and docs/features/active/ prefixes
```
