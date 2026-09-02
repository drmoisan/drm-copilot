# mcp-validator-missing-bug-promotion-substitution (Potential Bug)

- Date captured: 2026-09-02
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` (TypeScript surface) reports a false-positive completion error for `orchestrator-state` checkpoints with `promotion-type: "bug"` under `require_complete: true`, while the authoritative Python CLI (`scripts.dev_tools.validate_orchestration_artifacts`) passes the identical checkpoint cleanly.

## Environment

- OS/version: Windows 11
- Python version: repo-standard Poetry environment
- Command/flags used: `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=orchestrator-state`, `require_complete=true`, `require_model_routing=true`, vs. `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` for issue #620 (a `minor-audit`/`bug` promotion on the `small` route)

## Steps to Reproduce

1. Build an orchestrator-state checkpoint for a bug-type promotion (`"promotion-type": "bug"`) on the `small` route, with `mcp_call_receipts` containing a successful `new_potential_bug_entry` entry (not `new_potential_entry`) and `required_mcp_tools` set to the bug-substituted list (`["new_potential_bug_entry", "potential_to_issue", "new_active_feature_folder", "collect_pr_context", "validate_orchestration_artifacts"]`).
2. Run `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=orchestrator-state`, `require_complete=true` against that checkpoint.
3. Separately run the Python CLI directly on the same file with the same flags.

## Expected Behavior

Both the MCP tool and the Python CLI should agree: per `_resolve_promotion_entry_tools` in `scripts/dev_tools/_orchestrator_state_routing.py`, a checkpoint with `promotion-type == "bug"` should have every occurrence of `new_potential_entry` substituted with `new_potential_bug_entry` in the route's `required_mcp_tools` before both the exact-match check and the receipt-presence loop run, so a correctly-formed bug-type checkpoint should validate cleanly on both surfaces.

## Actual Behavior

The MCP tool returns:
```
Checkpoint required_mcp_tools must match routing matrix for route small.
Checkpoint missing successful MCP receipt: new_potential_entry.
```
even though the checkpoint's `required_mcp_tools` and `mcp_call_receipts` both correctly use the bug-substituted `new_potential_bug_entry` tool name. The Python CLI run against the identical file exits 0 with `orchestrator-state validation passed`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: MCP tool error: `"Checkpoint required_mcp_tools must match routing matrix for route small.\nCheckpoint missing successful MCP receipt: new_potential_entry."` vs. Python CLI: `"orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json"` (exit 0), both run against the same file content, same session.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The bug-substitution logic (`_resolve_promotion_entry_tools`, `FEATURE_PROMOTION_ENTRY_TOOL`/`BUG_PROMOTION_ENTRY_TOOL` constants) lives in `scripts/dev_tools/_orchestrator_state_routing.py` (Python). Suspect the TypeScript MCP-surface port of the orchestrator-state validator either lacks this substitution helper entirely, or reads the checkpoint's promotion-type field under a different key/casing than the Python side's `state.get("promotion-type")`. Worth checking `extensions/drm-copilot/src/lib/validate/orchestrator-state-*` (or equivalent) for an equivalent `_resolve_promotion_entry_tools`/`resolvePromotionEntryTools` implementation and whether it exists and is wired into the `require_complete` path at all.

This is the same general class of Python/TypeScript parity gap already tracked for the `parallel` surface (see the "Verified scope" divergence notes in `.claude/rules/parallel-orchestration.md`), but for the standard `orchestrator-state` artifact type, which does not currently document any known TS/Python divergence.

Workaround used: treat the Python CLI as authoritative per the existing documented precedent ("the Python validator is authoritative for full per-receipt correctness") and proceed on its result when the two surfaces disagree specifically on this check.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: a TypeScript unit test constructing a bug-type checkpoint (mirroring the existing Python test fixtures for `_resolve_promotion_entry_tools`) and asserting the MCP/TS surface accepts it under `require_complete`.
- [x] Integration scenario to retest: re-run `mcp__drm-copilot__validate_orchestration_artifacts` against the checkpoint that produced this report (issue #620's `artifacts/orchestration/orchestrator-state.json`, feature folder `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/`) once fixed, and confirm it now passes.
- [ ] Manual verification notes

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
