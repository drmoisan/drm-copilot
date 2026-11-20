# Bug: ts-validator-promotion-type-parity-gap (Issue #405)

- Issue: #405
- Epic: #771 (orchestrator-state-contract-correctness)
- Work Mode: full-bug

## Summary

PR #402 (issue #399) made `scripts/dev_tools/_orchestrator_state_routing.py`'s `validate_routing_contract` resolve the required promotion-entry MCP tool from the checkpoint's `promotion-type` (`bug` -> `new_potential_bug_entry`, feature/absent -> `new_potential_entry`), so bug-type `large`-route checkpoints can pass `--require-complete` via the Python CLI. The TypeScript MCP mirror validator was not updated with the same fix, so bug-type `large`-route checkpoints are still incorrectly rejected when validated through the `validate_orchestration_artifacts` MCP tool surface. Issue #623 item 3 reports the same disagreement between the PowerShell completion gate and the MCP validator.

## Expected Behavior

Both surfaces (Python CLI and MCP tool) return the same pass/fail result and the same error list for the same checkpoint.

## Actual Behavior

The MCP surface over-reports a missing-receipt error for bug-type `large`-route checkpoints that the Python CLI accepts, because the TypeScript mirror uses the feature-type tool name (`new_potential_entry`) regardless of `promotion-type`.

## Acceptance Criteria

- [x] `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (or equivalent) resolves the promotion-entry MCP tool name from `promotion-type`, mirroring `scripts/dev_tools/_orchestrator_state_routing.py`.
- [x] A bug-type, `large`-route checkpoint with a `new_potential_bug_entry` receipt passes MCP `validate_orchestration_artifacts` with `require_complete: true`.
- [x] A feature-type, `large`-route checkpoint continues to require `new_potential_entry` (no regression).
- [x] New TypeScript tests cover both cases plus the dead-skill-name and bug-type-with-only-feature-tool-rejection scenarios.
- [x] Full toolchain (format -> lint -> type-check -> test) passes with no coverage regression.

Authoritative requirements for full-bug mode are in `spec.md`; the source issue body is the GitHub issue #405.
