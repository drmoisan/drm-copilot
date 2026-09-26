# Fail-Before B4 ([P4-T3], expect-fail)

Timestamp: 2026-09-25T19-34
Command: sh <SCRATCHPAD>/i663/run.sh p4-new  (R-SCOPED over tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1, before the hook change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 2, FailedCount 2, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly G3-1 and G3-2; G3-3 and G3-4 pass. Both failures are assertion failures: the unchanged hook runs the per-feature resolution, which returns the NoTarget deny instead of the epic-scope allow (G3-1) or the epic-scope MODEL_ROUTING_RECEIPT_BLOCKED reason (G3-2).

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1

Starting discovery in 1 files.
Discovery found 4 tests in 111ms.
Running tests.
[-] enforce-model-routing-receipt.ps1 epic scope (issue #663).epic scope allows Agent(pr-author) when the epic checkpoint records a pr-author receipt
 236ms (224ms|13ms)
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the epic checkpoint records a pr-author routing receipt', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1:95
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1:95
 Expected strings to be the same, because the epic checkpoint records a pr-author routing receipt, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-model-routing-receipt.ps1 epic scope (issue #663).epic scope denies Agent(pr-author) with MODEL_ROUTING_RECEIPT_BLOCKED when the epic checkpoint has no pr-author receipt
 19ms (18ms|1ms)
 at $reason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1:113
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1:113
 Expected like wildcard 'MODEL_ROUTING_RECEIPT_BLOCKED*' to match 'TARGET_WORKTREE_NOT_DERIVABLE: modelled NoTarget target for a worktree-resolution matrix row The model-routing gate will not check this delegation against a checkpoint that may belong to a different item. Put the line 'Canonical issue number for this feature is <N>.' and a 'branch: <item branch>' label in the delegation prompt so the gate can identify the item.', but it did not match.
Tests completed in 773ms
Tests Passed: 2, 
Failed: 2, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 2
FailedCount: 2
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: epic scope allows Agent(pr-author) when the epic checkpoint records a pr-author receipt
FAILED: epic scope denies Agent(pr-author) with MODEL_ROUTING_RECEIPT_BLOCKED when the epic checkpoint has no pr-author receipt
PASSED: a per-feature delegation is denied with the unchanged per-feature reason when its checkpoint lacks the receipt
PASSED: a per-feature delegation is allowed from the per-feature checkpoint when the epic branch does not match
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
