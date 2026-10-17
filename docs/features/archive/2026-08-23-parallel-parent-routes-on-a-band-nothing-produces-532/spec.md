# parallel-parent-routes-on-a-band-nothing-produces (Spec)

- **Issue:** #532
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T20-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Branch:** `bug/parallel-parent-routes-on-a-band-nothing-produces-532`
- **Research:** `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/research/research.2026-09-29T19-50.md`

## Problem Statement

`.claude/skills/parallel-orchestrate/SKILL.md` (`## Parallel-Mode Kickoff Parameter`, `## Model Selection`) and `.claude/agents/parallel-orchestrator.md` (`## Delegation Model`) require `parallel-orchestrator` to pass `model` equal to "that item's model routing receipt's resolved model" when it spawns each item's `Agent(orchestrator)`, and forbid omitting `model` or hard-coding `opus`. No stage on the parallel surface produces the band or the receipt that obligation depends on:

- `.claude/skills/parallel-plan/SKILL.md` has no complexity-assessment procedure. `complexity_band` and `model_routing_receipt` appear only in the checkpoint field list.
- `scripts/dev_tools/validate_parallel_planner_state.py` does not list `complexity_band` or `model_routing_receipt` in `REQUIRED_ITEM_KEYS`; the band enum check is presence-gated, and the readiness gate (`_validate_ready_item`, invariant P7) checks neither field.
- The TypeScript MCP validator `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`, which is the path the planner actually invokes through `mcp__drm-copilot__validate_orchestration_artifacts`, enforces the same absence of routing checks.
- `parallel-orchestrate/SKILL.md` never names where the parent obtains the band or receipt.

The documented failure mode is therefore the actual behaviour: the parent spawns with no routing input and the child runs on the delegate's `opus` frontmatter default. Per research Section 3.4, for `agent == "orchestrator"` this means C1 and C2 items run on `opus` instead of `haiku`/`sonnet` under every `fable_policy`, and C4 items run on `opus` instead of `fable` under `available` and `preferred`.

The defect was verified present at `b7b4a2dc` (research Section 1).

## Root Cause

Incomplete port of the epic-surface routing mechanism. The parallel surface carried over the per-item field names (`complexity_band`, `model_routing_receipt`) and the kickoff `complexity` column, but not:

1. a band-derivation procedure in the parallel planner skill (the epic analogue is `.claude/skills/epic-plan/SKILL.md` `## Complexity Assessment`);
2. a validator requirement that the band and a matching receipt exist before execution readiness is declared (the epic analogue is `scripts/dev_tools/validate_epic_planner_state.py`, which requires `complexity_band` and cross-checks it against the ready-gated `model_routing_receipt.complexity_band`);
3. a named source for the parent's spawn-time routing input in `parallel-orchestrate/SKILL.md` and `parallel-orchestrator.md`.

The parallel planner-state validator records the optionality as "the backward-compatible shape", which allowed the gap to pass review. The deliberate omission of an `epic_worthiness` analogue on the parallel surface is a separate, correct decision about a scale gate; the per-item band is a routing input and is not settled by that decision.

## Scope

In scope:

1. A new ready-gate invariant **P10** in the parallel planner checkpoint validators (Python authoritative, TypeScript structural subset), enforced only when `require_ready_for_execution` is true.
2. Reuse of the existing Claude-side Python helpers for P10: `_validate_complexity_assessments` (`scripts/dev_tools/_orchestrator_state_complexity.py`), `_validate_model_routing_receipts` (`scripts/dev_tools/_orchestrator_state_model_routing.py`), `BAND_ORDER` / `compute_complexity_floor` (`scripts/dev_tools/compute_complexity_floor.py`), and `resolve_delegation_model` (`scripts/dev_tools/resolve_delegation_model.py`).
3. New routing helper modules so no production or test file exceeds 500 lines:
   - `scripts/dev_tools/_parallel_planner_state_routing.py`
   - `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts`
4. Relocation of the Python planner-state test builders to a non-test support module with a re-export from the existing test module.
5. Runtime text changes, each with its byte-identical bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`:
   - `.claude/skills/parallel-plan/SKILL.md`
   - `.claude/skills/parallel-orchestrate/SKILL.md`
   - `.claude/skills/parallel-add/SKILL.md`
   - `.claude/agents/parallel-planner.md`
   - `.claude/agents/parallel-orchestrator.md`
   - `.claude/rules/parallel-orchestration.md`
6. Unit and contract-text tests in Python and TypeScript.

## Non-Scope

- Adding `complexity_band` or `model_routing_receipt` to the unconditional `REQUIRED_ITEM_KEYS` (research option a1). Mid-preparation checkpoints remain valid without them.
- The Codex receipt family. `validate_codex_model_routing_receipts` and `resolve_codex_deployment` are not used; their `model` values cannot be passed to `Agent(orchestrator)` and they have no parallel `execution_context`.
- Recording the parent's spawn receipts in the parallel orchestrator checkpoint (research option b1). No change to `scripts/dev_tools/validate_parallel_orchestrator_state.py`, its `_parallel_state_*.py` helpers, or the TypeScript orchestrator-state port.
- A TypeScript port of `compute_complexity_floor` or `resolve_delegation_model` (research option T-full).
- Re-assessment of an item's band when its plan is amended after kickoff.
- A PreToolUse hook gating the `model` of an `Agent(orchestrator)` spawn. `.claude/hooks/enforce-model-routing-receipt.ps1` is unchanged.
- Changes to `.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md`, `.claude/skills/epic-orchestrate/SKILL.md`, the epic validators, the parallel run manifest schema (M6), `scripts/dev_tools/parallel_kickoff_contract.py`, or `scripts/dev_tools/_parallel_drift_scheduling.py`.
- The `parallel-planner` agent `tools:` allowlist (no `pwsh` grant is added; research Section 3.5 observation).
- Backfilling any committed checkpoint fixture (none exists; research Section 6.3).

## Functional Requirements

### FR1 — Per-item routing record (planner checkpoint)

Under the ready gate, each object-shaped `items[]` entry carries:

- `complexity_band`: one of `C1`, `C2`, `C3`, `C4`.
- `complexity_assessment`: object `{ band, floor, signals_present, rationale, assessed_at }`, where `floor == compute_complexity_floor(signals_present)`, `band >= floor`, `rationale` is a non-empty string, and `assessed_at` is a non-empty string.
- `model_routing_receipt`: Claude delegation receipt object `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from, model }` with `agent == "orchestrator"`, `complexity_band` equal to the item's `complexity_band`, `fable_policy` in `{disabled, available, preferred}`, and `model == resolve_delegation_model("orchestrator", complexity_band, fable_policy)["model"]`, including the existing disabled-mode clamp invariants.

### FR2 — Python P10 enforcement

`scripts/dev_tools/_parallel_planner_state_routing.py` exposes a pure function that validates one item record under the ready gate and returns an ordered error list. `validate_parallel_planner_state.py` calls it for each object-shaped item from `_validate_ready_gate`, immediately after that item's P7 errors, so P7 ordering is unchanged. With the gate off, P10 contributes zero errors.

Per item, with `<ctx>` = `Parallel planner checkpoint items[<i>]`, the P10 checks and their error strings are, in this order:

| # | Condition | Error |
| --- | --- | --- |
| 1 | `complexity_band` not in `C1`-`C4` (absent reports `None`) | `enum_error(<ctx>, "complexity_band", BAND_ORDER, value)`, i.e. `<ctx> complexity_band must be one of C1, C2, C3, C4; found: <repr>.` |
| 2 | `complexity_assessment` absent or not an object | `<ctx> complexity_assessment must be an object.` (checks 3-5 skipped) |
| 3 | Entry errors from `_validate_complexity_assessments([assessment])` | Each string with the prefix `Checkpoint complexity_assessments #0` replaced by `<ctx> complexity_assessment` |
| 4 | `assessed_at` not a non-empty string | `<ctx> complexity_assessment.assessed_at must be a non-empty string.` |
| 5 | `complexity_assessment.band != complexity_band` | `<ctx> complexity_assessment.band <repr> does not equal complexity_band <repr>.` |
| 6 | `model_routing_receipt` absent or not an object | `<ctx> model_routing_receipt must be an object.` (checks 7-10 skipped) |
| 7 | Entry errors from `_validate_model_routing_receipts([receipt])` | Each string with the prefix `Checkpoint model_routing_receipts #0` replaced by `<ctx> model_routing_receipt` |
| 8 | `agent != "orchestrator"` | `<ctx> model_routing_receipt.agent must be 'orchestrator'; found: <repr>.` |
| 9 | `receipt.complexity_band != complexity_band` | `<ctx> model_routing_receipt.complexity_band <repr> does not equal complexity_band <repr>.` |
| 10 | `fable_policy` not in `disabled, available, preferred` | `enum_error(<ctx>, "model_routing_receipt.fable_policy", ("disabled", "available", "preferred"), value)` |

Checks 5 and 9 are reported whenever the two values differ, including when the item band itself failed check 1, mirroring the epic planner cross-check. The helper performs no I/O and raises no exceptions for malformed input. The module does not reimplement the floor or model formulas.

### FR3 — TypeScript P10 structural subset

`extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` implements the P10 checks that need no resolver, and `validateReadyGate` in `parallel-planner-state-core.ts` calls it per item after that item's P7 errors. The TypeScript subset enforces:

- check 1 (band enum);
- check 2 (assessment object);
- from check 3: assessment `band` enum, `signals_present` list-of-strings, `band >= floor` ordering when both are valid bands, non-empty `rationale`;
- checks 4, 5, 6, 8, 9, 10;
- from check 7: receipt `complexity_band` enum.

Every string the TypeScript subset emits is identical to the corresponding Python string. The TypeScript subset does not enforce `floor == compute_complexity_floor(signals_present)`, `model == resolve_delegation_model(...)`, or the disabled-mode clamp; the Python validator is authoritative for those. With the gate off, the TypeScript P10 contributes zero errors.

### FR4 — Unconditional behaviour unchanged

Outside the ready gate, `complexity_band` remains optional and presence-gated (P3). `REQUIRED_ITEM_KEYS` is unchanged. The source comment in `_validate_item_contract` and the module docstring are updated to state that absence is permitted only outside the ready gate.

### FR5 — `parallel-plan` skill and `parallel-planner` agent

- `.claude/skills/parallel-plan/SKILL.md` gains a `## Complexity Assessment` section that states: the assessment point (after the item is `prepared`, preflight `PREFLIGHT: ALL CLEAR`, and radius V1/V2-clear, and before cohort seeding, which consumes the band); the signals and scale source (`config/orchestration-routing.json` `model_policy`); floor computation via `Get-ComplexityFloor` (`.claude/lib/model-routing/ModelRouting.psm1`) or `compute_complexity_floor`; model resolution via `Resolve-DelegationModel -Agent orchestrator` or `resolve_delegation_model`; the FR1 record shape; that the kickoff `## Item Summary` `complexity` cell equals `complexity_band`; and that the band is a routing input distinct from the deliberately absent worthiness verdict.
- The readiness contract in the same skill lists P10.
- The preparation-child collection sentence that currently says `logical_agent: "orchestrator"` uses the Claude receipt field `agent: "orchestrator"`.
- `.claude/agents/parallel-planner.md` adds `complexity_assessment` to the per-item field list and adds a Completion Requirement that each item carries a P10-valid band, assessment, and receipt.
- Existing assertions in `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` and `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py` remain satisfied (including `test_skill_contains_no_worthiness_gate`).

### FR6 — `parallel-orchestrate` skill and `parallel-orchestrator` agent

`.claude/skills/parallel-orchestrate/SKILL.md` (`## Parallel-Mode Kickoff Parameter` and `## Model Selection`) and `.claude/agents/parallel-orchestrator.md` (`## Delegation Model`) state that the parent:

- reads each item's `complexity_band` and `model_routing_receipt` from the planner checkpoint;
- uses the committed kickoff artifact's `## Item Summary` `complexity` column as the fallback band source when the planner checkpoint is unavailable;
- passes `model` equal to the receipt's `model` on the `Agent(orchestrator)` spawn when the run's `fable_policy` equals the receipt's `fable_policy`, and otherwise re-resolves with `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` and passes that result.

### FR7 — `parallel-add` skill

`.claude/skills/parallel-add/SKILL.md` step 2 requires the same complexity assessment after the admitted item's preflight clearance and records `complexity_band` on the admitted orchestrator-checkpoint item. The Constraints sentence stating that no field is added to `items[]` names `complexity_band` as an existing scheduling field read by drift re-scheduling, not a new field. No validator change accompanies this text.

### FR8 — `parallel-orchestration` rule

`.claude/rules/parallel-orchestration.md` updates: P3 states the band is optional outside the ready gate; a new P10 states FR1/FR2; the ready-gate sentence includes P10; the Enforcement section names `scripts/dev_tools/_parallel_planner_state_routing.py` and records that the TypeScript port enforces the P10 structural subset while the Python validator is authoritative for floor equality, resolved-model equality, and the disabled clamp.

### FR9 — Mirrors

Each `.claude` file changed under FR5-FR8 is byte-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`.

### FR10 — Test builders and file size

The Python builders `build_item` and `build_valid_planner_state` move to `tests/scripts/dev_tools/parallel_planner_state_builders.py` (non-test support module) and gain the three FR1 fields with values that pass P10 in both runtimes. `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` re-exports them so `test_validate_parallel_planner_state_bounds.py`, `test_validate_parallel_state_tolerated_edge_fields.py`, and `test_validate_orchestration_artifacts_parallel_dispatch.py` continue to import them unchanged. The TypeScript builders in `parallel-planner-state-core.test.ts` and `parallel-state-tolerated-edge-fields.test.ts` gain the same fields. Every new or changed production and test file is at or below 500 lines.

## Acceptance Criteria

- [x] Regression (fail-before): `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_item_without_band_assessment_or_receipt` validates, with `require_ready_for_execution=True`, a ready checkpoint whose first item omits `complexity_band`, `complexity_assessment`, and `model_routing_receipt`, and asserts the exact check-1, check-2, and check-6 error strings for that item. The executor records evidence that this test fails against the unmodified validator at `b7b4a2dc` (the validator returns no errors) and passes after the fix.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_accepts_item_with_valid_routing_record` asserts that a ready checkpoint built by the updated builders yields no errors.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_gate_off_accepts_item_without_routing_fields` asserts that a checkpoint whose items omit all three FR1 fields yields no errors with `require_ready_for_execution=False`.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_floor_that_disagrees_with_signals` asserts that an assessment with `signals_present: ["concurrency_or_ordering"]` and `floor: "C1"` yields the floor error with the rewritten `Parallel planner checkpoint items[0] complexity_assessment` prefix.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_band_below_floor` asserts the rewritten `band ... is below its floor ...` error.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_receipt_model_that_disagrees_with_resolver` asserts that a receipt `{agent: "orchestrator", complexity_band: "C2", fable_policy: "available", model: "opus"}` yields the rewritten resolver error with the `Parallel planner checkpoint items[0] model_routing_receipt` prefix.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_disabled_policy_fable_model` asserts the rewritten disabled-clamp error for a C4 receipt under `fable_policy: "disabled"` that records `model: "fable"`.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_assessment_band_mismatch` and `::test_ready_gate_rejects_receipt_band_mismatch` assert the exact check-5 and check-9 strings.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_non_orchestrator_agent` asserts the exact check-8 string.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_unknown_fable_policy` asserts the exact check-10 string for `fable_policy: "sometimes"`.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_non_object_assessment_and_receipt` asserts the check-2 and check-6 strings when the fields are strings, and that no check-3, 4, 5, 7, 8, 9, or 10 error is emitted for that item.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_missing_assessed_at` asserts the exact check-4 string.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_band_mismatch_reported_when_item_band_invalid` asserts that an item with `complexity_band: "C9"` reports check 1 and both check-5 and check-9 mismatch errors.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_p10_errors_follow_p7_errors_for_same_item` asserts that, for an item failing both P7 and P10, every P7 error precedes every P10 error in the returned list.
- [x] `scripts/dev_tools/_parallel_planner_state_routing.py` imports `_validate_complexity_assessments`, `_validate_model_routing_receipts`, and `BAND_ORDER` and does not import `validate_codex_model_routing_receipts` or `resolve_codex_deployment`; verified by `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_routing_helper_reuses_claude_helpers_only`.
- [x] `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` no longer asserts that `complexity_band` is absent from the builder; the replacement test deletes the three FR1 fields from a built item and asserts no errors with the gate off.
- [x] The builders live in `tests/scripts/dev_tools/parallel_planner_state_builders.py`, and `test_validate_parallel_planner_state_bounds.py`, `test_validate_parallel_state_tolerated_edge_fields.py`, and `test_validate_orchestration_artifacts_parallel_dispatch.py` pass without edits to their import statements.
- [x] `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` contains a fail-before regression case that validates, with the ready gate on, an item omitting all three FR1 fields and asserts the check-1, check-2, and check-6 strings; the executor records that it fails against the unmodified `parallel-planner-state-core.ts` and passes after the fix.
- [x] `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` asserts the exact strings for checks 4, 5, 8, 9, and 10, the assessment band enum, `signals_present` shape, `band >= floor` ordering, and empty `rationale`, and asserts that each string equals the Python string for the same input (fixed expected literals shared in both suites).
- [x] `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` pins the documented divergence: an assessment whose `floor` disagrees with its signals and a receipt whose `model` disagrees with the resolver each yield no TypeScript error.
- [x] `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts` and `parallel-state-tolerated-edge-fields.test.ts` builders carry the three FR1 fields; the ready-gate success cases pass; the former "complexity_band absent from builder" assertion is replaced by a gate-off case that deletes the three fields and expects no errors.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_plan_has_complexity_assessment_section` asserts that `.claude/skills/parallel-plan/SKILL.md` contains a `## Complexity Assessment` heading, the phrases `Get-ComplexityFloor` and `Resolve-DelegationModel`, and P10 in the readiness contract.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_plan_uses_claude_receipt_agent_field` asserts that `.claude/skills/parallel-plan/SKILL.md` no longer contains `logical_agent`.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestrate_names_planner_checkpoint_band_source` asserts that `.claude/skills/parallel-orchestrate/SKILL.md` `## Model Selection` names the planner checkpoint as the band and receipt source and names the kickoff `complexity` column as the fallback.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestrator_agent_names_planner_checkpoint_band_source` asserts the same named source in `.claude/agents/parallel-orchestrator.md` `## Delegation Model`.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_requires_complexity_assessment` asserts that `.claude/skills/parallel-add/SKILL.md` step 2 requires the complexity assessment and that the Constraints section identifies `complexity_band` as an existing scheduling field.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_planner_agent_requires_routing_record` asserts that `.claude/agents/parallel-planner.md` lists `complexity_assessment` and contains the band/receipt Completion Requirement.
- [x] `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestration_rule_defines_p10` asserts that `.claude/rules/parallel-orchestration.md` defines P10, names `_parallel_planner_state_routing.py`, and records the TypeScript structural-subset divergence.
- [x] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes, confirming each changed `.claude` file is byte-identical to its bundled mirror.
- [x] Existing surface-contract tests pass unchanged, including `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_contains_no_worthiness_gate`, `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`, and `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
- [x] `git diff --stat origin/main` shows no change to `scripts/dev_tools/validate_parallel_orchestrator_state.py`, `scripts/dev_tools/_parallel_state_common.py`, `scripts/dev_tools/_parallel_state_structures.py`, `scripts/dev_tools/_parallel_state_records.py`, `scripts/dev_tools/validate_epic_planner_state.py`, `.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md`, or `.claude/hooks/enforce-model-routing-receipt.ps1`.
- [x] `REQUIRED_ITEM_KEYS` in `scripts/dev_tools/validate_parallel_planner_state.py` is unchanged, and the `_validate_item_contract` comment no longer describes band absence as the backward-compatible shape without qualifying it as permitted only outside the ready gate.
- [x] Every new or changed production and test file is at or below 500 lines, verified by line count in the executor's evidence.
- [x] Line coverage >= 85% and branch coverage >= 75% for `scripts/dev_tools/_parallel_planner_state_routing.py` and `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts`, with no coverage regression on changed lines of `validate_parallel_planner_state.py` and `parallel-planner-state-core.ts`, recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] Python toolchain (Black, Ruff, Pyright, pytest) and TypeScript toolchain (Prettier, ESLint, tsc, Jest) complete in a single clean pass, recorded under `<FEATURE>/evidence/qa-gates/`.

## Backward Compatibility

- Checkpoints validated with `require_ready_for_execution=False` are unaffected: `REQUIRED_ITEM_KEYS` and the presence-gated P3 band enum are unchanged, so mid-preparation checkpoints written by an older planner continue to validate.
- A checkpoint that previously passed the ready gate without the FR1 fields now fails it. No committed planner checkpoint exists (planner checkpoints live under the gitignored `artifacts/orchestration/`), and planner checkpoints are not re-validated after kickoff, so the change affects only runs planned after the fix.
- In-flight runs retain a band source through the FR6 fallback: committed kickoff artifacts already carry `C1`-`C4` values in the `## Item Summary` `complexity` column.
- The Python CLI (`validate_orchestration_artifacts.py parallel-planner-state --require-ready-for-execution`) and the MCP tool input schema are unchanged; only the set of errors returned under the ready gate grows.
- The parallel orchestrator checkpoint schema and validators are unchanged. `_parallel_drift_scheduling.py` continues to read an optional `complexity_band` from orchestrator-checkpoint items.

## Risks and Mitigations

| Risk | Mitigation |
| --- | --- |
| Python and TypeScript error strings drift for the shared checks. | FR3 requires identical strings; AC pins the same literals in both suites. |
| The TypeScript MCP path, which the planner uses at runtime, does not enforce floor or model equality, so a planner validating only through MCP can pass with a wrong `floor` or `model`. | Divergence is documented in the rule (FR8) and pinned by test; the Python CLI remains authoritative; the TypeScript port of the formulas is recorded as a follow-up. |
| Prefix rewriting silently fails if a reused helper's message prefix changes. | Tests assert exact rewritten strings, so a prefix change fails the suite. |
| Planner-time receipt becomes stale if the operator runs with a different `fable_policy`. | FR6 requires spawn-time re-resolution when the run policy differs from the receipt policy. |
| A band assessed too low routes to `haiku`/`sonnet`; staleness after plan amendment is not guaranteed to fail toward `opus`. | Assessment occurs after V1/V2 re-plan; post-kickoff re-assessment is a recorded follow-up. |
| The planner lacks a `pwsh` tool grant for `ModelRouting.psm1`. | The skill names both the PowerShell and Python entry points; the planner uses the same route it already uses for `BlastRadius.psm1`. The grant question is recorded as a follow-up. |
| Moving test builders breaks importers. | Re-export from the original module; AC requires the three importers pass without import edits. |

## Follow-ups (out of scope, to be filed separately)

1. Record the parent's actual spawn receipts in the parallel orchestrator checkpoint (optional `model_routing_receipts[]`, new orchestrator invariant) so the model passed on each `Agent(orchestrator)` spawn is auditable (research option b1).
2. Port `compute_complexity_floor` and `resolve_delegation_model` to TypeScript with a parity test, allowing the MCP validator to enforce floor and model equality (research option T-full).
3. Decide whether a band should be re-assessed when an item's plan is amended after kickoff.
4. Evaluate whether `parallel-planner` requires an explicit `pwsh` tool grant for `ModelRouting.psm1` and `BlastRadius.psm1`.
5. The epic-orchestrate skill carries the same unnamed-source spawn-model obligation (research Section 3.1); evaluate a matching named-source change on the epic surface.

## Links

- Issue: https://github.com/drmoisan/drm-copilot/issues/532
- Issue record: `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/issue.md`
- Research: `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/research/research.2026-09-29T19-50.md`
