# ts-validator-promotion-type-parity-gap (Issue #405)

- Date captured: 2026-07-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ts-validator-promotion-type-parity-gap/ (Issue #405)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #405
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/405
- Last Updated: 2026-07-24
## Summary

PR #402 (issue #399) made `scripts/dev_tools/_orchestrator_state_routing.py`'s `validate_routing_contract` resolve the required promotion-entry MCP tool from the checkpoint's `promotion-type` (`bug` → `new_potential_bug_entry`, feature/absent → `new_potential_entry`), so bug-type `large`-route checkpoints can pass `--require-complete` via the Python CLI. The TypeScript MCP mirror validator was not updated with the same fix, so bug-type `large`-route checkpoints are still incorrectly rejected when validated through the `validate_orchestration_artifacts` MCP tool surface.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (surface-independent; logic divergence)
- Python version: repository Poetry environment (`scripts/dev_tools`)
- Command/flags used: `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing` (passes) vs MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: orchestrator-state`, `require_complete: true` (still fails)
- Data source or fixture: any `orchestrator-state.json` checkpoint with `promotion-type: bug` and `route_id: large` whose `mcp_call_receipts` correctly records `new_potential_bug_entry` (not `new_potential_entry`)

## Steps to Reproduce

1. Build a `large`-route, bug-type checkpoint whose `mcp_call_receipts` includes a successful `new_potential_bug_entry` receipt (matching real bug-promotion behavior) and no `new_potential_entry` receipt.
2. Validate it with the Python CLI using `--require-complete`: passes, per PR #402's fix.
3. Validate the same checkpoint through the MCP tool `validate_orchestration_artifacts` with `require_complete: true`: still reports a missing `new_potential_entry` receipt, because the TypeScript port (likely `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` or its sibling) has not been updated to resolve the tool name by `promotion-type` the way the Python validator now does.

## Expected Behavior

Both surfaces (Python CLI and MCP tool) return the same pass/fail result and the same error list for the same checkpoint, per the existing parity expectation already tracked for a different gap in issue #343.

## Actual Behavior

The MCP surface over-reports a missing-receipt error for bug-type `large`-route checkpoints that the Python CLI now correctly accepts, because the TypeScript mirror still hardcodes the feature-type tool name (`new_potential_entry`) regardless of `promotion-type`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: See PR #402's own description of the fix (`scripts/dev_tools/_orchestrator_state_routing.py`, `_receipt_agents`/tool-resolution logic) and issue #343 for the existing, separate TS/Python parity-gap pattern (`pr_gate`/`ci_gate` route-gating) this defect resembles.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Impact: any agent or extension command that self-checks completion through the MCP tool (rather than the authoritative Python CLI / SubagentStop hook) receives a false blocking error for bug-type `large`-route orchestrations, mirroring the class of bug already tracked in #343.

## Suspected Cause / Notes

- Likely lives in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (or wherever the TS port of `validate_routing_contract` resolves `required_mcp_tools`/receipt matching).
- Discovered while closing out issue #399/PR #402 on 2026-07-22; deliberately deferred out of that fix's minor-audit scope to avoid scope creep, and recorded here per that PR's own follow-up recommendation.
- May be related to, but is distinct from, issue #343 (which covers `pr_gate`/`ci_gate` route-gating, not `required_mcp_tools` promotion-type resolution).

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: TypeScript unit tests mirroring the 4 new Python tests added in PR #402 (`tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`) — bug-type pass, feature-type no-regression, dead-skill-name removal (if still applicable), bug-type-with-only-feature-tool rejection.
- [x] Integration scenario to retest: run the same fixture checkpoint through both the Python CLI and the MCP tool and assert identical results, per the existing config-parity test pattern used elsewhere in this repo.
- [ ] Manual verification notes:

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
