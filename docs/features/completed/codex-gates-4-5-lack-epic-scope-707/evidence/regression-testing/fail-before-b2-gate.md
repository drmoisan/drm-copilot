# Fail-Before: Suite B Before Gate Edit (d) ([P2-T5], expect-fail)

Timestamp: 2026-09-27T07-00
Command: sh <SCRATCHPAD>/x707p1-rscoped.sh tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure observed. With gate edits (a), (b), and (c) applied and edit (d) not yet applied, PassedCount 43, FailedCount 10, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly the three G1 expansions, the three G2 expansions, the three G3 expansions, and G5. Every G7 expansion (12) and G8 expansion (3) appears on a PASSED line.

Note: a first launch at 2026-09-27T07-00 reported FailedCount 13: the ten expected rows plus the three S4 rows. The S4 rows wrapped the result of `Get-PythonInvocationFinding` in `@()`, and that helper returns its findings with the unary comma operator, so the count was 1 (one empty inner array) rather than 0. The S4 assignment in the Suite B file was corrected to assign the result directly, as `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` does, and the run below was taken after that correction. No production file was changed between the two launches.

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T07-00

Starting discovery in 1 files.
Discovery found 53 tests in 137ms.
Running tests.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the command leg of a production path while a merge is in progress
 236ms (222ms|14ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits a production operand (D2)', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 Expected strings to be the same, because a ready epic checkpoint with a merge in progress admits a production operand (D2), but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the apply_patch leg of a production path while a merge is in progress
 17ms (16ms|1ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits a production operand (D2)', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 Expected strings to be the same, because a ready epic checkpoint with a merge in progress admits a production operand (D2), but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the path leg of a production path while a merge is in progress
 34ms (34ms|1ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits a production operand (D2)', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:125
 Expected strings to be the same, because a ready epic checkpoint with a merge in progress admits a production operand (D2), but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
 24ms (23ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
 11ms (11ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
 12ms (11ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:143
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
 21ms (20ms|1ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
 13ms (12ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when features is missing and names it and the epic checkpoint
 20ms (20ms|0ms)
 at $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:162
 Expected $true, because the denial names the epic checkpoint, but got $false.
[-] Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope decides a -C selector command by the selector worktree HEAD and allows it
 26ms (26ms|0ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:207
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:207
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
Tests completed in 1.65s
Tests Passed: 43, 
Failed: 10, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 43
FailedCount: 10
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=43 | failed=10
FAILED: epic scope allows the command leg of a production path while a merge is in progress
FAILED: epic scope allows the apply_patch leg of a production path while a merge is in progress
FAILED: epic scope allows the path leg of a production path while a merge is in progress
FAILED: epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
FAILED: epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
FAILED: epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
FAILED: epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
FAILED: epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
FAILED: epic scope denies the command leg when features is missing and names it and the epic checkpoint
FAILED: epic scope decides a -C selector command by the selector worktree HEAD and allows it
PASSED: the epic-scope decision names route_id and the epic checkpoint when the resolved scope carries an invalid route_id
PASSED: the epic-scope decision names epic_feature_folder and the epic checkpoint when the resolved scope carries an invalid epic_feature_folder
PASSED: the epic-scope decision names epic_manifest_path and the epic checkpoint when the resolved scope carries an invalid epic_manifest_path
PASSED: the epic-scope decision names integration_branch and the epic checkpoint when the resolved scope carries an invalid integration_branch
PASSED: the epic-scope decision names features and the epic checkpoint when the resolved scope carries an invalid features
PASSED: a -C selector command whose selector HEAD differs returns the single-feature decision although the session-root HEAD matches
PASSED: with no epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the command leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the path leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the command leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the path leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the command leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the path leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the command leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the apply_patch leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the path leg is allowed by a ready single-feature checkpoint
PASSED: a bookkeeping path operand stays exempt without reading the epic checkpoint
PASSED: a bookkeeping command operand stays exempt without reading the epic checkpoint
PASSED: the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: the epic-scope selector returns the selector path for a leading git -C selector
PASSED: the epic-scope selector returns no selector for a command without a selector
PASSED: the epic-scope selector returns no selector for an unbalanced command line
PASSED: resolves every Codex epic-scope seam name as a function after dot-sourcing the gate
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 byte-identical to its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-scope.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-resolution.ps1 or its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
EXIT_CODE=1
```
