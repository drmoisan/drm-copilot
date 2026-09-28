# Fail-Before B5 ([P5-T3], expect-fail)

Timestamp: 2026-09-25T19-39
Command: sh <SCRATCHPAD>/i663/run.sh p5-new  (R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1, before the gate changes)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 5, FailedCount 8, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly G4-1, G4-2, the three expanded G4-3 names, G4-5, G4-6, and G4-7; the two expanded G4-4 names, G4-8, G4-9, and G4-10 pass. Every failure is an assertion failure: the unchanged gate returns the single-feature deny, so allow rows see `deny`, deny rows see a reason that does not name the epic checkpoint, and G4-5 sees `deny` and no HEAD read.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1

Starting discovery in 1 files.
Discovery found 13 tests in 117ms.
Running tests.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows git add of a production path while a merge is in progress
 255ms (243ms|12ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits staging a production path (D2)', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:92
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:92
 Expected strings to be the same, because a ready epic checkpoint with a merge in progress admits staging a production path (D2), but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
 25ms (23ms|1ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:107
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:107
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_feature_folder is missing and names it
 21ms (20ms|1ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_manifest_path is missing and names it
 15ms (15ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when features is missing and names it
 15ms (14ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:127
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope resolves the -C selector worktree for the command leg
 22ms (22ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:156
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:156
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows an Edit of a production path while a merge is in progress
 17ms (17ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the path leg follows the same readiness decision as the command leg', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:171
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:171
 Expected strings to be the same, because the path leg follows the same readiness decision as the command leg, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies a Write of a production path when no merge is in progress
 31ms (30ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:185
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:185
 Expected $true, because the denial names the epic checkpoint, but got $false.
Tests completed in 975ms
Tests Passed: 5, 
Failed: 8, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 5
FailedCount: 8
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: epic scope allows git add of a production path while a merge is in progress
FAILED: epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
FAILED: epic scope denies git add of a production path when epic_feature_folder is missing and names it
FAILED: epic scope denies git add of a production path when epic_manifest_path is missing and names it
FAILED: epic scope denies git add of a production path when features is missing and names it
FAILED: epic scope resolves the -C selector worktree for the command leg
FAILED: epic scope allows an Edit of a production path while a merge is in progress
FAILED: epic scope denies a Write of a production path when no merge is in progress
PASSED: a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
