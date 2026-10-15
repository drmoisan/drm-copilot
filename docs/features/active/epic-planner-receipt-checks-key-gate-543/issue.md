# epic-planner-receipt-checks-key-gate (Bug, Issue #543 remainder)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Draft
- Issue: #543
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/543
- GitHub issue: #543 (pre-existing; adopted, not re-promoted)
- Lifecycle record: docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md
- Parallel run: bug-burndown-2026-10-15

- Work Mode: full-bug

## Summary

Under `require_ready_for_execution`, `_validate_ready_features` in `scripts/dev_tools/validate_epic_planner_state.py` validates each feature's `model_routing_receipt` (via `validate_codex_model_routing_receipts`, plus the `logical_agent`, `complexity_band`, and `execution_context` checks) and each feature's `topology_receipt` (via `_validate_child_topology_receipt`) unconditionally. Both receipts are Codex-runtime evidence that no Claude-runtime producer writes, so a fully prepared Claude epic-planner checkpoint still fails the ready gate on every feature. The TypeScript twin `validateReadyFeatures` in `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` carries the same unconditional checks.

Earlier #543 work key-gated the launch bindings (PR #829) and the top-level planner `topology_receipt` (PR #874), and corrected the agent-definition field list (PR #912). This item closes the last remaining gap named in the #543 history: the per-feature receipt checks.

## Environment

- OS/version: any (observed on Windows 11)
- Command/flags used: `validate_epic_planner_state_text(text, require_ready_for_execution=True)`; MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state` and `require_ready_for_execution: true`
- Data source: a Claude-prepared epic-planner checkpoint whose features carry no `model_routing_receipt` or `topology_receipt` key

## Steps to Reproduce

1. Author an epic-planner checkpoint with at least two fully prepared features and no per-feature `model_routing_receipt` or `topology_receipt` key.
2. Validate it with `require_ready_for_execution=True` and no Codex flag.
3. Observe per-feature `model_routing_receipt` and `topology_receipt` errors.

## Expected Behavior

When neither `require_codex_model_routing` nor `require_codex_topology` is asserted, each per-feature receipt check runs only when its key is present on the feature, matching the key-gating pattern already applied to launch bindings and to the top-level planner `topology_receipt`. When a Codex flag is asserted, the checks remain unconditional. Python and TypeScript behave identically.

## Actual Behavior

Both per-feature receipt checks run unconditionally under `require_ready_for_execution`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Operator scope: key-gate the per-feature `model_routing_receipt` and `topology_receipt` checks in `scripts/dev_tools/validate_epic_planner_state.py` (`_validate_ready_features`, called from `validate_epic_planner_state_text`) and in the TypeScript twin, so each check applies only when its key is present, with tests on both sides and any bundled mirror. This item closes #543.

Out of scope: edits to `.claude/rules/` or `.github/instructions/`; reopening PR #829, PR #874, or PR #912 behavior.

## Acceptance Criteria

Acceptance criteria for this full-bug item are authored in `spec.md` (the work-mode AC source).

## Next Step

- [x] Promote to GitHub issue (bug-report template) — issue #543 already exists; no new issue is created
- [x] Move to active fix folder / branch
