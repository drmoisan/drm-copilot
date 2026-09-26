# B4 Scoped Pester ([P4-T6])

Timestamp: 2026-09-25T19-36
Command: sh <SCRATCHPAD>/i663/run.sh p4-verify  (R-SCOPED over tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1, tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1, tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1, tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1)
EXIT_CODE: 0
Output Summary: PassedCount 46, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. G3-1 to G3-4 appear on PASSED lines. Pre-change toolchain check on the touched folders: PSScriptAnalyzer reported no findings and the formatter check reported `would format: 0` over 133 files.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
  tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
  tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
  tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1

Starting discovery in 4 files.
Discovery found 46 tests in 180ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1
 774ms (392ms|265ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
 511ms (432ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1
 168ms (128ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1
 92ms (56ms|26ms)
Tests completed in 1.56s
Tests Passed: 46, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 46
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows a well-formed tool_input carrying no subagent_type (scope filter)
PASSED: denies unparseable JSON as an envelope anomaly (fail closed)
PASSED: allows a non-delegating subagent_type
PASSED: allows an orchestrator subagent_type (caller, not receipt-gated)
PASSED: allows when a routing receipt exists for the subagent
PASSED: denies with MODEL_ROUTING_RECEIPT_BLOCKED when no receipt exists for the subagent
PASSED: denies when the checkpoint is missing (no receipts at all)
PASSED: denies when the checkpoint has no model_routing_receipts property
PASSED: returns $null when the checkpoint path does not exist
PASSED: returns $null when the file exists but is not valid JSON
PASSED: returns a parsed object when the file exists and is valid JSON
PASSED: returns $false for a $null checkpoint
PASSED: returns $true when a matching receipt exists
PASSED: model-routing R1 allows when the resolved own checkpoint records the receipt
PASSED: model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present
PASSED: model-routing R2 denies with the no-target code when the only signal is a repository-relative path
PASSED: model-routing R3 denies with the blocked reason when the resolved own checkpoint records no receipt
PASSED: model-routing R3 denies with the blocked reason when the checkpoint is absent at the resolved target
PASSED: model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt
PASSED: model-routing R4 selects the branch-named worktree when a stale attempt records the same issue
PASSED: model-routing R5 denies with the no-target code when the prompt names no target
PASSED: model-routing R6 allows when the working directory is the item worktree and its own receipt is present
PASSED: model-routing R7 denies with the blocked reason when the resolved checkpoint is unparseable
PASSED: model-routing R7 denies with the blocked reason when the resolved checkpoint is empty
PASSED: model-routing R8 denies with the no-target code when the issue is recorded in no live worktree
PASSED: model-routing R9 denies with the ambiguity code when the issue and the branch name different worktrees
PASSED: model-routing R9 denies with the ambiguity code when two live worktrees record the issue
PASSED: model-routing R10 allows a subagent outside the gated set when the target is unresolvable
PASSED: model-routing genuine-absence and target-resolution reason codes never appear in each other's decisions
PASSED: model-routing denies an unresolved NoTarget target without reaching the checkpoint read
PASSED: model-routing denies an unresolved Ambiguous target without reaching the checkpoint read
PASSED: model-routing reads the checkpoint at the resolved absolute path for a SessionRoot target
PASSED: model-routing reads the checkpoint at the resolved absolute path for a OtherWorktree target
PASSED: epic scope allows Agent(pr-author) when the epic checkpoint records a pr-author receipt
PASSED: epic scope denies Agent(pr-author) with MODEL_ROUTING_RECEIPT_BLOCKED when the epic checkpoint has no pr-author receipt
PASSED: a per-feature delegation is denied with the unchanged per-feature reason when its checkpoint lacks the receipt
PASSED: a per-feature delegation is allowed from the per-feature checkpoint when the epic branch does not match
PASSED: orchestrate skill archives a foreign per-feature checkpoint to the handoff folder
PASSED: parallel-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: epic-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: orchestrate skill requires the canonical issue line on every receipt-gated delegation
PASSED: orchestrate skill requires a branch label on every receipt-gated delegation
PASSED: orchestrate skill names every subagent type the model-routing gate receipt-gates
PASSED: orchestrate skill names both gates that identify the item from the delegation prompt
RSCOPED_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
