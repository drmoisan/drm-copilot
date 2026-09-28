# Remediation Cycle 1 Fail-Before RB2 ([P2-T4], expect-fail)

Timestamp: 2026-09-25T21-25
Command: sh <SCRATCHPAD>/rem1/runout.sh es-run  (R-SCOPED over tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 and tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1, before the module change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 39, FailedCount 3, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly H1, H2, and G4-11. H1 failed on IsEpicScope (expected false, got true); H2 on IsEpicScope (expected true, got false); G4-11 on permissionDecision (expected deny, got allow). RSCOPED_EXIT_CODE 1 and PROCESS_EXIT_CODE 1.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1

Starting discovery in 2 files.
Discovery found 42 tests in 154ms.
Running tests.
[-] Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2).a head-matched command leg is not epic scope when the text names integration_branch but the selector HEAD differs
 32ms (31ms|1ms)
 at $scope.IsEpicScope | Should -BeFalse -Because 'the selector worktree HEAD, not the text label, decides a head-matched leg', <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1:363
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1:363
 Expected $false, because the selector worktree HEAD, not the text label, decides a head-matched leg, but got $true.
[-] Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2).a head-matched command leg probes MERGE_HEAD in the selector worktree when the text names another branch
 19ms (19ms|1ms)
 at $scope.IsEpicScope | Should -BeTrue -Because 'the selector worktree HEAD equals integration_branch whatever the text names', <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1:377
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1:377
 Expected $true, because the selector worktree HEAD equals integration_branch whatever the text names, but got $false.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope ignores a text branch label and decides the -C selector worktree by its own HEAD
 37ms (37ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:242
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:242
 Expected strings to be the same, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
Tests completed in 1.93s
Tests Passed: 39,
Failed: 3,
Skipped: 0,
Inconclusive: 0,

NotRun: 0
PassedCount: 39
FailedCount: 3
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: a head-matched command leg is not epic scope when the text names integration_branch but the selector HEAD differs
FAILED: a head-matched command leg probes MERGE_HEAD in the selector worktree when the text names another branch
FAILED: epic scope ignores a text branch label and decides the -C selector worktree by its own HEAD
PASSED: resolves epic scope when the --head branch equals integration_branch
PASSED: resolves epic scope when a branch: label equals integration_branch
PASSED: resolves epic scope for a command leg whose -C selector worktree HEAD equals integration_branch
PASSED: resolves epic scope for a command leg without a selector when the session-root HEAD equals integration_branch
PASSED: reports a merge in progress for a head-matched command leg when MERGE_HEAD exists
PASSED: is not epic scope when the epic checkpoint is absent
PASSED: is not epic scope when the epic checkpoint is unparseable
PASSED: is not epic scope when route_id is not epic
PASSED: is not epic scope when integration_branch is empty
PASSED: is not epic scope when the branch signal does not equal integration_branch
PASSED: is not epic scope when the worktree HEAD does not equal integration_branch
PASSED: is not epic scope and reads no checkpoint when there is no branch signal and head matching is off
PASSED: is not epic scope when the session root is not inside a worktree
PASSED: returns an absolute checkpoint path composed from the session worktree root
PASSED: never takes the checkpoint path from text that names another epic checkpoint
PASSED: reads the epic checkpoint through the seam exactly once per resolution
PASSED: returns null checkpoint text when the checkpoint file is absent
PASSED: reads the HEAD branch of a linked worktree through its gitdir file
PASSED: reads the HEAD branch of a main checkout through its git directory
PASSED: returns no HEAD branch for a detached HEAD
PASSED: probes MERGE_HEAD in the worktree git directory
PASSED: epic scope allows git add of a production path while a merge is in progress
PASSED: epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies git add of a production path when epic_feature_folder is missing and names it
PASSED: epic scope denies git add of a production path when epic_manifest_path is missing and names it
PASSED: epic scope denies git add of a production path when features is missing and names it
PASSED: a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: epic scope resolves the -C selector worktree for the command leg
PASSED: epic scope allows an Edit of a production path while a merge is in progress
PASSED: epic scope denies a Write of a production path when no merge is in progress
PASSED: without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
PASSED: issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
