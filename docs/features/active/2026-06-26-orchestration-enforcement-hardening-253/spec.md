# orchestration-enforcement-hardening — Spec

- **Issue:** #253
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-26T15-43
- **Status:** Draft
- **Version:** 0.1

## Overview

An orchestration run recorded `path_selected: "small"` (work-mode minor-audit) yet deviated from the small route's defined procedure: no promotion, `issue-num: "n/a"`, `feature-folder: "n/a"`, no atomic plan, no feature-review audit, and a fabricated `execution_mode: "direct_powershell_engineer_remediation"` that is not a key in `config/orchestration-routing.json`. The checkpoint still reached `next_step: "complete"`. No enforcement surface stopped it.

Research (`docs/research/20260626-orchestration-enforcement-hardening-research.md`) confirmed six gaps are still open after the merged #207/#230/#232 work, plus a routing-matrix agent-name defect. This feature closes those gaps so that a route cannot deviate from its defined procedure undetected, and reconciles the routing matrix so it references only agents that exist.

## Behavior

Close the diagnosed gaps so a route cannot deviate from its defined procedure undetected:

1. **Gap 1 — Routing validator at the completion gate.** Wire the routing-contract validator into the SubagentStop completion gate (`validate-orchestrator-output.ps1`) via an injectable subprocess seam to the authoritative Python validator. The hook blocks DONE with `ROUTING_CONTRACT_BLOCKED: <error list>` when the validator returns errors and allows when clean.
2. **Gap 2 — Sentinel rejection.** Reject sentinel/placeholder values (`n/a`, `none`, `tbd`, empty, whitespace) in `issue-num` and `feature-folder` presence checks in `enforce-completion-consistency.ps1`; require digits-only issue numbers and `docs/features/active/...` feature folders, via testable helpers.
3. **Gap 3 — Edit-tool bypass closed.** Close the Edit-tool bypass on the orchestrator checkpoint via read-then-validate: when an Edit targets the checkpoint path, read the on-disk file through an injectable seam, apply the `old_string`→`new_string` patch in memory, and run the completion checks on the result. Allow on missing file or non-matching patch.
4. **Gap 4 — Route-driven `requires_pr_gate`.** Generalize the hardcoded issue-`232` special-casing into a route-driven `requires_pr_gate` matrix field. Remove the `"232"` literals from the PowerShell hooks and the `ISSUE_232`/`ISSUE_232_BRANCH` constants from `validate_orchestrator_state.py`. Apply `pr_gate` checks only when the checkpoint's route has `requires_pr_gate == true`.
5. **Gap 5 — Route membership and phase completeness.** Add `validate_route_membership` and `validate_phase_completeness` to `_orchestrator_state_routing.py`. Reject unknown routes such as `direct_powershell_engineer_remediation`. Call route-membership unconditionally (with an opt-in strict parameter) and phase-completeness under `require_complete`.
6. **Gap 6 — Audit trail (deferred, low priority).** Provide a checkpoint-transition audit trail. This gap is diagnostic, not preventive, and is deferred until Gaps 1–5 are closed. It is documented here for traceability but is not required for this feature's Definition of Done.

**Agent-name reconciliation.** Reconcile `config/orchestration-routing.json` `large` route agent names (`feature-reviewer`, `commit-steward`) with the agents that actually exist: replace `feature-reviewer` with `feature-review` and replace `commit-steward` with `pr-author`. Keep the bundled mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` byte-identical.

## Inputs / Outputs

- **Inputs:**
  - `artifacts/orchestration/orchestrator-state.json` — the orchestrator checkpoint read/validated by the hooks and the Python validator.
  - `config/orchestration-routing.json` — the routing matrix; source of `required_agents`, `required_skills`, `required_mcp_tools`, and the new `requires_pr_gate` field.
  - Tool-call payloads (`Write`/`Edit` `tool_input`) intercepted by the PreToolUse and SubagentStop hooks.
- **Outputs:**
  - Hook decisions (`allow` / block) with named block messages (e.g., `ROUTING_CONTRACT_BLOCKED: ...`, sentinel/feature-folder rejection messages).
  - Python validator error lists (strings) consumed by the subprocess seam.
- **Config keys and defaults:**
  - `requires_pr_gate` (boolean) on routing-matrix routes. Default when absent: `false`. Set to `true` on the `large` route; absent or `false` on `small` and `remediation`.
- **Versioning / backward-compatibility constraints:**
  - Existing checkpoints without new fields must continue to validate.
  - `strict_route_membership` defaults to `false`; only the completion gate opts into `true`.
  - The two routing JSON files must change in lockstep and remain byte-identical.

## API / CLI Surface

- **`validate-orchestrator-output.ps1`** — add `Invoke-RoutingContractValidation` with an injectable subprocess scriptblock seam (default produces the real call). Insert the call inside `Invoke-OrchestratorOutputValidation` after the `human_interaction` check and before the final allow. On routing errors, return `{ Ok = $false; Message = "ROUTING_CONTRACT_BLOCKED: ..." }`.
- **`validate_orchestration_artifacts.py`** — add a `__main__` CLI entry if absent, supporting `--file <path> --require-complete`, so the PowerShell subprocess seam can invoke the authoritative validator.
- **`enforce-completion-consistency.ps1`** — add helpers `Test-IsValidIssueNum` (rejects sentinel set and any non-digit string; requires `^\d+$`) and `Test-IsValidFeatureFolder` (rejects sentinel set; requires `docs/features/active/` prefix plus a non-empty suffix; optional injectable `FolderExistsCheck` seam). Add an injectable `CheckpointReader` seam for the read-then-validate Edit path. Replace `$issueNum -eq '232'` with a routing-matrix `requires_pr_gate` lookup.
- **`enforce-orchestration-preimplementation-gate.ps1`** — remove `$script:Issue232FeatureFolder` and the hardcoded #232 checks; generalize block messages to name the missing checkpoint fields rather than the issue number.
- **`_orchestrator_state_routing.py`** — add `validate_route_membership(state, matrix)` and `validate_phase_completeness(state, route_map)`, each returning a list of error strings.
- **`validate_orchestrator_state.py`** — call `validate_route_membership` unconditionally (gated by a new `strict_route_membership: bool = False` parameter); call `validate_phase_completeness` under `require_complete=True`; remove `ISSUE_232`/`ISSUE_232_BRANCH` and the branch-name check; drive `pr_gate` from the route's `requires_pr_gate`.

- **Contracts and validation rules:**
  - `issue-num` must match `^\d+$` and must not be in `{n/a, none, tbd, empty, whitespace-only}`.
  - `feature-folder` must start with `docs/features/active/`, carry a non-empty suffix, and must not be a sentinel value.
  - `route_id`/`path_selected` must be a key in `matrix["routes"]`; `direct_powershell_engineer_remediation` is rejected.
  - `pr_gate` is required if and only if the route's `requires_pr_gate == true`.

## Data & State

- **Data flow:** Hooks intercept `Write`/`Edit` tool calls and the SubagentStop event; they parse the checkpoint JSON (directly for Write, via read-then-patch for Edit), evaluate completion evidence, optionally invoke the Python validator through a subprocess, and emit an allow/block decision. The Python validator reads the checkpoint and the routing matrix and returns an error list.
- **Data transformations and invariants:**
  - Edit patches are applied in memory only; no on-disk mutation is performed by the hook.
  - Validator functions are pure with respect to their inputs (return error lists; no `sys.exit`, no disk writes).
  - The two routing JSON files remain byte-identical.
- **Caching or persistence details:** No new persistent state for Gaps 1–5. Gap 6 (deferred) would introduce an append-only `artifacts/orchestration/orchestrator-state.log.jsonl` capped at 100 entries; out of scope for this feature.
- **Migration or backfill requirements:** None. `requires_pr_gate` defaults to `false` when absent; old checkpoints without `route_id`/`path_selected` validate unchanged under non-strict route membership.

## Constraints & Risks

- Backward compatibility: existing checkpoints without new fields must keep validating; strict route-membership is opt-in (enabled at the completion gate), `requires_pr_gate` defaults to false when absent.
- No PowerShell reimplementation of the Python routing logic; call the authoritative validator via subprocess.
- File-size limit: `enforce-completion-consistency.ps1` (301 lines) and `validate_orchestrator_state.py` (506 lines) must stay under 500 lines; extract helpers if needed (e.g., a dot-sourced helper script following the existing `ConvertFrom-CheckpointJson` seam pattern).
- The two routing JSON files must change in lockstep and remain byte-identical (enforced by `test_orchestration_routing_config_parity.py`).
- Edit read-then-validate risk (on-disk divergence, non-unique `old_string`, missing file) is bounded by allowing on missing file or non-matching patch and by the injectable `CheckpointReader` seam.

## Implementation Strategy

- **Implementation scope (affected production files):**

  Python (Black / Ruff / Pyright / Pytest):
  - `scripts/dev_tools/_orchestrator_state_routing.py` — add `validate_route_membership()` and `validate_phase_completeness()` (Gap 5).
  - `scripts/dev_tools/validate_orchestrator_state.py` — call `validate_route_membership` (with `strict_route_membership` param); call `validate_phase_completeness` under `require_complete`; remove `ISSUE_232`/`ISSUE_232_BRANCH`; drive `pr_gate` from `requires_pr_gate` (Gaps 4, 5).
  - `scripts/dev_tools/validate_orchestration_artifacts.py` — add `__main__` CLI entry if absent (Gap 1).
  - `config/orchestration-routing.json` — add `requires_pr_gate: true` to `large`; replace `feature-reviewer` with `feature-review` and `commit-steward` with `pr-author` (Gap 4, agent-name fix).
  - `extensions/drm-copilot/resources/config/orchestration-routing.json` — byte-identical mirror of the above.

  PowerShell (PoshQC format / analyze / Pester):
  - `.claude/hooks/validate-orchestrator-output.ps1` — add `Invoke-RoutingContractValidation` with injectable subprocess seam; call after the `human_interaction` check (Gap 1).
  - `.claude/hooks/enforce-completion-consistency.ps1` — add `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder`; replace sentinel-passing checks; add Edit-tool read-then-validate; replace #232 hardcoding with routing-matrix lookup (Gaps 2, 3, 4).
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — remove `$script:Issue232FeatureFolder` and hardcoded #232 checks; generalize block messages (Gap 4).

- **New functions/commands to add or update:** `Invoke-RoutingContractValidation`, `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder` (PowerShell); `validate_route_membership`, `validate_phase_completeness`, `__main__` CLI entry (Python).
- **Dependency changes:** None. No new packages.
- **Logging/telemetry additions:** Named block messages on the hook decisions only. No new telemetry sinks. Gap 6 audit log is deferred.
- **Rollout plan:** No feature flags. Backward compatibility is preserved by default-off strict route membership and `requires_pr_gate` defaulting to `false`.

- **Module rigor tiers and toolchains:**
  - `scripts/dev_tools/` — T2 (Core; orchestration guardrails / CI gates).
  - `.claude/hooks/` — scaffolding (T4) elevated to T2 for completion gates.
  - Uniform gate matrix applies to both: format 100% pass, 0 lint errors, 0 type errors (Python), 0 architecture violations, line coverage >= 85%, branch coverage >= 75%, no regression on changed lines.
  - Required toolchains: Python — Black, Ruff, Pyright, Pytest; PowerShell — PoshQC format, PoshQC analyze, Pester. All existing tests must continue to pass.

## Definition of Done

- [x] AC1: `validate-orchestrator-output.ps1` invokes the routing-contract validator through an injectable subprocess seam and blocks DONE with `ROUTING_CONTRACT_BLOCKED: ...` on any routing error; allows when clean.
- [x] AC2: `enforce-completion-consistency.ps1` rejects sentinel/invalid `issue-num` (non-digit) and `feature-folder` (sentinel or not under `docs/features/active/`) values with named errors, via testable helpers.
- [x] AC3: `enforce-completion-consistency.ps1` validates completion-asserting Edit-tool patches by reading the on-disk checkpoint and applying the patch in memory; allows on missing file or non-matching patch.
- [x] AC4: The literal `"232"` no longer appears in any condition in `enforce-completion-consistency.ps1` or `enforce-orchestration-preimplementation-gate.ps1`; `ISSUE_232`/`ISSUE_232_BRANCH` are removed from `validate_orchestrator_state.py`; `pr_gate` is required only when the route's `requires_pr_gate` is true.
- [x] AC5: `validate_route_membership` rejects a checkpoint whose `route_id`/`path_selected` is not a routing-matrix key (including `direct_powershell_engineer_remediation`); phase-completeness is verified at completion.
- [x] AC6: `config/orchestration-routing.json` and its bundled mirror contain only real agent names in every route and remain byte-identical (parity test passes).
- [x] AC7: All four quality toolchains pass with no coverage regression (Python: Black/Ruff/Pyright/Pytest; PowerShell: PoshQC format/analyze/Pester), and existing tests continue to pass.
- [ ] AC8: The `large` route's `required_mcp_tools` lists only MCP tools the orchestrator is permitted to exercise (per the `.claude/settings.json` allow list). `collect_commit_context` — defined in the extension but absent from the orchestrator allow list and never invoked by an orchestrator skill — is removed from the `large` route in both `config/orchestration-routing.json` and the byte-identical bundled mirror, so a fully-exercised large-route checkpoint passes the routing-contract completion validator (`validate_routing_contract`) with no unsatisfiable receipt. Parity and routing-contract tests pass.
- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Affected Test Files

Python (Pytest):
- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` — add unknown-route rejection tests; remove #232-specific branch-name tests; large-route positive test with updated agent list.
- `tests/scripts/dev_tools/test_validate_orchestrator_state.py` — add `validate_route_membership` unit tests; route-driven `pr_gate` tests; phase-completeness pass/fail.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — add CLI `--require-complete` subprocess tests if `__main__` is added.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` — no change needed; byte-identical guard catches mirror drift automatically.

PowerShell (Pester):
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` — routing-validator subprocess mock contexts (block on errors, allow when clean, mockable seam).
- `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` — sentinel rejection matrix, feature-folder validation, Edit-bypass read-then-validate, routing-matrix `pr_gate` lookup.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` — update hardcoded-path tests to use generalized assertions.

## Seeded Test Conditions (from potential)
- [x] Pester: routing-validator subprocess block/allow with mocked seam; sentinel rejection matrix; Edit-patch read-then-validate; route-driven `pr_gate`.
- [x] Pytest: unknown-route rejection; route-driven `pr_gate`; removal of #232 branch assertion; phase-completeness pass/fail.
- [x] Parity: `test_orchestration_routing_config_parity.py` passes after both JSON files update.
