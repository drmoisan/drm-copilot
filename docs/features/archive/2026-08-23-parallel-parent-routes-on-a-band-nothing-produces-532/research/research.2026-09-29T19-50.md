# Research: parallel-parent-routes-on-a-band-nothing-produces (Issue #532)

- **Issue:** #532
- **Work mode:** full-bug (severity medium)
- **Branch:** `bug/parallel-parent-routes-on-a-band-nothing-produces-532`
- **Research timestamp:** 2026-09-29T19-50
- **Authoritative scope source:** `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/issue.md` (no issue comments)

## 1. Baseline Verification

- The worktree branch ref `bug/parallel-parent-routes-on-a-band-nothing-produces-532` and `refs/remotes/origin/main` both resolve to `b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e` (verified by reading the two ref files under the repository `.git` directory). Every finding below was read from this tree.
- `spec.md` and `plan.2026-09-29T15-46.md` in the feature folder are unfilled templates seeded from `issue.md`; they contain no design decisions.
- **Result: the defect is fully present at `b7b4a2dc`. No partial fix has landed.** Each cited location is unchanged in substance; several line numbers have drifted (Section 2.6).

## 2. Current State (Research Question 1)

### 2.1 `.claude/skills/parallel-orchestrate/SKILL.md`

- `## Parallel-Mode Kickoff Parameter` (lines 239-278): spawn parameters are `isolation: "worktree"`, `run_in_background: true`, branch base `origin/main`, and "`model` equal to that item's model routing receipt's resolved model" (lines 261-263).
- `## Model Selection` (lines 280-305): lines 295-300 state that `parallel-orchestrator` "applies the same per-delegation resolution to that channel and passes `model` equal to the routing receipt's `model` on the spawn call. It MUST NOT omit `model` ... and MUST NOT hard-code `model=opus`".
- Neither passage names where the band or the receipt comes from. The skill never references the planner checkpoint (`grep planner` returns only cohort/manifest-authorship references at lines 49, 71, 91, 96, 188, 220, 267, 537, 817-818, 1099).
- `.claude/agents/parallel-orchestrator.md` lines 173-174 repeat the obligation: "`model` — bound to that item's model routing receipt, resolved per the skill's `## Model Selection` section."
- What the parent actually reads: the run manifest (`docs/features/parallel/<slug>/parallel.md`, SKILL lines 60-86) and, through `/parallel-run`, the committed kickoff artifact. The manifest schema (M6) carries no band. The kickoff artifact's `## Item Summary` table does carry a `complexity` column (Section 2.2).

### 2.2 `.claude/skills/parallel-plan/SKILL.md`

- No `## Complexity Assessment` section and no band-derivation procedure anywhere in the file (verified by reading the full 621-line file).
- `## Checkpoint Persistence` line 451-454: per-item fields include `complexity_band` and `model_routing_receipt`.
- Line 137-138: preparation children are collected with "the model-routing receipt with `logical_agent: "orchestrator"`". `logical_agent` is Codex receipt vocabulary (Section 3.3); the Claude receipt uses `agent`.
- Lines 456-458: "Deliberately absent: any `epic_worthiness` analogue ..."
- Readiness contract lines 460-465 list P6-P9 only; no band or receipt condition.
- Kickoff template lines 529-533 and structural requirements lines 552-554: `## Item Summary` headers `issue_num | feature_folder | cohort | complexity | branch | plan-path`, with `complexity` one of `C1`-`C4`. This is enforced by `scripts/dev_tools/parallel_kickoff_contract.py` lines 255-278. No validator cross-checks this column against the checkpoint's `complexity_band`.
- Lines 316-317 (Cohort Seeding): the scheduling entry point `Get-BlastRadiusConflictEdge` consumes each item's "complexity band" (issue #722 integration-cost rule). The band therefore already feeds scheduling, still without a derivation procedure.
- `.claude/agents/parallel-planner.md` lines 116-120 list the same per-item fields; lines 122-140 (Completion Requirements) contain no band condition.

Observed practice: all seven committed kickoff artifacts under `docs/features/parallel/*/parallel-kickoff.md` carry `C1`-`C4` values in the `complexity` column. Planners have been emitting a band by judgment, with no documented procedure, no recorded rationale, and no validator linkage to the checkpoint or to any routing receipt.

### 2.3 `scripts/dev_tools/validate_parallel_planner_state.py` (450 lines)

- `REQUIRED_ITEM_KEYS` lines 79-84: `issue_num feature_folder kind state blast_radius preparation_status research_path plan_path preflight_status`. Neither `complexity_band` nor `model_routing_receipt` is present.
- `VALID_COMPLEXITY_BANDS` line 88 is a local tuple `("C1","C2","C3","C4")`, not imported from `compute_complexity_floor.BAND_ORDER`.
- `_validate_item_contract` lines 237-245: presence-gated enum check with the comment "The band is optional: absence is the backward-compatible shape".
- `_validate_ready_item` lines 300-351 (P7): preparation status, preflight status, research/plan paths, `blast_radius.source`. Nothing about band or receipt.
- The module never references `model_routing_receipt`, `resolve_delegation_model`, `compute_complexity_floor`, or `validate_codex_model_routing_receipts`.

### 2.4 `scripts/dev_tools/validate_parallel_orchestrator_state.py` and helpers

- A content search for `complexity_band|model_routing` across `scripts/dev_tools` returns 17 files; none of `validate_parallel_orchestrator_state.py`, `_parallel_state_common.py`, `_parallel_state_structures.py`, or `_parallel_state_records.py` is among them.
- The orchestrator validator imposes no item-key allowlist (no `ALLOWED`/unknown-key logic in `_parallel_state_*.py`), so extra item fields are tolerated.
- `scripts/dev_tools/_parallel_drift_scheduling.py` line 47 (`ITEM_BAND_FIELD = "complexity_band"`) and lines 76-95 read an optional band from the orchestrator checkpoint's `items[]` for drift re-scheduling, defaulting when absent. This is the only consumer of a band on the parallel orchestrator checkpoint, and it is a scheduling input, not a routing input.

### 2.5 `.claude/rules/parallel-orchestration.md`

- Invariant 19 (line 80): receipt arrays are `delegation_receipts`, `skill_receipts`, `mcp_call_receipts` only.
- P3 (line 96): "`complexity_band`, when present, must be in `{C1, C2, C3, C4}`."
- P7 (line 104) and the Enforcement section (lines 616-621) carry no routing invariant. Line 620 records that the TypeScript parity port "reproduces the same invariants".
- Line 459-460 (drift behaviour) references "the items' complexity bands from the checkpoint (`default_band` when absent)".

### 2.6 Citation drift relative to the issue (2026-08-23)

| Issue citation | Current location at `b7b4a2dc` |
| --- | --- |
| `parallel-orchestrate/SKILL.md` 292-299 | 295-300 (plus 261-263) |
| `parallel-plan/SKILL.md` 412 (checkpoint field list) | 451 |
| `parallel-plan/SKILL.md` 414 (`model_routing_receipt`) | 454 |
| `parallel-plan/SKILL.md` 493, 515 ("parallel-status.md column") | 531 and 553-554; these are the kickoff `## Item Summary` table, not `parallel-status.md` |
| `parallel-plan/SKILL.md` 418-420 (worthiness omission) | 456-458 |
| `validate_parallel_planner_state.py` 79-84 | 79-84 (unchanged) |
| `validate_parallel_planner_state.py` 237-243 | 237-245 |
| `validate_epic_planner_state.py` 52, 155, 260 | 52, 155, 260 (unchanged) |
| `epic-plan/SKILL.md` 69-75 | 73-79 |

## 3. Epic-Surface Reference and Reusable Helpers (Research Question 2)

### 3.1 `.claude/skills/epic-plan/SKILL.md` `## Complexity Assessment` (lines 73-79), verbatim

> Assess each child feature's complexity band (`C1`-`C4`) using the `model_policy` scale and signals in `config/orchestration-routing.json`, and record the band with a short rationale in the planning checkpoint's `features[]` entries and in the epic narrative. The bands serve two purposes: they feed the epic-worthiness rationale, and they give each child orchestrator's own model-selection step a reviewed starting assessment.

The epic text does not mention the parent's own spawn model; the epic-orchestrate skill (lines 166-171) carries the same unnamed-source "passes `model` equal to the routing receipt's `model`" obligation as the parallel surface.

### 3.2 `scripts/dev_tools/validate_epic_planner_state.py`

- Line 52: `complexity_band` in `REQUIRED_FEATURE_KEYS` (unconditional presence).
- Line 155-156: enum check against `BAND_ORDER` imported from `compute_complexity_floor`.
- Lines 241-269 (inside `_validate_ready_features`, i.e. only under `require_ready_for_execution`): calls `validate_codex_model_routing_receipts([model_receipt])` and rewrites the prefix `"Checkpoint codex_model_routing_receipts[0]"` to `f"{prefix}.model_routing_receipt"`; requires `logical_agent == "orchestrator"`; line 260 requires `model_routing_receipt.complexity_band == feature.complexity_band`; requires `execution_context == "epic_preparation_child"`.
- No floor check on the epic planner: there is no per-feature assessment object, and `compute_complexity_floor` is not called.

### 3.3 Two receipt families exist; only one fits the parallel spawn

| Family | Shape | Validator | Resolver | `model` values |
| --- | --- | --- | --- | --- |
| Codex deployment receipt | `logical_agent, deployment_agent, phase, complexity_band, execution_context, orchestration_complexity_ceiling, c3_overlay_applied, c3_overlay_reason, model, model_reasoning_effort` | `validate_codex_model_routing_receipts` in `scripts/dev_tools/_orchestrator_state_codex_model_routing.py` | `resolve_codex_deployment` in `scripts/dev_tools/resolve_codex_deployment.py` | `gpt-5.6-luna`, `gpt-5.6-terra`, `gpt-5.6-sol` |
| Claude delegation receipt | `agent, phase, complexity_band, fable_policy, table_model, clamped_from, model` (`.claude/rules/orchestrator-state.md` line 83) | `_validate_model_routing_receipts` in `scripts/dev_tools/_orchestrator_state_model_routing.py` | `resolve_delegation_model` in `scripts/dev_tools/resolve_delegation_model.py` | `haiku`, `sonnet`, `opus`, `fable` |

Findings that decide which family the parallel fix reuses:

1. The parallel surface is Claude-only. No `.github/`, `.codex/`, or `.agents/` copy of any parallel skill, agent, or rule exists (glob over those roots returns nothing), and `resolve_codex_deployment.VALID_EXECUTION_CONTEXTS` (lines 24-26) is `{standalone, epic_preparation_child, epic_execution_child}` with no parallel value.
2. The Claude `Agent` tool `model` parameter takes a Claude tier. A Codex receipt's `model` (`gpt-5.6-*`) cannot be passed to `Agent(orchestrator)`, so "model equal to the routing receipt's model" is only satisfiable with a Claude receipt.
3. `.claude/rules/orchestrator-state.md` lines 111-113 (issue #524) record that the epic per-feature Codex receipt has exactly one production writer, `.codex/scripts/launch-epic-child-wave.ps1`, on the Codex runtime. Copying the epic cross-check literally would reproduce a Codex-only requirement on a Claude-only surface.

**Conclusion:** the parallel fix reuses the epic *pattern* (required band, per-item receipt, `agent == "orchestrator"`, band-matches-receipt cross-check, ready-gate scoping of the receipt) but the *Claude* validators, not `validate_codex_model_routing_receipts`.

### 3.4 Reusable Python helpers (reuse, do not reimplement)

- `scripts/dev_tools/_orchestrator_state_complexity.py`: `_validate_complexity_assessments(value)` (exported via `__all__`). Per entry: band enum; `signals_present` is a list of strings; `floor == compute_complexity_floor(signals_present)`; `band >= floor`; non-empty `rationale`. Error prefix `"Checkpoint complexity_assessments #<i>"`. Calling it with a one-element list and rewriting the prefix is the same technique the epic validator uses for Codex receipts.
- `scripts/dev_tools/_orchestrator_state_model_routing.py`: `_validate_model_routing_receipts(value)` (exported via `__all__`). Per entry: band enum; `model == resolve_delegation_model(agent, complexity_band, fable_policy)["model"]`; disabled-mode clamp invariants. Error prefix `"Checkpoint model_routing_receipts #<i>"`. It does not validate `fable_policy` membership or `agent`; those checks belong in the caller.
- `scripts/dev_tools/compute_complexity_floor.py`: `BAND_ORDER` (replaces the local `VALID_COMPLEXITY_BANDS` literal if desired; the tuple values are identical).
- `scripts/dev_tools/resolve_delegation_model.py`: `resolve_delegation_model(agent, band, fable_policy)`. For `agent == "orchestrator"` (not in `PREFERRED_OVERLAY_AGENTS`), results are: C1 `haiku`, C2 `sonnet`, C3 `opus`, C4 `fable` under `available`/`preferred`, C4 `opus` (clamped) under `disabled`.

Consequence for the impact statement in the issue: for the parent spawn, `fable_policy` only changes the C4 cell. The practical effect of the current omission is that C1 and C2 items run on `opus` instead of `haiku`/`sonnet` under every policy, and C4 items run on `opus` instead of `fable` under `available`/`preferred`.

### 3.5 Destination-runtime equivalents

- `.claude/lib/model-routing/ModelRouting.psm1` exports `Get-ComplexityFloor` (line 90) and `Resolve-DelegationModel` (line 148), documented as faithful ports. These are what a planner or parent without a Python interpreter uses to compute the floor and the resolved model.
- Observation (not in scope to fix): `.claude/agents/parallel-planner.md` `tools:` grants `Bash(git *)`, `Bash(gh *)`, `Bash(poetry run *)`, and four bash entry points, but no `pwsh` grant, although the skill already instructs `Import-Module` of `BlastRadius.psm1` under `pwsh`. Resolving the band through `ModelRouting.psm1` inherits whatever route the planner already uses for the blast-radius facade.

## 4. Validation Entry Points (Research Question 3)

- **Python CLI:** `scripts/dev_tools/validate_orchestration_artifacts.py` registers `parallel-planner-state` with `--require-ready-for-execution` (`.claude/rules/parallel-orchestration.md` line 619). No change is needed there; it calls `validate_parallel_planner_state_text`.
- **MCP (TypeScript) — the runtime-active path.** The planner is instructed to validate through `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "parallel-planner-state"` (`parallel-plan/SKILL.md` lines 479-480; `parallel-planner.md` lines 133-135). That tool dispatches in-process to `validateParallelPlannerStateText` in `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` (454 lines) via `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` lines 346-353, forwarding `requireReadyForExecution` (`extensions/drm-copilot/src/mcp-tool-inputs.ts` lines 464-480; parameter descriptions in `extensions/drm-copilot/src/mcp-tool-definitions.ts` line 450-453 and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` lines 395-398). A fix to the Python validator alone would not change what the planner's own gate enforces.
- **TypeScript has no port of the Claude routing formulas.** A search of `extensions/drm-copilot/src` for `table_model|clamped_from|fable_disabled` and for `signals_present|ComplexityFloor` returns no files. The TypeScript side has only `resolveCodexDeployment`/`validateCodexModelRoutingReceipts` (`orchestrator-state-codex-model-routing.ts` lines 209, 385) and an existence-only check for Claude receipts (`orchestrator-state-model-routing-existence.ts`). `.claude/rules/orchestrator-state.md` line 107 documents that precedent: "The MCP TypeScript surface performs the existence check only ...; the Python validator remains authoritative for per-receipt correctness."
- **Hooks and bash libraries:** no parallel hook and no `.claude/lib/bash/*` script reads `complexity_band` or `model_routing_receipt` (content search over `.claude` returns only skills, rules, agents, the standard orchestrator-state PowerShell modules, `enforce-model-routing-receipt.ps1`, and `validate-orchestrator-output.ps1`). `validate-parallel-manifest.sh` validates the manifest, which carries no band. `enforce-model-routing-receipt.ps1` lines 26-28 and 231-232 deliberately exclude `orchestrator` as a gated `subagent_type`, so no PreToolUse hook gates an `Agent(orchestrator)` spawn's model.

## 5. Mirror Inventory (Research Question 4)

Only one mirror family exists for the parallel surface: the bundled Claude payload under `extensions/drm-copilot/resources/claude-customizations/`. There are no `.github/`, `.codex/`, or `.agents/` mirrors of any file the fix touches. Python modules and TypeScript sources are not mirrored.

| Source file | Bundled mirror |
| --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` |
| `.claude/skills/parallel-add/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` |
| `.claude/agents/parallel-planner.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` |
| `.claude/agents/parallel-orchestrator.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` |
| `.claude/rules/parallel-orchestration.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` |

Parity tests that pin these mirrors:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 118-143) requires every non-memory `.claude` file to exist in the bundle with identical text.
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` pins text fragments of `parallel-plan/SKILL.md` and `parallel-planner.md`, including `test_skill_contains_no_worthiness_gate` (lines 391-402: requires the phrase "worthiness verdict" and forbids `## Epic Worthiness` and `NON_EPIC_RECOMMENDED`) and content guards on `epic-plan/SKILL.md` and `epic-planner.md` (lines 37-63). A new `## Complexity Assessment` section does not violate any of these; the fix must not edit `epic-plan/SKILL.md` or `epic-planner.md` fragments listed there.

## 6. Existing Tests and Fixtures (Research Question 5)

### 6.1 Python

- `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` (500 lines, at the policy cap). Builders `build_item` (lines 42-55) and `build_valid_planner_state` (lines 58-84) carry no band or receipt. `test_optional_keys_are_absent_from_the_builder_and_yield_no_errors` (lines 171-178) asserts `"complexity_band" not in item_at(state, 0)`. `test_valid_checkpoint_yields_no_errors[True]` (lines 121-125) runs the builder through the ready gate.
- Files importing `build_valid_planner_state` from that module and validating with `ready=True`: `tests/scripts/dev_tools/test_validate_parallel_planner_state_bounds.py` (line 65), `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` (lines 65, 82), `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` (line 367-379, `main` returns 0 for ready).
- No planner-state test reads a file; checkpoints are built as dicts and serialized.

### 6.2 TypeScript

- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts` (439 lines): own `buildItem`/`buildValidPlannerState` (lines 39-79); line 137-141 asserts `complexity_band` is absent from the builder; line 89-92 runs the builder with the gate on.
- `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`: its own `buildPlannerItem`/`buildValidPlannerState` (lines 67-109) validated with `ready = true` at lines 143 and 169.
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts`, `extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts`, `extensions/drm-copilot/test/mcp-tool-inputs-parallel-validation.test.ts`, `extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts`: use `[]`, `{}`, or mocked dispatch; unaffected by new item-level conditions.

### 6.3 Fixtures

- No committed `parallel-planner-state*.json` exists anywhere (glob returns only the TS source and test file names), and no committed `*.json` carries a `"preparation_status"` key. Planner checkpoints live under the gitignored `artifacts/orchestration/`. No fixture backfill is required.
- `docs/features/parallel/*/parallel.md` manifests are unaffected (M6 has no band). The committed `parallel-kickoff.md` files already carry valid `complexity` values.

### 6.4 Breakage matrix

| Design choice | Tests that break without builder updates |
| --- | --- |
| Band/assessment/receipt required only under `require_ready_for_execution` (recommended) | Every `ready=True` success assertion listed in 6.1 and 6.2; the two "complexity_band absent from builder" assertions once builders gain the field |
| Band/receipt added to unconditional `REQUIRED_ITEM_KEYS` (issue text) | All of the above plus every gate-off success assertion (`test_valid_checkpoint_yields_no_errors[False]`, `test_readiness_gate_contributes_no_errors_when_disabled`, bounds and tolerated-edge gate-off cases, and TS equivalents) |

## 7. Options and Recommendation (Research Question 6)

### 7.1 Where the requirement lives (option a)

- **a1 — Unconditional required keys (issue's literal proposal).** Adds `complexity_band` and `model_routing_receipt` to `REQUIRED_ITEM_KEYS`. Limitation: the planner writes the checkpoint "after every completed step", beginning at intake, when no plan exists and no band can be assessed; the current comment on `REQUIRED_ITEM_KEYS` ("The preparation fields have no unconditional value constraint; the readiness gate pins them") and the presence-gated enum would force either a null placeholder (which the enum check rejects) or a fabricated early band.
- **a2 — Ready-gate requirement (recommended).** Keep the unconditional P3 enum check presence-gated; add a new ready-gate invariant (P10) requiring, per item, a valid `complexity_band`, a `complexity_assessment` object, and a `model_routing_receipt` object with the cross-checks. This matches how the file already scopes preparation fields, matches the epic planner (receipt validated only under the ready gate, lines 241-269), and matches when the value is consumed: the parent spawns only after the planner reports `PARALLEL_EXECUTION_READY`, and the planner cannot report completion until the ready gate passes (`parallel-planner.md` Completion Requirement 4).

### 7.2 Receipt family

Claude delegation receipt, validated by reusing `_validate_model_routing_receipts`; per-item assessment validated by reusing `_validate_complexity_assessments`. Rationale in Section 3.3.

### 7.3 Parent-side routing state (option b)

- **b1 — Parent records a spawn receipt in the parallel orchestrator checkpoint** (optional presence-gated `model_routing_receipts[]` reusing `_validate_model_routing_receipts`, new invariant 22). Gives an auditable record of the model actually passed. Cost: Python validator, TypeScript core (shape-only, since TypeScript has no resolver), rule invariant text, and tests on a second surface. It does not by itself make the band exist.
- **b2 — Name the source in the skill text only (recommended for this fix; b1 as follow-up).** The root cause recorded in the issue is that the obligation "is currently stated with no named source". `parallel-orchestrate/SKILL.md` and `parallel-orchestrator.md` should state that the parent reads each item's `complexity_band` from the planner checkpoint (re-derivable from the durable kickoff artifact's `## Item Summary` `complexity` column, which the planner writes from the same field, consistent with the cache doctrine at `parallel-plan/SKILL.md` lines 474-477), resolves `model` with `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>`, and passes it. When the run's `fable_policy` equals the planner receipt's `fable_policy`, the result equals the planner receipt's `model` by construction; when the operator runs with a different policy, re-resolution at spawn time is the correct behaviour and the planner receipt remains planning-time evidence.

### 7.4 Backward compatibility (option c)

- No committed planner checkpoint exists, and planner checkpoints are not re-validated after kickoff (the parent does not read them through a validator). The new ready-gate invariant therefore affects only runs planned after the fix.
- In-flight runs: every committed kickoff artifact already carries a `C1`-`C4` band per item, so a parent following the revised skill text has a band source for existing runs via the kickoff table.
- The unconditional P3 behaviour is unchanged, so mid-preparation checkpoints written by an older planner continue to validate with the gate off.

### 7.5 `/parallel-add` and plan amendment (issue's unchecked items)

- `/parallel-add` step 2 runs its own preparation child and step 3 already passes an "optional complexity `band`" to `Get-BlastRadiusConflictEdge` (`parallel-add/SKILL.md` lines 53-70), yet no step assesses it. Recommended: add one sentence to step 2 requiring the same assessment after preflight clearance and recording `complexity_band` on the admitted orchestrator-checkpoint item (the field `_parallel_drift_scheduling.py` already reads), and amend the Constraints sentence (line 166, "No field ... is added to ... `items[]`") to name `complexity_band` as an existing scheduling field rather than a new one. Skill text only; no validator change.
- Plan amendment: assess the band after the item's plan is approved, preflight-clear, and radius V1/V2-clear, so a V1/V2 re-plan (`parallel-plan/SKILL.md` lines 265-270) naturally precedes the assessment. Re-assessment of plans amended after kickoff is out of scope; note that staleness is not guaranteed to fail toward `opus` (a band assessed too low resolves to `haiku`/`sonnet`).

### 7.6 TypeScript parity scope

- **T-structural (recommended):** the TypeScript helper enforces every check that needs no resolver: band enum, assessment/receipt object shape, `signals_present` list-of-strings, `band >= floor` ordering, non-empty `rationale`, `agent == "orchestrator"`, `fable_policy` in the three-value enum, and both band cross-checks. Python additionally enforces `floor == compute_complexity_floor(...)`, `model == resolve_delegation_model(...)`, and the disabled clamp. This follows the documented precedent at `.claude/rules/orchestrator-state.md` line 107 and requires amending `.claude/rules/parallel-orchestration.md` line 620 to record the scoped divergence.
- **T-full (rejected for this fix, candidate follow-up):** port `resolve_delegation_model` and `compute_complexity_floor` to TypeScript. This would enforce the mechanically checkable half at the destination runtime, but it creates a third implementation of each formula (Python, PowerShell, TypeScript) requiring its own parity test, which exceeds a minimal fix.

### 7.7 Recommendation

Adopt a2 + Claude receipt family + b2 + the `/parallel-add` text change + T-structural.

Rejected alternatives (brief): a1 (breaks mid-preparation checkpoints and every gate-off test for no consumer benefit); reusing `validate_codex_model_routing_receipts` (Codex `model` values cannot feed `Agent(orchestrator)`, no parallel `execution_context`, Codex-only producer per #524); b1 in this fix (adds a second validated surface without supplying the missing band; better as a follow-up); T-full (third formula implementation).

## 8. Behavior Semantics

Assessment point: after an item is `prepared` (preflight `PREFLIGHT: ALL CLEAR`, declared radius V1/V2-clear) and before cohort seeding, because seeding consumes the band.

Per-item record under the recommended design:

- `complexity_band`: one of `C1`-`C4`.
- `complexity_assessment`: `{ band, floor, signals_present[], rationale, assessed_at }` (the `.claude/rules/orchestrator-state.md` line 65 shape, singular per item; `phase` is not needed per item).
- `model_routing_receipt`: `{ agent: "orchestrator", phase, complexity_band, fable_policy, table_model, clamped_from, model }` resolved with `Resolve-DelegationModel`/`resolve_delegation_model`.
- The kickoff `## Item Summary` `complexity` cell equals `complexity_band`.

Ready-gate P10 success requires all of the following per item; each violation is one error, ending with a period and prefixed with the item context (`Parallel planner checkpoint items[<i>]`):

1. `complexity_band` in `C1`-`C4` (reuse `enum_error`; an absent band reports `found: None.`).
2. `complexity_assessment` is an object; its entry errors come from `_validate_complexity_assessments([value])` with the prefix `Checkpoint complexity_assessments #0` rewritten to `<item context> complexity_assessment`.
3. `complexity_assessment.band == complexity_band`.
4. `model_routing_receipt` is an object; its entry errors come from `_validate_model_routing_receipts([value])` with the prefix `Checkpoint model_routing_receipts #0` rewritten to `<item context> model_routing_receipt`.
5. `model_routing_receipt.agent == "orchestrator"`.
6. `model_routing_receipt.complexity_band == complexity_band`.
7. `model_routing_receipt.fable_policy` in `{disabled, available, preferred}` (the reused helper does not check this, and an arbitrary string silently resolves as `available`).

Ordering: P10 errors follow the existing P7 errors for the same item, preserving the existing P7 order. Gate off: P10 contributes zero errors. Edge cases: non-object `items` entries are skipped (existing `_item_records` behaviour); a band that fails the enum suppresses the two band-match errors only if the implementation chooses to, which the spec should fix explicitly (recommended: always report both match errors, mirroring epic line 260, which compares regardless of validity).

## 9. Requirements Mapping — Proposed File Changes

### 9.1 Production (Python and TypeScript)

- `scripts/dev_tools/_parallel_planner_state_routing.py` (new; keeps `validate_parallel_planner_state.py` under 500 lines): the P10 per-item helper reusing `_validate_complexity_assessments`, `_validate_model_routing_receipts`, and `BAND_ORDER`.
- `scripts/dev_tools/validate_parallel_planner_state.py`: import the helper and call it from the ready gate; update the `_validate_item_contract` comment and module docstring to state that absence is permitted only outside the ready gate.
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (new): structural subset per Section 7.6 with byte-identical strings for the shared checks.
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`: call the new helper from `validateReadyGate`.

### 9.2 Runtime text and mirrors

- `.claude/skills/parallel-plan/SKILL.md` and its bundled mirror: add `## Complexity Assessment` (procedure, assessment point, record shape, `Get-ComplexityFloor`/`Resolve-DelegationModel` usage, kickoff column equality); correct line 138 `logical_agent` to `agent`; extend the Readiness contract with P10; state that the band is a routing input distinct from the deliberately absent worthiness verdict.
- `.claude/agents/parallel-planner.md` and mirror: add `complexity_assessment` to the per-item field list and a band/receipt clause to Completion Requirements.
- `.claude/skills/parallel-orchestrate/SKILL.md` and mirror: name the band source and the spawn-time resolution in `## Parallel-Mode Kickoff Parameter` and `## Model Selection` (Section 7.3 b2).
- `.claude/agents/parallel-orchestrator.md` and mirror: same named source in `## Delegation Model` lines 173-174.
- `.claude/skills/parallel-add/SKILL.md` and mirror: Section 7.5 text.
- `.claude/rules/parallel-orchestration.md` and mirror: P3 wording (band optional outside the gate), new P10, the ready-gate sentence at line 110, and the Enforcement bullets at lines 617 and 620 (helper module and TypeScript scoped divergence).

### 9.3 Tests

- `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` (new): P10 cases.
- `tests/scripts/dev_tools/test_validate_parallel_planner_state.py`: builders gain the three fields; rewrite lines 171-178 to delete the fields and assert gate-off validity. The file is at 500 lines, so the builders should move to a non-test support module (for example `tests/scripts/dev_tools/parallel_planner_state_builders.py`) with a re-export from the existing module so the three importing files keep working; the planner should confirm the re-export satisfies the importers.
- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` (new): TypeScript P10 structural cases.
- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts`: builder update and the lines 137-141 rewrite.
- `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`: builder update (lines 67-79).
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`: optional positive fragment test for `## Complexity Assessment`; existing assertions remain satisfied.

## 10. Testing Implications

- Regression-first: with the builders updated to carry the three fields, a P10 test that removes each field (band, assessment, receipt) under `ready=True` must fail against the current validator (current validator returns `[]`) and pass after the fix. This is the issue's "shown to fail against a checkpoint that omits the keys" requirement.
- Floor integration case (issue): an assessment whose `floor` disagrees with `compute_complexity_floor(signals_present)` (for example `signals_present: ["concurrency_or_ordering"]`, `floor: "C1"`) must yield the rewritten floor error under the Python validator. The TypeScript suite asserts the documented non-enforcement of this case, so the divergence is pinned rather than accidental.
- Model mismatch case: receipt `{agent: orchestrator, complexity_band: C2, fable_policy: available, model: opus}` must yield the rewritten resolver error in Python.
- Cross-check cases: band mismatch between item and assessment, item and receipt; `agent` not `orchestrator`; out-of-enum `fable_policy`; non-object assessment/receipt.
- Gate-off neutrality: an item with none of the three fields validates with the gate off in both runtimes.
- Mutation-sensitive assertions: assert exact error strings, not counts, for the rewritten prefixes, so a prefix-rewrite regression is caught.
- Coverage: new modules must meet line >= 85% and branch >= 75% (Python, TypeScript). Tier per `quality-tiers.yml` for `scripts/dev_tools` and `extensions/drm-copilot` applies unchanged; the planner should confirm whether property tests are required for the new pure helper under that tier.
- Toolchain: Python (Black, Ruff, Pyright, pytest) and TypeScript (Prettier, ESLint, tsc, Jest) loops; the bundle-parity pytest after mirroring.

## 11. Numeric Derivation Evidence

No numeric count, enumeration size, or population is proposed for any `spec.md` acceptance criterion by this research. Counts appearing in findings (for example the number of committed kickoff artifacts) are informational observations and must not be carried into an acceptance criterion without a complete derivation record.

## 12. Automation Feasibility

The fix is fully automatable. It consists of Python and TypeScript validator changes, Markdown skill/agent/rule text changes, byte-identical mirror copies, and unit tests that build checkpoints in memory. No human interaction, credential, external service, or manual verification step is required. No GitHub API or Claude runtime spawn is needed to verify the behaviour; the parent-side skill text change is verified by contract-text tests and review.

## 13. Open Decisions for the Spec Author

1. Confirm a2 (ready-gate scope) over the issue's literal a1.
2. Confirm the Claude receipt family over the epic's Codex receipt family.
3. Confirm b2 now and b1 (parent spawn receipts in the orchestrator checkpoint) as a follow-up issue.
4. Confirm T-structural now and T-full (TypeScript ports of the two formulas) as a follow-up issue.
5. Confirm inclusion of the `/parallel-add` text change.
