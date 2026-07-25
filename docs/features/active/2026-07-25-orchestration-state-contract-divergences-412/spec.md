# 2026-07-25-orchestration-state-contract-divergences (Spec)

- **Issue:** #412
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/412
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25
- **Status:** Ready
- **Version:** 1.0
- **Work Mode:** full-bug (this `spec.md` is the sole acceptance-criteria source; no `user-story.md`)
- **Authoritative research:** `research/2026-07-25T20-45-orchestration-state-contract-divergences-research.md`

## Context
Two documented-contract-versus-implementation divergences exist in the orchestration state machine. First, the `step9_status` values documented in `.claude/skills/orchestrate/SKILL.md` (`passed`, `failed_remediation_required`, `blocked_ci_loop_limit`) are all rejected by the validator's shared step-status enumeration, so a CI failure or a CI-loop-limit halt has no valid representation in the checkpoint. Second, the documented complexity-floor semantics ("each present `[floor]` signal contributes a candidate band of `C3`") do not match the reference implementations, which return `C3` for any non-empty signal list regardless of the signal's `floor` flag.

An adjacent finding of the same defect class in the same production files is explicitly in scope: `.claude/skills/orchestrate/SKILL.md` line 200 instructs recording `step6_status: "blocked_remediation_loop_limit"` on the third remediation pass. That value is also outside `VALID_STEP_STATUS` and is equally unpersistable.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `poetry run python -m scripts.dev_tools.validate_orchestrator_state`; direct invocation of `scripts/dev_tools/compute_complexity_floor.py` and `.claude/lib/model-routing/ModelRouting.psm1` (`Get-ComplexityFloor`)
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json`, `config/orchestration-routing.json`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Write a checkpoint containing `step9_status: "passed"` (the value documented in `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Schema — CI Gate Fields`) and run the orchestrator-state validator.
2. Observe `Checkpoint has invalid step9_status: passed`. Repeat with `failed_remediation_required` and `blocked_ci_loop_limit`; all three documented non-`pending` values are rejected by `VALID_STEP_STATUS`.
3. Call `compute_complexity_floor(["docs_or_comment_only"])` (a `"floor": false` signal in `config/orchestration-routing.json`) and observe `C3` rather than `C1`. Repeat with `Get-ComplexityFloor -SignalsPresent docs_or_comment_only` in `.claude/lib/model-routing/ModelRouting.psm1` and observe the same result.

Expected:
The documented S9 status vocabulary and the documented complexity-floor semantics are each consistent with exactly one authoritative side, and both the validator and the reference implementations agree with the documented contract.

Actual:
`Checkpoint has invalid step9_status: passed` is produced for a checkpoint written to the documented S9 contract. `VALID_STEP_STATUS = {not-applicable, pending, delegated, verified, blocked, not_started, in_progress, completed}` is applied uniformly to `step5_status`..`step10_status`, so no documented S9 failure state is representable and the fail-closed CI halt path cannot be persisted. Separately, both complexity-floor reference implementations return `C3` for every non-empty signal list, so the `"floor": false` flag and the unknown-signal case are dead configuration. Runtime verification recorded in the research confirms both implementations return `C1` for `[]` and `C3` for each of `['single_file_localized_edit']`, `['docs_or_comment_only']`, and `['not_a_real_signal']`.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `Checkpoint has invalid step9_status: passed`


## Authoritative-Side Rulings

### Divergence 1: the documented contract in `.claude/skills/orchestrate/SKILL.md` is authoritative; `VALID_STEP_STATUS` is the lagging implementation

Decision justification (research RQ1.1):

1. **Decisive evidence — a shipped enforcement hook already implements the documented vocabulary.** `.claude/hooks/enforce-epic-merge-gate.ps1` line 148 (`Test-ChildCheckpointAllowsEpicMerge`) requires `step9_status -eq 'passed'`, a value the validator rejects. Two shipped enforcement components are therefore deadlocked: the epic merge gate requires a value the checkpoint validator cannot accept. Only one side can be correct, and the hook plus its Pester suite (`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`) sit on the documented side.
2. The documented vocabulary is load-bearing for fail-closed behavior: the S9 failure states exist so a CI failure blocks DONE persistently. Collapsing them into the shared vocabulary loses the distinction between "blocked awaiting delegate" and "CI loop limit reached, halt permanently".
3. The documented vocabulary is mirrored across every documentation surface, while the narrow enumeration exists only in the three validator mirrors. Aligning the implementation is the smaller and semantically correct change.

### Divergence 2: the documented contract plus `config/orchestration-routing.json` are authoritative; both reference implementations diverge together

Decision justification (research RQ2.1):

1. **Decisive evidence — the config structure proves intent.** `config/orchestration-routing.json` deliberately encodes `"floor": false` on three signals in the same block that flags four others `"floor": true`. Under current implementation behavior those three flags never change any outcome — they are dead configuration.
2. If the implementation were authoritative, every phase that honestly records any signal would floor at `C3`, making the `complexity_to_model` cells `C1: haiku` and `C2: sonnet` unreachable for any signal-reporting assessment. The implementation collapses the documented four-band `complexity_to_model` economy (feature #286) to two bands; that cannot be the contract.
3. The originating spec and plan for feature #286 state the `[floor]`-only contribution rule explicitly. The two implementations agreeing with each other is not evidence of correctness: `ModelRouting.psm1` is a documented faithful port of `compute_complexity_floor` and inherited the defect by design.

## Scope & Non-Goals
- In scope:
  - Divergence 1: per-step-key additive extra-status vocabulary in the Python validator, its TypeScript mirror, and `OrchestratorState.psm1` (plus the resources byte mirror), including completion-gate and PR-creation-readiness closure.
  - Divergence 1 adjacent finding: `step6_status: "blocked_remediation_loop_limit"` (`.claude/skills/orchestrate/SKILL.md` line 200) is included in scope by explicit decision; the per-key mechanism covers it.
  - Divergence 2: floor-signal filtering in `compute_complexity_floor.py` and `ModelRouting.psm1` (plus the resources byte mirror), pinned to the config by static parity tests.
  - Test additions in the Python, Pester, and Jest suites listed in the File Surface section.
- Out of scope / non-goals:
  - `config/orchestration-routing.json` and its bundled mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` — unchanged.
  - `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, and all documentation mirrors — unchanged; documentation is the authoritative side for both divergences.
  - `.claude/hooks/validate-orchestrator-output.ps1` — **MUST NOT be modified.** A separate parallel orchestration owns that file. Verified: it contains no step-status or floor literals; all required behavior change flows through the Python validator and `OrchestratorState.psm1`, so this exclusion creates no follow-up dependency.
  - `.claude/hooks/enforce-epic-merge-gate.ps1` — unchanged; it already implements the authoritative vocabulary and serves as ruling evidence.
  - `scripts/dev_tools/_orchestrator_state_complexity.py` — unchanged; passing the full recorded list is correct once the formula filters internally.
  - Recorded follow-up, not in scope: optional extension of the `enforce-completion-consistency.ps1` completion-assertion detector to treat `step9_status == 'passed'` as a completion assertion, including its codex mirror, two resources mirrors, and Pester suite.
  - Recorded follow-up, not in scope: optional additive validator check that every `signals_present` element is a catalog member (typo detection), which would require a config read in `_orchestrator_state_complexity.py` and a new error-message class.
- Explicitly excluded systems, integrations, or datasets: none beyond the files listed above; no external services are involved.

## Root Cause Analysis
The S9 CI-gate vocabulary was documented in the skill without a corresponding extension of the validator's shared step-status set. The complexity-floor reference implementations were written to accept a pre-filtered floor-signal sequence, while the checkpoint records the full `signals_present[]` set that the validator then recomputes from; the caller-pre-filters docstring clause and the validator's recompute-over-the-full-array invariant cannot both hold. Affected implementations: `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`, `scripts/dev_tools/compute_complexity_floor.py`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `.claude/lib/model-routing/ModelRouting.psm1`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`.


## Proposed Fix

### Design summary (what changes where):

**Divergence 1 — per-step-key additive extra-status map.** Keep the shared `VALID_STEP_STATUS` set unchanged; add a per-key additive map (for example `STEP_SPECIFIC_EXTRA_STATUS`) such that a value is valid when it is in the shared set or in that key's extra set. Mirror the mechanism identically in the TypeScript port and the PowerShell module.

- `step9_status` gains: `passed`, `failed_remediation_required`, `blocked_ci_loop_limit`.
- `step6_status` gains: `blocked_remediation_loop_limit`.

Rejected alternatives (research RQ1.2): widening the shared set would validate values on step keys with no documented meaning and permanently weaken the checkpoint shape contract; re-vocabulary of the skill (`passed` → `completed`, failures → `blocked`) has a strictly larger change surface, destroys the failure-mode distinctions, and invalidates the epic-merge-gate contract.

**Divergence 1 completion-gate closure (mandatory in the same change).** The `--require-complete` gate currently rejects only `{pending, blocked}`. It must additionally reject `failed_remediation_required`, `blocked_ci_loop_limit`, and `blocked_remediation_loop_limit` (applied across all step keys, since the failure values are per-key-valid only), so DONE cannot be written on a recorded CI failure. `passed` must not block completion. `--require-pr-creation-ready` (steps 5–8) must additionally reject `blocked_remediation_loop_limit`; the S9 values are outside its key set. The TypeScript completion check must apply the same blocklist with byte-identical error strings. Requiring `step9_status == "passed"` exactly at completion is rejected: it would break the preparation-route `not-applicable` terminal contract and legacy `completed` checkpoints; the route-driven `ci_gate.conclusion == "success"` check already enforces the CI-green substance.

**Divergence 2 — hard-coded floor-signal name set pinned by static parity tests.** Hard-code the floor-signal name set in both reference implementations (`FLOOR_SIGNAL_NAMES: frozenset[str]` in `compute_complexity_floor.py`; `$script:FLOOR_SIGNAL_NAMES` in `ModelRouting.psm1`) and compute the floor from the intersection of `signals_present` with that set. Pin both embedded sets to the config's `"floor": true` entries via static parity tests (extended `tests/scripts/dev_tools/test_compute_complexity_floor.py`; extended `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`). This follows the embedded-constant-plus-parity-test pattern already used by `ModelRouting.psm1` for `BASE_COMPLEXITY_TO_MODEL`.

- Unknown signal names contribute no floor candidate (treated as non-floor). A raising formula is incompatible with the error-string-collector validator contract; treating unknowns as floor signals reproduces the defect being fixed. Residual typo risk is handled by the out-of-scope catalog-membership follow-up.
- Neither implementation may read a file at runtime. The PowerShell module is pushed down to consumer repositories that receive only the `.claude` tree, where `config/orchestration-routing.json` does not exist; both modules carry documented purity contracts. Rejected alternative: implementations reading the config at runtime (breaks the pushed-down runtime, adds I/O to pure reference formulas, contradicts two module contracts).
- Docstrings in `compute_complexity_floor.py` are updated to remove the caller-pre-filters clause.

### Boundaries and invariants to preserve:
- `VALID_STEP_STATUS` (shared set) is unchanged; per-key values are additive only.
- Invariant 3 of `.claude/rules/orchestrator-state.md` (`floor == compute_complexity_floor(signals_present)` over the full recorded array) is preserved without any grace/legacy-acceptance rule.
- `band >= floor` validation is unchanged; the floor never exceeds `C3` and is never `C4`.
- Fail-closed default preserved: an absent `step9_status` is treated as `pending`, which already blocks completion.
- Both floor implementations remain pure and deterministic (no file reads at runtime); `compute_complexity_floor.py` stays under 500 lines.
- Error-message strings in the TypeScript mirror remain byte-identical to the Python validator (documented header contract in `orchestrator-state-core.ts`).

### Dependencies or blocked work:
- Batch 1 (Python D1) must complete before Batch 5 (TypeScript D1): the TS port copies the final Python error strings verbatim.
- Each root `.claude/lib` module edit must land in the same batch as its resources byte mirror (enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`).
- `.claude/hooks/validate-orchestrator-output.ps1` is owned by a separate parallel orchestration and must not be touched; no dependency on that work exists.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

All paths repo-root-relative.

| File | Language | Prod/Test | Divergence |
|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | Python | Prod | D1 |
| `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` | Python | Prod | D1 (step6 value) |
| `scripts/dev_tools/compute_complexity_floor.py` | Python | Prod | D2 |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | PowerShell | Prod | D1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1` | PowerShell | Prod (byte mirror) | D1 |
| `.claude/lib/model-routing/ModelRouting.psm1` | PowerShell | Prod | D2 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1` | PowerShell | Prod (byte mirror) | D2 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` | TypeScript | Prod | D1 |
| `tests/scripts/dev_tools/test_validate_orchestrator_state.py` | Python | Test | D1 |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py` | Python | Test | D1 |
| `tests/scripts/dev_tools/test_compute_complexity_floor.py` | Python | Test | D2 |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` | Python | Test | D2 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | PowerShell | Test | D1 |
| `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` | PowerShell | Test | D2 |
| `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` | PowerShell | Test | D2 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts` | TypeScript | Test | D1 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts` | TypeScript | Test | D1 |

The two resources-mirror `.psm1` copies are byte copies required by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; they are counted as production PowerShell files. The MCP TypeScript surface fully mirrors step-status validation and must change in step for divergence 1; it does not mirror complexity-floor computation or `complexity_assessments` validation, so divergence 2 has zero TypeScript surface.

#### Batch decomposition (5 sequential batches per research RQ7):

Routing notes: the overall PowerShell scope of 4 prod files exceeds the 2-file direct-mode budget in `.claude/rules/powershell.md` and must route via `powershell-orchestrator`; TypeScript has `direct_mode_enabled: false` in `config/orchestration-routing.json` and routes to `typescript-engineer`.

1. **Batch 1 — Python, D1** (2 prod, 2 test): `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`; `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py`.
2. **Batch 2 — Python, D2** (1 prod, 2 test): `scripts/dev_tools/compute_complexity_floor.py`; `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py`.
3. **Batch 3 — PowerShell, D1** (2 prod, 1 test): `.claude/lib/orchestrator-state/OrchestratorState.psm1` plus its resources byte mirror; `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.
4. **Batch 4 — PowerShell, D2** (2 prod, 2 test): `.claude/lib/model-routing/ModelRouting.psm1` plus its resources byte mirror; `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`, `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`.
5. **Batch 5 — TypeScript, D1** (1 prod, 2 test; typescript-engineer): `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`; `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts`.

Ordering constraints: Batch 1 precedes Batch 5 (the TS mirror must copy the final Python error strings verbatim). Batches 2, 3, and 4 are mutually independent. Batch 3 and Batch 4 mirror copies must land in the same batch as their root edits (push-down parity test). Both divergences must be delivered; neither may be dropped.

#### Functions/classes/CLI commands impacted:
- `validate_orchestrator_state_text` and its step-status check plus `--require-complete` blocklist (`validate_orchestrator_state.py`).
- The PR-creation-readiness blocked-status set (`_orchestrator_state_pr_creation_readiness.py`).
- `compute_complexity_floor` (`compute_complexity_floor.py`).
- `$script:VALID_STEP_STATUS` application in `OrchestratorState.psm1`.
- `Get-ComplexityFloor` in `ModelRouting.psm1`.
- `validateOrchestratorStateText` step-status and completion checks (`orchestrator-state-core.ts`).

#### Data flow and validation changes:
- Plain validation: per-key extra statuses accepted on their owning keys only; all other behavior unchanged.
- Completion gate: blocklist extended by three failure values; `passed` never blocks.
- PR-creation-readiness gate: blocklist extended by `blocked_remediation_loop_limit` (step6 is in its key set).
- Floor computation: `floor = C3` if `signals_present ∩ FLOOR_SIGNAL_NAMES ≠ ∅`, else `C1`; unknown names contribute nothing; deterministic and order-independent. The validator continues to recompute over the full recorded array.

#### Error handling and logging updates:
- Rejection of a per-key extra value on a non-owning key uses the existing message form `Checkpoint has invalid <key>: <value>`.
- New completion-gate error strings must be byte-identical between Python and TypeScript.
- No logging changes; the validator remains a non-raising error-string collector.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Divergence 1 is purely widening in plain mode. Divergence 2 changes the floor formula; the accepted compatibility consequence and repair path are documented below. Rollback is a revert of the batches.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- S9 semantics (SKILL.md): `step9_status: "passed"` iff `ci_gate.conclusion == "success"` and head-SHA match; `failed_remediation_required` on poll timeout or failed required checks; `blocked_ci_loop_limit` on the third failed CI pass, halting without DONE. All three persist through the validator; the two failure values plus step6's loop-limit value block `--require-complete`.
- Floor semantics: `C3` when at least one recorded signal is in the floor set, else `C1`; never `C4`.

#### Required configuration keys and defaults:
- None added or changed. `config/orchestration-routing.json` is unchanged; its `"floor": true` entries are the parity-test source of truth for the embedded name sets.

#### Backward-compatibility expectations:

Divergence 2, concretely:
- **Stored assessments invalidated: zero.** Every `complexity_assessments` entry in the runtime checkpoint at `artifacts/orchestration/orchestrator-state.json` records only the floor-flagged signal `cross_module_contract_change`, a `"floor": true` signal, so each entry's recomputed floor is `C3` before and after the change and no stored entry's recomputed floor changes.
- **Committed JSON files carrying `complexity_assessments`: zero** (repo-wide search).
- **Test fixtures asserting the any-non-empty behavior: zero.** Existing Python and Pester floor tests derive inputs exclusively from `floor: true` catalog names and remain green; new cases are additive.
- **Decision: accept the break with no grace/legacy-acceptance rule.** A rule accepting `floor: C3` where the recompute yields `C1` would permanently weaken invariant 3 of `.claude/rules/orchestrator-state.md`, be indistinguishable from the bug it excuses, and add dead code once fleets roll forward.
- **Repair path:** a pre-change checkpoint whose assessment recorded only non-floor signals necessarily recorded `floor: "C3"` and will fail post-change with a floor-mismatch error naming the recomputed `C1`. It is repaired by the documented resume reconciliation in `.claude/skills/orchestrate/SKILL.md`, which recomputes the floor and rewrites the entry. The PR body must state this consequence and the repair step.

Divergence 1 is purely widening in plain mode: previously invalid values become valid; no currently valid value becomes invalid. The completion-gate extension newly rejects the three failure values, but no stored checkpoint carries them (they were unwritable before this fix).

#### Performance constraints (latency/throughput/memory):
- None material. Both changes are constant-time set membership checks over small in-memory sets.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): repository Poetry environment for Python; `pwsh` for Pester; extension workspace toolchain for TypeScript. The research's runtime evidence (recorded in the delegation input) is confirmed by static reading of the cited code.
- Constraints (budget, performance, compatibility): batch caps and routing per research RQ7 and `.claude/rules/powershell.md`; no file may exceed 500 lines; no runtime file reads in either floor implementation.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact
- User-facing or API changes: validator accepts the documented per-key statuses; completion and PR-creation-readiness gates gain blocklist entries; floor formula filters by the floor-signal set.
- Data or migration considerations: no migration. The only compatibility consequence is the divergence-2 repair path documented above.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag changes; `--require-complete` and `--require-pr-creation-ready` semantics are extended additively; config schema unchanged.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: step-status validation, complexity-floor computation, config-parity between Python and PowerShell implementations
- [x] Integration scenario to retest: full-lifecycle checkpoint validation under `--require-complete --require-model-routing`
- [x] Manual verification notes: research must first determine, per divergence, which side is authoritative, and must determine the backward-compatibility consequence of a floor-formula change for stored `complexity_assessments[]` entries

- Regression tests to add or update: per-key acceptance/rejection matrix for the extra statuses; completion blocklist for the three failure values; PR-creation-readiness rejection for step6; epic-merge-gate regression scenario (`epic_mode: true`, `step9_status: "passed"`, hook unchanged); non-floor/unknown/mixed floor cases; validator acceptance of `floor: C1` with non-floor-only signals.
- Unit tests (pytest) for the fixed behavior and boundaries: extended `test_validate_orchestrator_state.py`, `test_validate_orchestrator_state_pr_creation_readiness.py`, `test_compute_complexity_floor.py` (including the floor-set parity assertion against `load_routing_matrix()`), `test_validate_orchestrator_state_complexity.py`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): per-key values on non-owning keys rejected; unknown signal names contribute nothing; empty signal list yields `C1`; absent `step9_status` treated as `pending` (blocks completion).
- Error handling and logging verification: Jest cases assert TypeScript error strings byte-identical to Python; the validator remains a non-raising error-string collector.
- Coverage impact and targets for changed lines/modules: line >= 85%, branch >= 75% maintained on changed files.
- Toolchain commands to run (format → lint → type-check → test): full per-language toolchain for every batch; baseline fail-before commands run first (below).
- Manual validation steps (if required): none; no human-interaction requirement identified.

Baseline fail-before evidence (first execution task, per research Verification Method Disclosure):
- `poetry run python -c "from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor as f; print(f([]), f(['docs_or_comment_only']), f(['not_a_real_signal']))"` — expected pre-fix output `C1 C3 C3`.
- `pwsh -NoProfile -Command "Import-Module ./.claude/lib/model-routing/ModelRouting.psm1; Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only')"` — expected pre-fix output `C3`.
- A Python validator call on a minimal checkpoint carrying `step9_status: "passed"` — expected pre-fix error `Checkpoint has invalid step9_status: passed`.

No fixture repair is needed anywhere; existing tests pin rejection behavior with `invalid-status` fixtures and remain green. No temporary files; all fixtures in-memory per repository test policy.


## Acceptance Criteria

### Divergence 1 — step-status vocabulary

- [x] The Python validator (`scripts/dev_tools/validate_orchestrator_state.py`) accepts `step9_status` values `passed`, `failed_remediation_required`, and `blocked_ci_loop_limit` in plain validation mode.
- [x] The Python validator accepts `step6_status: "blocked_remediation_loop_limit"` in plain validation mode.
- [x] The Python validator rejects each per-key extra value when written to any step-status key other than its owning key, with the error `Checkpoint has invalid <key>: <value>`.
- [x] The shared `VALID_STEP_STATUS` set in `scripts/dev_tools/validate_orchestrator_state.py` is unchanged; the new values are carried in a per-step-key additive map.
- [x] The Python `--require-complete` gate fails with a completion-validation error when any step status is `failed_remediation_required`.
- [x] The Python `--require-complete` gate fails with a completion-validation error when any step status is `blocked_ci_loop_limit`.
- [x] The Python `--require-complete` gate fails with a completion-validation error when any step status is `blocked_remediation_loop_limit`.
- [x] The Python `--require-complete` gate does not fail on `step9_status: "passed"` in an otherwise-complete checkpoint.
- [x] The Python `--require-pr-creation-ready` gate fails when `step6_status` is `blocked_remediation_loop_limit`.
- [ ] The TypeScript mirror (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`) implements the same per-key acceptance and rejection behavior with error strings byte-identical to the Python validator, verified by Jest cases.
- [ ] The TypeScript completion check rejects `failed_remediation_required`, `blocked_ci_loop_limit`, and `blocked_remediation_loop_limit` with error strings byte-identical to the Python validator, and does not reject `step9_status: "passed"`.
- [x] `.claude/lib/orchestrator-state/OrchestratorState.psm1` implements the same per-key acceptance and rejection behavior, verified by Pester cases in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.
- [x] A checkpoint with `epic_mode: true` and `step9_status: "passed"` passes plain validation and satisfies `.claude/hooks/enforce-epic-merge-gate.ps1` with zero edits to that hook (regression scenario).
- [ ] All pre-existing step-status validator tests (Python, Pester, Jest) pass without fixture modification, demonstrating that no previously valid checkpoint is newly rejected in plain mode.

### Divergence 2 — complexity-floor semantics

- [x] `compute_complexity_floor` returns `C1` for each single-element list containing a `"floor": false` signal (`single_file_localized_edit`, `mechanical_rename_or_move`, `docs_or_comment_only`) and for a single-element list containing an unknown signal name.
- [x] `compute_complexity_floor` returns `C3` for each single-element list containing a `"floor": true` signal and for any mixed list containing at least one floor signal, returns `C1` for `[]`, and never returns `C4`.
- [x] `Get-ComplexityFloor` in `.claude/lib/model-routing/ModelRouting.psm1` produces outputs identical to `compute_complexity_floor` for the same truth table, verified by Pester cases in `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`.
- [x] `tests/scripts/dev_tools/test_compute_complexity_floor.py` contains a static parity assertion that the embedded `FLOOR_SIGNAL_NAMES` set equals the set of names flagged `"floor": true` in `config/orchestration-routing.json`.
- [x] `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` contains a static parity assertion pinning `$script:FLOOR_SIGNAL_NAMES` to the config's `"floor": true` names.
- [x] The complexity validator accepts a recorded `complexity_assessments` entry whose `signals_present` contains only non-floor signals and whose `floor` is `"C1"`.
- [x] The complexity validator rejects the same entry with `floor: "C3"`, producing a floor-mismatch error that names the recomputed value `C1`.
- [x] `scripts/dev_tools/compute_complexity_floor.py` docstrings no longer claim caller pre-filtering, the module performs no file I/O, and the file remains under 500 lines.
- [x] `.claude/lib/model-routing/ModelRouting.psm1` performs no file reads at runtime.
- [ ] The PR body records the divergence-2 backward-compatibility statement: zero stored assessments invalidated (paths and counts per the research), and pre-change checkpoints with non-floor-only assessments require re-recording via the documented resume reconciliation.

### Cross-cutting

- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes, confirming the root `.claude/lib` modules and their `extensions/drm-copilot/resources/claude-customizations` mirrors are content-identical.
- [ ] The full per-language toolchain (format, lint, type-check where applicable, tests) passes for every batch.
- [ ] Line coverage >= 85% and branch coverage >= 75% are maintained on changed files.

## Risks & Mitigations
- Technical or operational risks:
  - Divergence-2 formula change invalidates pre-change checkpoints in other worktrees whose assessments recorded only non-floor signals (residual nonzero risk outside this repository's search scope). Mitigation: the documented resume reconciliation recomputes and rewrites the entry; the PR body states the consequence and repair step.
  - Error-string drift between the Python validator and the TypeScript mirror. Mitigation: Batch 1 precedes Batch 5; Jest cases assert byte-identical strings.
  - Root/mirror `.psm1` divergence. Mitigation: mirror copies land in the same batch; `test_push_down_claude_resource_contracts.py` enforces byte identity.
  - Typoed floor-signal names silently compute `C1` under the ignore-unknowns policy. Mitigation: `band >= floor` and band-enum membership still validate; catalog-membership validation is recorded as a follow-up.
- Mitigations and rollbacks: revert the batches; no data migration or flag cleanup is required.

## Rollout & Follow-up
- Release/rollout steps: standard PR merge; the resources byte mirrors ship the change to consumer repositories via the existing push-down mechanism.
- Post-fix monitoring or clean-up tasks: none required.
- Recorded follow-ups (out of scope for this fix):
  1. Optional `enforce-completion-consistency.ps1` detector extension (`step9_status == 'passed'` as a completion assertion) plus its codex mirror, two resources mirrors, and Pester suite.
  2. Optional additive validator check that every `signals_present` element is a catalog member (typo detection), requiring a config read in `_orchestrator_state_complexity.py`.
- Links: Issue #412 (https://github.com/drmoisan/drm-copilot/issues/412); research artifact `research/2026-07-25T20-45-orchestration-state-contract-divergences-research.md`; originating feature #286 (`docs/features/completed/2026-07-03-two-axis-model-selection-286/`).
