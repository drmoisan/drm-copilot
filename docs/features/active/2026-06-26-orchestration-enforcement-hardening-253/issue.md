# orchestration-enforcement-hardening (Issue #253)

- Date captured: 2026-06-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestration-enforcement-hardening/ (Issue #253)

- Issue: #253
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/253
- Last Updated: 2026-06-26
- Work Mode: full-feature

## Problem / Why

An orchestration run recorded `path_selected: "small"` (work-mode minor-audit) yet deviated from the small route's defined procedure: no promotion, `issue-num: "n/a"`, `feature-folder: "n/a"`, no atomic plan, no feature-review audit, and a fabricated `execution_mode: "direct_powershell_engineer_remediation"` that is not a key in `config/orchestration-routing.json`. The checkpoint still reached `next_step: "complete"`. No enforcement surface stopped it.

Research (`docs/research/20260626-orchestration-enforcement-hardening-research.md`) confirmed six gaps are still open after the merged #207/#230/#232 work, plus a routing-matrix agent-name defect.

## Proposed Behavior

Close the diagnosed gaps so a route cannot deviate from its defined procedure undetected:

1. Wire the routing-contract validator into the SubagentStop completion gate (`validate-orchestrator-output.ps1`) via an injectable subprocess seam to the authoritative Python validator.
2. Reject sentinel/placeholder values (`n/a`, `none`, `tbd`, empty, whitespace) in `issue-num` and `feature-folder` presence checks; require digits-only issue numbers and `docs/features/active/...` feature folders.
3. Close the Edit-tool bypass on the orchestrator checkpoint via read-then-validate against the on-disk file.
4. Generalize the hardcoded issue-`232` special-casing into route-driven `requires_pr_gate` matrix data.
5. Add route-membership and phase-completeness validation that rejects unknown route/`execution_mode` values.
6. (Low priority) Provide a checkpoint-transition audit trail.

Also reconcile `config/orchestration-routing.json` `large` route agent names (`feature-reviewer`, `commit-steward`) with the agents that actually exist (`feature-review`, `pr-author`), and keep the bundled mirror byte-identical.

## Acceptance Criteria (early draft)

- [x] AC1: `validate-orchestrator-output.ps1` invokes the routing-contract validator through an injectable subprocess seam and blocks DONE with `ROUTING_CONTRACT_BLOCKED: ...` on any routing error; allows when clean.
- [x] AC2: `enforce-completion-consistency.ps1` rejects sentinel/invalid `issue-num` (non-digit) and `feature-folder` (sentinel or not under `docs/features/active/`) values with named errors, via testable helpers.
- [x] AC3: `enforce-completion-consistency.ps1` validates completion-asserting Edit-tool patches by reading the on-disk checkpoint and applying the patch in memory; allows on missing file or non-matching patch.
- [x] AC4: The literal `"232"` no longer appears in any condition in `enforce-completion-consistency.ps1` or `enforce-orchestration-preimplementation-gate.ps1`; `ISSUE_232`/`ISSUE_232_BRANCH` are removed from `validate_orchestrator_state.py`; `pr_gate` is required only when the route's `requires_pr_gate` is true.
- [x] AC5: `validate_route_membership` rejects a checkpoint whose `route_id`/`path_selected` is not a routing-matrix key (including `direct_powershell_engineer_remediation`); phase-completeness is verified at completion.
- [x] AC6: `config/orchestration-routing.json` and its bundled mirror contain only real agent names in every route and remain byte-identical (parity test passes).
- [x] AC7: All four quality toolchains pass with no coverage regression (Python: Black/Ruff/Pyright/Pytest; PowerShell: PoshQC format/analyze/Pester), and existing tests continue to pass.

## Constraints & Risks

- Backward compatibility: existing checkpoints without new fields must keep validating; strict route-membership is opt-in (enabled at the completion gate), `requires_pr_gate` defaults to false when absent.
- No PowerShell reimplementation of the Python routing logic; call the authoritative validator via subprocess.
- File-size limit: `enforce-completion-consistency.ps1` (301 lines) and `validate_orchestrator_state.py` (506 lines) must stay under 500 lines; extract helpers if needed.
- The two routing JSON files must change in lockstep.

## Test Conditions to Consider

- [x] Pester: routing-validator subprocess block/allow with mocked seam; sentinel rejection matrix; Edit-patch read-then-validate; route-driven `pr_gate`.
- [x] Pytest: unknown-route rejection; route-driven `pr_gate`; removal of #232 branch assertion; phase-completeness pass/fail.
- [x] Parity: `test_orchestration_routing_config_parity.py` passes after both JSON files update.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/orchestration-enforcement-hardening/` folder from the template