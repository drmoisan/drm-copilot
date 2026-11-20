# Fail-Before B6 ([P6-T4], expect-fail)

Timestamp: 2026-09-25T19-43
Command: sh <SCRATCHPAD>/i663/run.sh p6-new  (R-SCOPED over tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1, before any Markdown edit)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 7, FailedCount 4, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly the four `(issue #663)` names; the seven pre-existing names pass. Every failure is an assertion failure on absent contract text: the `## Epic-Level Issue Promotion` section does not exist, the epic-planner frontmatter lacks the promotion tool, and neither epic-orchestrate nor epic-orchestrator states `epic_issue_num` or the integration-PR checkpoint shape.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1

Starting discovery in 1 files.
Discovery found 11 tests in 112ms.
Running tests.
[-] checkpoint hygiene and delegation identity skill contract.epic-plan skill promotes an epic-level issue and records epic_issue_num (issue #663)
 18ms (17ms|1ms)
 at $section | Should -Not -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:165
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:165
 Expected a value, but got $null or empty.
[-] checkpoint hygiene and delegation identity skill contract.epic-planner agent lists the promotion tool and records epic_issue_num (issue #663)
 9ms (8ms|0ms)
 at $frontmatter.Contains('"mcp__drm-copilot__potential_to_issue"') | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:180
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:180
 Expected $true, but got $false.
[-] checkpoint hygiene and delegation identity skill contract.epic-orchestrate skill states the integration-PR checkpoint shape and receipt location (issue #663)
 5ms (4ms|0ms)
 at $section | Should -BeLike '*Integration-PR checkpoint shape (issue #663)*', <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:191
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:191
 Expected like wildcard '*Integration-PR checkpoint shape (issue #663)*' to match '`artifacts/orchestration/epic-orchestrator-state.json` carries `objective`, `route_id: "epic"`, `epic_feature_folder`, `epic_manifest_path` (which points at `docs/features/epics/<epic-slug>/epic.md`), `epic_status_doc_path`, `integration_branch`, `completed_steps`, `next_step`, `last_updated`, `current_wave`, `waves[]`, `features[]`, `epic_merge_pr`, and the three receipt arrays (`delegation_receipts[]`, `skill_receipts[]`, `mcp_call_receipts[]`). The `merge_status` enum is: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`. The optional `intent` object (projection of the `epic.md` intent block) is validated presence-gated. Every field needed to re-derive state durably on resume (`worktree_path`, `branch_name`, `pr_number`, `merge_status`) is re-derivable from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` - the checkpoint is a cache of that durable state, not the source of truth. Validate the checkpoint through the `mcp__drm-copilot__validate_orchestration_artifacts` call with `artifact_type: "epic-orchestrator-state"`, supplying the `require_complete` argument on that same call at the completion gate. The validation is implemented in `scripts/dev_tools/validate_epic_orchestrator_state.py`. **Checkpoint hygiene (issue #673).** The coordinating session never holds a per-feature checkpoint at its own root. Before the first child delegation of a run it moves any `artifacts/orchestration/orchestrator-state.json` at its root to `artifacts/orchestration/handoff/orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json`, and writes none there for the rest of the run, because each item's checkpoint lives in that item's worktree. A gated call the coordinator issues on an item's behalf is resolved by the item's issue number and branch, never by the coordinator root.', but it did not match.
[-] checkpoint hygiene and delegation identity skill contract.epic-orchestrator agent lists epic_issue_num and model_routing_receipts in its checkpoint fields (issue #663)
 4ms (3ms|0ms)
 at $section | Should -BeLike '*epic_issue_num*', <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:205
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1:205
 Expected like wildcard '*epic_issue_num*' to match 'Update `artifacts/orchestration/epic-orchestrator-state.json` after every completed step, per the full schema enforced by `validate_epic_orchestrator_state_text`, implemented in `scripts/dev_tools/validate_epic_orchestrator_state.py`: `objective`, `route_id: "epic"`, `epic_feature_folder`, `epic_manifest_path`, `epic_status_doc_path`, `integration_branch`, `completed_steps`, `next_step`, `last_updated`, `current_wave`, `waves[]`, `features[]` (including `merge_status` and the four lifecycle timestamps), `epic_merge_pr`, and the three receipt arrays (`delegation_receipts[]`, `skill_receipts[]`, `mcp_call_receipts[]`) populated with the `epic` route's required names from `config/orchestration-routing.json`.', but it did not match.
Tests completed in 571ms
Tests Passed: 7, 
Failed: 4, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 7
FailedCount: 4
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: epic-plan skill promotes an epic-level issue and records epic_issue_num (issue #663)
FAILED: epic-planner agent lists the promotion tool and records epic_issue_num (issue #663)
FAILED: epic-orchestrate skill states the integration-PR checkpoint shape and receipt location (issue #663)
FAILED: epic-orchestrator agent lists epic_issue_num and model_routing_receipts in its checkpoint fields (issue #663)
PASSED: orchestrate skill archives a foreign per-feature checkpoint to the handoff folder
PASSED: parallel-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: epic-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
PASSED: orchestrate skill requires the canonical issue line on every receipt-gated delegation
PASSED: orchestrate skill requires a branch label on every receipt-gated delegation
PASSED: orchestrate skill names every subagent type the model-routing gate receipt-gates
PASSED: orchestrate skill names both gates that identify the item from the delegation prompt
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
