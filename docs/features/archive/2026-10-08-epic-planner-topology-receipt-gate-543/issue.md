# epic-planner-topology-receipt-gate (Potential Bug)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Draft
- GitHub issue: #543 (pre-existing; residual scope recorded in its last two comments)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

## Summary

`_validate_planner_topology_receipt` in `scripts/dev_tools/validate_epic_planner_state.py` runs unconditionally under `require_ready_for_execution`, so a Claude-prepared epic-planner checkpoint (which never writes a Codex `topology_receipt`) cannot pass the strict ready gate. PR #829 (merge commit 869c4fad) key-gated the launch-binding and launch-evidence checks but left this check, and its TypeScript parity port `validatePlannerTopologyReceipt` in `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, unconditional.

## Environment

- OS/version: any (observed on Windows 11)
- Python version: repository Poetry environment
- Command/flags used: epic-planner checkpoint validation with `require_ready_for_execution` (MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state`, `require_ready_for_execution: true`)
- Data source or fixture: Claude-runtime epic-planner checkpoints for epics #770 and #771

## Steps to Reproduce

1. Prepare an epic with the Claude `epic-planner` agent, which writes no top-level `topology_receipt`.
2. Validate the planner checkpoint with `require_ready_for_execution: true` and without any Codex flag.
3. Observe the topology-receipt errors.

## Expected Behavior

Without `require_codex_model_routing` or `require_codex_topology`, the planner topology-receipt check is key-gated: a checkpoint that does not carry `topology_receipt` is not required to carry one. A checkpoint that does carry it is still validated in full, and the Codex flags keep the check unconditional.

## Actual Behavior

The ready gate reports `Epic planner topology_receipt ...` errors for every Claude-prepared checkpoint, in both the Python validator and the TypeScript MCP port.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see issue #543 comments dated 2026-09-30 and 2026-10-07.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The call site `errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))` in `validate_epic_planner_state_text` is not conditioned on the `key_gated` value that PR #829 introduced. The TypeScript call `validatePlannerTopologyReceipt(value["topology_receipt"])` in `validateEpicPlannerStateText` has the same shape.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: Python and TypeScript tests for absent, present-valid, and present-invalid `topology_receipt` under key-gated and Codex-flagged modes
- [ ] Integration scenario to retest: MCP service call with `require_ready_for_execution` on a Claude-shaped checkpoint
- [ ] Manual verification notes: none

## Next Step

- [x] Promote to GitHub issue (bug-report template) — issue #543 already exists; no new issue is created
- [ ] Move to active fix folder / branch
