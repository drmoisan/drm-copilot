# B6 Scoped Pester ([P6-T12])

Timestamp: 2026-09-25T19-46
Command: sh <SCRATCHPAD>/i663/run.sh p6-verify  (R-SCOPED over tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1, tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1, tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1, tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1)
EXIT_CODE: 0
Output Summary: PassedCount 132, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. The two D3 names and the four contract names appear on PASSED lines. Pre-run toolchain check on the touched folders: PSScriptAnalyzer reported no findings and the formatter check reported `would format: 0` over 135 files.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
  tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
  tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
  tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
  tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
  tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
  tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1

Starting discovery in 7 files.
Discovery found 132 tests in 263ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1
 909ms (471ms|314ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1
 86ms (38ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1
 142ms (98ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1
 153ms (108ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
 308ms (258ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1
 792ms (636ms|110ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
 98ms (50ms|32ms)
Tests completed in 2.5s
Tests Passed: 132, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 132
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: allows when file_path is missing from a well-formed tool_input
PASSED: allows when content itself is not valid JSON (defers to downstream tools)
PASSED: allows a file_path other than the checkpoint
PASSED: allows an Edit-style call that only supplies old_string/new_string on the checkpoint path
PASSED: allows a checkpoint whose next_step is not complete and has no completion markers
PASSED: allows when issue-num, feature-folder, and a success ci_gate with head_sha are present
PASSED: accepts variables.issue-num and variables.feature-folder fallbacks
PASSED: requires pr_gate and blocks when a requires_pr_gate route omits PR evidence
PASSED: does NOT require pr_gate for the small route (no requires_pr_gate)
PASSED: enforces the gate for a non-232 route with requires_pr_gate true (route-driven, not issue-driven)
PASSED: blocks when a requires_pr_gate route has stale ci_gate.head_sha versus pr_gate.head_sha
PASSED: allows when a requires_pr_gate route supplies complete matching PR and CI evidence
PASSED: returns true for a route whose requires_pr_gate is true
PASSED: returns false for a route without requires_pr_gate
PASSED: returns false for an unknown route
PASSED: returns false when the payload selects no route
PASSED: blocks and references ci_gate when ci_gate is absent
PASSED: blocks and references issue-num
PASSED: blocks and references feature-folder
PASSED: blocks and references ci_gate conclusion
PASSED: blocks issue-num sentinel "n/a"
PASSED: blocks issue-num sentinel "none"
PASSED: blocks issue-num sentinel "tbd"
PASSED: blocks issue-num sentinel "  "
PASSED: blocks issue-num sentinel ""
PASSED: allows a digits-only issue-num with a valid existing feature-folder
PASSED: blocks a feature-folder sentinel "n/a"
PASSED: allows a valid docs/features/active/... feature-folder that exists
PASSED: blocks a valid-shaped feature-folder when the injected existence check returns false
PASSED: blocks an Edit whose patched checkpoint asserts completion without evidence
PASSED: allows an Edit whose patched checkpoint does not assert completion
PASSED: allows an Edit when the on-disk checkpoint file does not exist
PASSED: allows an Edit when old_string is not found in the on-disk content
PASSED: allows an Edit on a non-checkpoint path
PASSED: Test-IsValidIssueNum returns true for digits-only
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit "n/a"
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit "none"
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit "TBD"
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit "12a"
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit ""
PASSED: Test-IsValidIssueNum returns false for sentinel/non-digit "   "
PASSED: Test-IsValidFeatureFolder returns false for the bare active prefix
PASSED: Test-IsValidFeatureFolder returns false for a folder outside docs/features/active/
PASSED: Test-IsValidFeatureFolder returns true for a valid existing folder
PASSED: allows when the mocked content parser throws (invalid content JSON path)
PASSED: issue #663 does not intercept a completion-asserting Write to epic-orchestrator-state.json
PASSED: issue #663 still denies a per-feature checkpoint whose feature-folder is under docs/features/epics/
PASSED: denies an empty payload
PASSED: denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: denies a null tool_input
PASSED: denies a non-object tool_input
PASSED: reads the payload through the shared reader
PASSED: emits a block decision JSON when completion is asserted without evidence
PASSED: emits the PreToolUse deny shape for a completion checkpoint with missing evidence
PASSED: uses the helper-backed route gate for bundled Codex resources
PASSED: keeps the bundled-mirror enforce-completion-consistency.ps1 byte-identical to the canonical hook
PASSED: keeps the bundled-mirror enforce-completion-helpers.ps1 byte-identical to the canonical helper
PASSED: orchestrate skill archives a foreign per-feature checkpoint to the handoff folder
PASSED: parallel-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: epic-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: orchestrate skill requires the canonical issue line on every receipt-gated delegation
PASSED: orchestrate skill requires a branch label on every receipt-gated delegation
PASSED: orchestrate skill names every subagent type the model-routing gate receipt-gates
PASSED: orchestrate skill names both gates that identify the item from the delegation prompt
PASSED: epic-plan skill promotes an epic-level issue and records epic_issue_num (issue #663)
PASSED: epic-planner agent lists the promotion tool and records epic_issue_num (issue #663)
PASSED: epic-orchestrate skill states the integration-PR checkpoint shape and receipt location (issue #663)
PASSED: epic-orchestrator agent lists epic_issue_num and model_routing_receipts in its checkpoint fields (issue #663)
PASSED: allows when an epic features[] record matches and merge_status is merged
PASSED: allows when the epic record merge_status is worktree_removed
PASSED: allows when a parallel checkpoint exists but does not cover the target
PASSED: normalizes backslash paths in an epic features[] record
PASSED: denies when the epic record merge_status is not terminal
PASSED: denies when the epic record has no merge_status field
PASSED: denies when the epic checkpoint covers a different worktree
PASSED: denies fail-closed when the epic checkpoint is unparseable
PASSED: denies fail-closed when the epic checkpoint is absent
PASSED: denies when the epic checkpoint has no features array
PASSED: still denies an unmerged parallel item even when an epic record exists for another path
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows when the JSON payload has no command field
PASSED: allows git worktree list
PASSED: allows git worktree add
PASSED: allows an unrelated Bash command
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: allows git worktree remove when the matching record has merge_status merged
PASSED: allows git worktree remove when the matching record has merge_status worktree_removed
PASSED: allows git worktree remove --force when the matching record has merge_status merged
PASSED: denies when the matching record has merge_status not_started
PASSED: denies when the matching record has merge_status worktree_created
PASSED: denies when the matching record has merge_status pr_open
PASSED: denies when the matching record has merge_status ci_green
PASSED: denies when the matching record has merge_status blocked_drift
PASSED: denies when the matching record has merge_status blocked_ci_loop_limit
PASSED: denies when the matching record carries no merge_status key
PASSED: denies when the parallel checkpoint file is absent
PASSED: denies when the parallel checkpoint content is malformed JSON
PASSED: denies when no items[] record has a matching worktree_path
PASSED: denies when the checkpoint carries no items key
PASSED: calls the read seam exactly once and allows when the seam reports merged
PASSED: calls the read seam exactly once and denies for the identical command when the seam reports ci_green
PASSED: does not call the read seam for a command that is not git worktree remove
PASSED: matches worktree_path across backslash/forward-slash separator differences
PASSED: matches worktree_path when the recorded value carries a trailing slash
PASSED: matches worktree_path when the command quotes the target path
PASSED: extracts the target path from the command text
PASSED: returns $null when the command does not name a path
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when the items key is absent
PASSED: returns $null when WorktreePath is empty
PASSED: skips item records with no worktree_path key
PASSED: returns the matching item record
PASSED: returns $false when ItemRecord is $null
PASSED: returns $false when the merge_status key is absent
PASSED: returns $true for merge_status merged
PASSED: Get-ParallelWorktreeRemovalGateCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-ParallelWorktreeRemovalGateCheckpointContent reads real content when the file exists
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope end-to-end when no checkpoint record authorizes removal
PASSED: allows the nested envelope when the checkpoint records the item as merged
PASSED: allows removal when a fresh manifest record authorizes the target
PASSED: denies a manifest-covered removal whose target a parallel checkpoint records
PASSED: emits the unchanged parallel block reason
PASSED: keeps the merge_status allow-set unchanged
PASSED: resolves the operand when --force precedes the path
PASSED: brings git -C /repo/main worktree remove into scope
PASSED: takes a quoted mention of the removal phrase out of scope
RSCOPED_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
