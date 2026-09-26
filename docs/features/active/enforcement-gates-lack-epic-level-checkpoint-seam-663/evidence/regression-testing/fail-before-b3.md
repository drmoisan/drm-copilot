# Fail-Before B3 ([P3-T4], expect-fail)

Timestamp: 2026-09-25T19-28
Command: sh <SCRATCHPAD>/i663/run.sh p3-new  (R-SCOPED over tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 and tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1, before any production change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 11, FailedCount 8, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly G1-1, G1-2, G1-3, and the five expanded `issue #663 epic scope` names; G1-4, G1-5, and the nine pre-existing base-branch names pass. Each failure is an assertion failure (deny instead of allow, a NoTarget reason instead of the epic reason, or a per-feature seam invoked), not a setup error.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1

Starting discovery in 2 files.
Discovery found 19 tests in 148ms.
Running tests.
[-] enforce-pr-author-skill.ps1 epic scope (issue #663).epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed
 288ms (275ms|13ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the epic checkpoint satisfies every PR-creation readiness conjunct', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:92
 Expected strings to be the same, because the epic checkpoint satisfies every PR-creation readiness conjunct, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-pr-author-skill.ps1 epic scope (issue #663).epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status
 40ms (38ms|1ms)
 at $reason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:109
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:109
 Expected regular expression 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED' to match 'TARGET_WORKTREE_NOT_DERIVABLE: modelled NoTarget target for a worktree-resolution matrix row The pr-author gate will not validate this call against the session root's checkpoint, because that checkpoint may belong to a different item. Pass --head <branch> on the gh pr create command so the call names its own target.', but it did not match.
[-] enforce-pr-author-skill.ps1 epic scope (issue #663).epic scope denies when features is empty and names the epic checkpoint and features
 39ms (39ms|0ms)
 at $reason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:125
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1:125
 Expected regular expression 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED' to match 'TARGET_WORKTREE_NOT_DERIVABLE: modelled NoTarget target for a worktree-resolution matrix row The pr-author gate will not validate this call against the session root's checkpoint, because that checkpoint may belong to a different item. Pass --head <branch> on the gh pr create command so the call names its own target.', but it did not match.
[-] enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride.issue #663 epic scope.issue #663 epic scope allows --base main end-to-end
 47ms (47ms|0ms)
 at Should -Invoke Invoke-OrchestratorStatePreflight -Times 0 -Exactly, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:160
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:160
 Expected Invoke-OrchestratorStatePreflight to be called 0 times exactly, but was called 1 times
[-] enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride.issue #663 epic scope.issue #663 epic scope denies --base development with EPIC_BASE_BRANCH_MISMATCH
 40ms (39ms|1ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:175
 Expected strings to be the same, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride.issue #663 epic scope.issue #663 epic scope denies --base epic/sample-epic-integration with EPIC_BASE_BRANCH_MISMATCH
 38ms (37ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:175
 Expected strings to be the same, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride.issue #663 epic scope.issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH
 33ms (32ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:188
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:188
 Expected strings to be the same, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride.issue #663 epic scope.issue #663 epic scope reads the epic checkpoint once per gh pr create call
 36ms (36ms|1ms)
 at Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:201
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1:201
 Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
Tests completed in 1.58s
Tests Passed: 11, 
Failed: 8, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 11
FailedCount: 8
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed
FAILED: epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status
FAILED: epic scope denies when features is empty and names the epic checkpoint and features
FAILED: issue #663 epic scope allows --base main end-to-end
FAILED: issue #663 epic scope denies --base development with EPIC_BASE_BRANCH_MISMATCH
FAILED: issue #663 epic scope denies --base epic/sample-epic-integration with EPIC_BASE_BRANCH_MISMATCH
FAILED: issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH
FAILED: issue #663 epic scope reads the epic checkpoint once per gh pr create call
PASSED: without an epic checkpoint the call takes the unchanged per-feature path and is denied by its resolution
PASSED: a per-feature pull request whose --head differs from integration_branch gets the same decision and reason as with no epic checkpoint
PASSED: allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)
PASSED: allows when the checkpoint has epic_mode: false
PASSED: allows a non-create command regardless of epic_mode (gh pr edit is out of scope)
PASSED: allows when --base matches epic_context.integration_branch exactly
PASSED: denies when --base is absent from the command text
PASSED: denies when --base names a different branch than epic_context.integration_branch
PASSED: denies when epic_mode is true but epic_context.integration_branch is missing
PASSED: denies EPIC_BASE_BRANCH_MISMATCH end-to-end when epic_mode is true and --base is missing
PASSED: allows end-to-end when epic_mode is true and --base matches
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
