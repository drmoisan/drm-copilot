# resync-bundled-orchestration-validator (Issue #196)

- Date captured: 2026-06-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/resync-bundled-orchestration-validator/ (Issue #196)

- Issue: #196
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/196
- Last Updated: 2026-06-17
- Work Mode: full-bug

## Problem / Why

The MCP tool `validate_orchestration_artifacts` (published in `@danmoisan/drm-copilot-mcp`) runs the bundled Python validator at `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestration_artifacts.py`. That bundled copy is a stale monolith (dated 2026-05-01) that predates the repo-source refactor (2026-06-16) which split the validator into:

- `scripts/dev_tools/validate_orchestration_artifacts.py` (thin dispatcher)
- `scripts/dev_tools/validate_orchestrator_state.py`
- `scripts/dev_tools/_orchestrator_state_human_interaction.py`
- `scripts/dev_tools/validate_orchestration_review_artifacts.py`
- `scripts/dev_tools/validate_policy_audit_artifact.py`

As a result the MCP tool rejects checkpoints that the repo-source validator accepts. Observed divergences in the bundled monolith:

- Rejects the `completed` value for `step5_status`..`step10_status` (its `VALID_STEP_STATUS` is stale).
- Requires list-form `delegation_receipts` and does not accept the additive `delegation_receipts.promotion.*` namespace mandated by the orchestrate skill.
- Has no awareness of the `human_interaction` block or the `remediation_loop` cycle invariants.

This was observed during issue #194 orchestration: `validate_orchestration_artifacts` failed while the repo-source validator (`scripts/dev_tools/validate_orchestrator_state.py`) passed `require_complete=True`.

## Proposed Behavior

Re-sync the bundled validator mirror under `extensions/drm-copilot/resources/scripts/dev_tools/` so the MCP tool's behavior matches the repo-source validator, and add a parity guard so the bundle cannot silently drift again.

- The bundled mirror must reproduce the current repo-source validation logic (status enum including `completed`, namespaced promotion receipts, `human_interaction` invariants, `remediation_loop` cycle invariants).
- Follow the established bundle convention used by other multi-module packages already present in the bundle (e.g., `new_active_feature_folder_*.py`), including any import-path rewriting from `scripts.dev_tools.*` to `dev_tools.*` performed at sync time.
- Add or extend an automated parity/contract test so a future divergence between `scripts/dev_tools/` validator sources and the bundled mirror fails CI.

## Acceptance Criteria (early draft)

- [ ] The MCP `validate_orchestration_artifacts` tool accepts an orchestrator-state checkpoint that the repo-source validator accepts (including `completed` statuses, namespaced promotion receipts, `human_interaction`, and `remediation_loop`).
- [ ] The bundled mirror reproduces the repo-source validator behavior for plan, policy-audit, code-review, feature-audit, and orchestrator-state artifact types.
- [ ] A parity/contract test detects divergence between the validator sources and the bundled mirror and fails CI on drift.
- [ ] Python toolchain (Black, Ruff, Pyright, Pytest) passes; coverage thresholds met.

## Constraints & Risks

- Import-path semantics differ between source (`scripts.dev_tools.*`) and bundle (`dev_tools.*` via `resources/scripts` on `sys.path`). The resync must preserve correct imports in the bundle.
- The bundle is consumed by the published npm MCP package; behavior parity with the repo source is the goal.
- File-size limit (500 lines) and bundled-mirror sync obligations apply.
- Must not modify the canonical policy/source validator behavior; this is a propagation/guard task, not a semantics change.

## Test Conditions to Consider

- [ ] MCP-path validation of a `completed`/namespaced-receipts checkpoint succeeds.
- [ ] Parity test fails when a source validator module changes without a matching bundle update.
- [ ] Each artifact type round-trips through the bundled dispatcher.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create active feature folder from the template