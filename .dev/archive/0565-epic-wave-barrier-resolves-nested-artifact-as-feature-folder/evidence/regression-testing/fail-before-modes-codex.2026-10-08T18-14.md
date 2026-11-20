# Fail-Before: Codex -modes.ps1 Target Folder (W27)

Timestamp: 2026-10-08T18-14
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P1-T14.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=5 Failed=11 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Required failures present: M2a, M2b, M3a, M3b, M7. Additional observed failures: M4e, M4p, M5, M5r, M7d, M9. Passing before the fix: M1, M4q, M6a, M6b, M8.

The `FAILED:` prefix `enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Codex, issue #565).` is abbreviated to `...` below.

```
Passed=5 Failed=11 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: ...nested-artifact citations resolve to the target folder.M2a: allows the target folder cited together with a research artifact
FAILED: ...nested-artifact citations resolve to the target folder.M2b: allows the target folder cited together with an evidence artifact
FAILED: ...nested-artifact citations resolve to the target folder.M3a: allows a research artifact cited alone
FAILED: ...nested-artifact citations resolve to the target folder.M3b: allows an evidence artifact cited alone
FAILED: ...upstream and sibling citations.M4e: prunes a cited epic dependency and reports no readiness failure
FAILED: ...upstream and sibling citations.M4p: reports target-ambiguous for a parallel target cited with another item and no issue number
FAILED: ...two non-dependency folders are ambiguous at decision level.M5: denies with target-ambiguous naming both candidates
FAILED: ...two non-dependency folders are ambiguous at decision level.M5r: denies with target-ambiguous for the reversed order with the longer slug first
FAILED: ...the #621/#508 regression fixture.M7: resolves feature 621 and does not fail the merge_status predicate
FAILED: ...the #621/#508 regression fixture.M7d: allows the 621 launch at decision level
FAILED: ...shared resolver import failure.M9: returns no target folder and a feature-folder-resolution-import readiness failure
```
