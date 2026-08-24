# Research: Orchestration State Contract Divergences (#412)

- **Issue:** #412
- **Feature folder:** `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412`
- **Work mode:** full-bug
- **Base branch:** main
- **Timestamp:** 2026-07-25T20-45
- **Author:** task-researcher

## Verification Method Disclosure

This research environment exposed read-only analysis tools (file read, content search, glob) and no shell executor. Runtime command verification (`poetry run python -c`, `pwsh -NoProfile -Command`, `git log`) could not be executed inside this agent session. Evidence therefore comes from three sources:

1. Static reading of the exact code paths, with file and line citations for every claim.
2. Runtime outputs already verified and recorded in the orchestrator's delegation input: both floor implementations return `C1` for `[]` and `C3` for each of `['single_file_localized_edit']`, `['docs_or_comment_only']`, `['not_a_real_signal']`; and writing `step9_status: "passed"` produces `Checkpoint has invalid step9_status: passed`. The static code reading below independently confirms each of these outcomes is the only possible behavior of the cited code.
3. Committed feature documents standing in for git-history intent evidence (git commands unavailable): `docs/features/completed/2026-07-03-two-axis-model-selection-286/spec.md` and `plan.2026-07-03T16-19.md`.

Confirmation commands the atomic plan MUST include as baseline evidence (fail-before) before implementation:

- `poetry run python -c "from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor as f; print(f([]), f(['docs_or_comment_only']), f(['not_a_real_signal']))"` — expected pre-fix output `C1 C3 C3`.
- `pwsh -NoProfile -Command "Import-Module ./.claude/lib/model-routing/ModelRouting.psm1; Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only')"` — expected pre-fix output `C3`.
- A Python validator call on a minimal checkpoint carrying `step9_status: "passed"` — expected pre-fix error `Checkpoint has invalid step9_status: passed`.

---

## Divergence 1 — `step9_status` enumeration

### Current state

- `.claude/skills/orchestrate/SKILL.md` documents `step9_status` as "an enumeration with at minimum the values `pending`, `passed`, `failed_remediation_required`, and `blocked_ci_loop_limit`" (line 238), instructs `step9_status: "passed"` on CI green (line 222), `failed_remediation_required` on poll timeout (line 221) and failed required checks (line 267), and `blocked_ci_loop_limit` on the third failed CI pass (line 273). Line 225: "DONE is not written while `step9_status` is anything other than `passed`."
- `scripts/dev_tools/validate_orchestrator_state.py` defines `VALID_STEP_STATUS = {not-applicable, pending, delegated, verified, blocked, not_started, in_progress, completed}` (lines 88–97) and applies it uniformly to every key in `STEP_STATUS_KEYS` = `step5_status`..`step10_status` (lines 107–114, check at lines 411–414). All three documented non-`pending` S9 values are rejected.
- Consequence confirmed: neither a CI pass, a CI failure, nor a CI-loop-limit halt is representable, so the fail-closed S9 halt path cannot be persisted.

### Adjacent finding (same defect class, same files)

`.claude/skills/orchestrate/SKILL.md` line 200 (Remediation Loop termination guard) instructs recording `step6_status: "blocked_remediation_loop_limit"` on the third remediation pass. That value is also outside `VALID_STEP_STATUS` and is equally unpersistable. It is the same defect class in the same production files. Recommendation: include it in this fix (the per-key mechanism below covers it at near-zero marginal cost); the spec should list it explicitly so the scope decision is recorded.

### RQ1.1 — Authoritative side: the documented contract (SKILL.md)

Ruling: the documentation is authoritative; `VALID_STEP_STATUS` is the lagging implementation.

Evidence:

1. **A shipped enforcement hook already implements the documented vocabulary.** `.claude/hooks/enforce-epic-merge-gate.ps1` line 148 (`Test-ChildCheckpointAllowsEpicMerge`): `return ([string]$Checkpoint.step9_status) -eq 'passed'`, and its block message at line 287 names `step9_status == "passed"` as the merge precondition. Its Pester suite `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (lines 37–48, 158–168) asserts the `passed` semantics. The runtime is therefore deadlocked today: the epic merge gate requires a value the checkpoint validator rejects. Only one side can be correct, and the hook + its tests sit on the documented side.
2. **The documented vocabulary is load-bearing for fail-closed behavior.** The S9 failure states (`failed_remediation_required`, `blocked_ci_loop_limit`) exist so a CI failure blocks DONE persistently. Collapsing them into the shared vocabulary loses the distinction between "blocked awaiting delegate" (`blocked` + `VALID_BLOCKED_REASONS`, which contains no CI reason — lines 98–106) and "CI loop limit reached, halt permanently." `VALID_BLOCKED_REASONS` would need widening anyway under any mapping approach.
3. **The doc contract is mirrored across every documentation surface** (`.agents/skills/orchestrator-workflow/SKILL.md`, `.github/agents/*orchestrator.agent.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`), while the narrow enum exists only in the three validator mirrors. Aligning the implementation is the smaller and semantically correct change.

### RQ1.2 — Fix shape: per-step extra vocabulary layered on the shared set (option b)

Recommended: **(b) a step-specific additive enum layered on the shared set.**

- Mechanism: keep `VALID_STEP_STATUS` unchanged; add a per-key map, e.g. `STEP_SPECIFIC_EXTRA_STATUS = {"step9_status": {"passed", "failed_remediation_required", "blocked_ci_loop_limit"}, "step6_status": {"blocked_remediation_loop_limit"}}`. A value is valid when it is in the shared set or in that key's extra set. Mirror identically in TS and the PowerShell module.
- Why widening the shared set (option a) matters and is rejected: widening would validate `step5_status: "passed"` or `step7_status: "blocked_ci_loop_limit"` — states with no documented meaning. The concrete harm is bounded (the `require_complete` gate must blocklist the failure values for all keys under either option, so option (a) is not a gate bypass), but it permanently weakens the checkpoint shape contract and makes the validator unable to catch a status written to the wrong step key, which is precisely the class of clerical error a resume workflow depends on catching. The per-key map costs a few lines and preserves the stricter contract. Option (a) is acceptable-but-weaker; not recommended.
- Why re-vocabulary (option c) is rejected: mapping `passed`→`completed` / failures→`blocked` requires editing the orchestrate SKILL plus its three documentation mirrors, `enforce-epic-merge-gate.ps1` plus its codex mirror (`.codex/hooks/enforce-epic-merge-gate.ps1`) and two resources mirrors and its test suite, and widening `VALID_BLOCKED_REASONS` — a strictly larger surface — while destroying the distinction between S9 failure modes and the remediation-loop-limit halt. It also invalidates line 225 of the skill ("DONE is not written while `step9_status` is anything other than `passed`"), which the epic merge gate depends on.

### RQ1.3 — Complete consumer enumeration for step-status values

| # | Consumer | Symbol / location | Must change? |
|---|---|---|---|
| 1 | `scripts/dev_tools/validate_orchestrator_state.py` | `VALID_STEP_STATUS` (l.88–97), `STEP_STATUS_KEYS` (l.107–114), plain check (l.411–414), `require_complete` check `value in {"pending", "blocked"}` (l.465–470) | Yes — per-key extra set; completion blocklist extended (RQ1.4) |
| 2 | `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` | `PR_CREATION_READY_STEP_KEYS` (l.49–54, steps 5–8 only), blocked set `{"pending", "blocked"}` (l.97) | Yes, only for the step6 adjacent finding: `blocked_remediation_loop_limit` must block PR creation (add to the blocked set). S9 values are outside its key set (comment l.45–48) |
| 3 | `scripts/dev_tools/_orchestrator_state_preparation_terminal.py` | `OUT_OF_SCOPE_STEP_KEYS` requires exactly `'not-applicable'` (l.30–35) | No — equality against `not-applicable` is unaffected |
| 4 | `scripts/dev_tools/_orchestrator_state_routing.py` | No step-status reads (grep for `step\d+_status|pending|blocked`: no matches) | No |
| 5 | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | `$script:VALID_STEP_STATUS` (l.75–84), applied at l.262; header pins it to the Python validator (l.16–17) | Yes — same per-key extension; plus byte-identical resources mirror (see RQ6) |
| 6 | `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | Imports the sibling module (l.32) and performs presence-level checks only; no step-status literals of its own | No — behavior flows from #5 |
| 7 | `.claude/hooks/enforce-epic-merge-gate.ps1` | `Test-ChildCheckpointAllowsEpicMerge`, `step9_status -eq 'passed'` (l.145–148) | No — already implements the authoritative vocabulary (this is ruling evidence) |
| 8 | `.claude/hooks/enforce-completion-consistency.ps1` | Completion-assertion detector: `step8_status/step9_status/step10_status -eq 'completed'` (l.160–165) | Optional follow-up only. Under the authoritative vocabulary S9's terminal success is `passed`, so the detector never fires on step9; DONE detection still works via `next_step == 'complete'` (l.148) and `S12_complete` (l.152–157). Adding `passed` for step9 is defense-in-depth; it drags in the codex mirror `.codex/hooks/enforce-completion-consistency.ps1`, two resources mirrors, and its Pester suite. Recommend deferring; record in spec as follow-up |
| 9 | `.claude/hooks/validate-orchestrator-output.ps1` | **OUT OF SCOPE per delegation.** Grep confirms it contains no step-status literals; it imports `OrchestratorState.psm1` (l.41) and invokes the Python validator with `--require-complete --require-model-routing`. All required behavior change flows through #1 and #5 without touching this file. **No follow-up dependency for the parallel orchestration is created by this feature.** |
| 10 | `.claude/hooks/enforce-pr-author-skill.ps1` | Imports `OrchestratorState.psm1` (l.49); no step-status literals | No — flows from #5 |
| 11 | `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` | `VALID_STEP_STATUS` (l.84–93), `STEP_STATUS_KEYS` (l.118–125), plain check (l.303–312), completion check `value === "pending" || value === "blocked"` (l.354–361). Header (l.49): "Error-message strings are identical to the Python source." | Yes — must change in step with #1, including identical new error strings |
| 12 | `extensions/drm-copilot/src/lib/validate/orchestrator-state-preparation-terminal.ts` | `step9_status` in its out-of-scope key list (l.12), equality against `not-applicable` | No |

The MCP TypeScript surface does **not** shell out to the Python validator for step-status validation; `validateOrchestratorStateText` in `orchestrator-state-core.ts` is a full port ("Mirror Python `validate_orchestrator_state_text`", l.268) and must change in step.

### RQ1.4 — Interaction with the `require_complete` gate

The completion gate currently rejects only `{"pending", "blocked"}` (`validate_orchestrator_state.py` l.465–470; TS mirror l.354–361). Without extension, a checkpoint recording `step9_status: "failed_remediation_required"` or `blocked_ci_loop_limit` would newly PASS the completion gate — i.e., DONE could be written on a recorded CI failure. This must be closed in the same change.

Values that MUST block completion (added to the existing `{pending, blocked}` set, applied across all step keys since the failure values are per-key-valid only anyway):

- `failed_remediation_required`
- `blocked_ci_loop_limit`
- `blocked_remediation_loop_limit`

`passed` must NOT block completion. Requiring `step9_status == "passed"` exactly at completion is NOT recommended: it would break the preparation route (`not-applicable` terminal contract, `_orchestrator_state_preparation_terminal.py`) and legacy checkpoints using `completed`; the route-driven `ci_gate.conclusion == "success"` check (l.480–481 plus `_validate_completion_ci_gate` l.245–276) already enforces the CI-green substance. The blocklist approach is sufficient and additive.

The same three values must be added to the TS completion check (`orchestrator-state-core.ts` l.354–361) with byte-identical error strings. `--require-pr-creation-ready` (steps 5–8) needs only `blocked_remediation_loop_limit` added (step6 is in its key set; the S9 values are not).

### RQ1.5 — Existing checkpoints that a change would invalidate

None. The change is purely widening (previously-invalid values become valid; no currently-valid value becomes invalid in plain mode). Search evidence:

- `artifacts/` contains exactly one JSON file: `artifacts/orchestration/orchestrator-state.json` (Glob `artifacts/**/*.json`). Its six step statuses are all `pending` (lines 21–26) — valid before and after. Note `/artifacts` is gitignored (`.gitignore` line 6), so this is a runtime-local file, not a committed artifact.
- No committed JSON fixture anywhere carries step-status values outside the current set (grep `"passed"` / step-status literals across `scripts/`, `tests/`: the only `passed` step9 occurrences are the epic-merge-gate hook and its tests, which are hook inputs, not validator fixtures).
- The completion-gate extension does newly reject the three failure values — but no stored checkpoint carries them (they were unwritable until this fix), so nothing existing is invalidated.

Tests that pin current rejection behavior and remain green (they use `invalid-status`, not the new values): `tests/scripts/dev_tools/test_validate_orchestrator_state.py::test_validate_orchestrator_state_text_rejects_invalid_step_status` (l.208–235, uses `step8_status = "invalid-status"`); `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts` (l.82–92, same fixture). Both files gain new cases but need no fixture repair.

---

## Divergence 2 — Complexity-floor signal semantics

### Current state

- Contract: `.claude/skills/orchestrate/SKILL.md` l.105 and `.claude/rules/orchestrator-state.md` (complexity invariants): "Each present `[floor]` signal contributes a candidate band of `C3`". `config/orchestration-routing.json` `model_policy.complexity.signals` (l.133–169) marks exactly four signals `"floor": true` and three `"floor": false`.
- Implementation: `scripts/dev_tools/compute_complexity_floor.py` returns `C3` for ANY non-empty sequence (l.97–108: empty guard then `candidate_rank` for every element unconditionally). `.claude/lib/model-routing/ModelRouting.psm1` `Get-ComplexityFloor` (l.109–123) is an exact port with the same behavior. Both were runtime-verified (delegation input): `C1` for `[]`, `C3` for `['single_file_localized_edit']`, `['docs_or_comment_only']`, `['not_a_real_signal']`.
- The pre-filtering contract is incoherent. The docstring (compute_complexity_floor.py l.13–19, l.75–81) says the caller pre-filters to `[floor]`-flagged signals. But the validator is itself a caller and does NOT pre-filter: `scripts/dev_tools/_orchestrator_state_complexity.py` l.147–160 passes the full recorded `signals_present` list (`signal_names = _string_list(signals_present)` then `compute_complexity_floor(signal_names)`). The checkpoint field is `signals_present[]` — the full assessed-signal record (SKILL.md l.113: "The recorded `floor` must equal `compute_complexity_floor(signals_present)`"; `.claude/rules/orchestrator-state.md` invariant 3 states the same equality). The two constraints — "caller pre-filters" and "floor equals the recompute over the recorded full array" — cannot both hold. An orchestrator that honestly records a non-floor signal in `signals_present` is forced to record floor `C3` or fail validation.

### RQ2.1 — Authoritative side: the documented contract and the config

Ruling: the documentation + config are authoritative; both implementations diverge together.

Evidence:

1. **Config structure proves intent.** `config/orchestration-routing.json` deliberately encodes `"floor": false` on three signals (l.155–168). Under current implementation behavior that flag never changes any outcome — dead configuration. A flag written as `false` on purpose, in the same block that flags four others `true`, is direct evidence the author intended non-floor signals not to raise the floor.
2. **Consequences under the alternative.** If the implementation were authoritative, every phase that honestly records any signal floors at `C3`, so `complexity_to_model` cells `C1: haiku` and `C2: sonnet` (config l.171–176) become unreachable for any signal-reporting assessment, and the C1/C2 scale anchors ("trivial or mechanical", "localized") plus all three non-floor anchors become dead text. The documented design (feature 286) explicitly built a four-band economy; behavior that collapses it to a two-band economy cannot be the contract.
3. **Origin-intent record (in lieu of git history; git unavailable in this session).** The originating spec `docs/features/completed/2026-07-03-two-axis-model-selection-286/spec.md` l.76–81: "Each signal flagged `[floor]` in the `model_policy.complexity` signal catalog contributes a candidate band of `C3`" and simultaneously l.108: "`floor == compute_complexity_floor(signals_present)`". The plan `plan.2026-07-03T16-19.md` l.56 repeats the `[floor]`-only contribution as the P1-T1 acceptance criterion. The intent chain is unambiguous; the implementation took a shortcut (any non-empty → C3) and papered over it with the caller-pre-filters docstring clause, which the validator invariant contradicts.
4. The two implementations agreeing with each other is not evidence of correctness: `ModelRouting.psm1` is documented as a "Faithful PowerShell port of compute_complexity_floor" (l.79–80) — it inherited the defect by design.

### RQ2.2 — Unknown-signal policy: ignore (contribute nothing)

Recommended: an unrecognized signal name contributes no floor candidate (treated as non-floor). `compute_complexity_floor(['not_a_real_signal']) == "C1"`.

Justification:

- **Rejecting (raising) is incompatible with the validator.** `_validate_complexity_assessments` is an error-string collector that never raises (module contract l.79–83); a raising formula would force try/except translation in the validator and in `_orchestrator_state_model_routing_gate.py`'s reuse path, and would make any checkpoint carrying a free-form signal name permanently unvalidatable — a harsher compatibility break than the formula fix itself.
- **Treating unknowns as floor signals reproduces the bug being fixed**: any typo or free-text rationale token floors at `C3`, and the `"floor": false` flags stay dead for unknown names. It also makes the floor set unbounded, which the parity tests (RQ2.5) could not pin.
- **Fail-open analysis, honestly stated:** ignoring unknowns means a typoed floor signal (`auth_or_token_handlng`) silently computes `C1`. The floor is a lower bound on a judgment band, not a security gate — the assessed `band` and its rationale remain, and the validator still enforces `band >= floor` and band-enum membership. The residual typo risk is best handled by an additive validator membership check (each `signals_present` element must be a catalog member) — recorded here as a recommended follow-up, not in scope, because it adds a config read to the complexity validator and a new error message class.

### RQ2.3 — Source of truth for the floor-signal set: hard-coded set pinned by parity tests

Recommended: hard-code the floor-signal name set in both implementations; pin both to `config/orchestration-routing.json` with static parity tests.

- The repository already uses exactly this pattern for the same module pair: `ModelRouting.psm1` embeds `BASE_COMPLEXITY_TO_MODEL`, `PREFERRED_OVERLAY_AGENTS`, etc. as literals, pinned by `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` (header l.5–11: "asserts that the module's embedded script-scope constants equal the authoritative config values"). SKILL.md l.108 documents this architecture: "pinned to the same `config/orchestration-routing.json` truth table by a static config-parity test."
- Reading the config at runtime is not viable for the PowerShell half: `ModelRouting.psm1` is pushed down to consumer repositories that receive only the `.claude` tree (`scripts/dev_tools/push_down_claude_customizations.py`, `ROOT_FOLDERS == (Path(".claude"),)` per its test l.80) — `config/orchestration-routing.json` does not exist at the destination. The module header (l.13–15) states the constraint: "Both functions are pure and deterministic: they read no file at runtime." Making only Python read the config would split the mirror architecture.
- Purity and testability: `compute_complexity_floor.py`'s docstring assertion "This module does not read the routing config or any other file" (l.17–18) stays true; the function stays pure per `.claude/rules/python.md` seam guidance and `general-code-change.md` I/O-boundary rules; file stays far under 500 lines.
- Concrete change: add `FLOOR_SIGNAL_NAMES: frozenset[str]` to `compute_complexity_floor.py` and `$script:FLOOR_SIGNAL_NAMES` to `ModelRouting.psm1`; compute the floor from `signals_present ∩ FLOOR_SIGNAL_NAMES`; update docstrings to remove the caller-pre-filters clause. Rejected alternative — implementations read config: breaks the pushed-down runtime, adds I/O to pure reference formulas, and contradicts two module contracts.

### RQ2.4 — Backward compatibility (exact counts and paths)

(a) **Stored assessments invalidated by the formula change: 0.**

- Checkpoints under `artifacts/`: exactly one JSON file exists, `artifacts/orchestration/orchestrator-state.json` (Glob `artifacts/**/*.json`; `/artifacts` is gitignored per `.gitignore` l.6). It carries exactly one `complexity_assessments` entry (l.127–138): `signals_present: ["cross_module_contract_change"]`, recorded `floor: "C3"`. `cross_module_contract_change` is `"floor": true` in the config (l.150), so the recomputed floor is `C3` before and after the fix. Not invalidated.
- Committed JSON checkpoints or fixtures carrying `complexity_assessments`: none. Grep `complexity_assessments` restricted to `**/*.json` across the repo: no files. Every other `complexity_assessments` occurrence is Markdown documentation, source, or test code that constructs fixtures programmatically.
- `SearchScope:` repo root recursive (`artifacts/`, `tests/`, `docs/`, `extensions/`, `scripts/`, `.claude/`); `SearchPatterns:` `complexity_assessments` (all files and `**/*.json`), `signals_present` (all files), Glob `artifacts/**/*.json`; `SearchResult:` one runtime checkpoint (path above), zero committed JSON.

(b) **Test fixtures asserting the any-non-empty-list behavior: none.**

- `tests/scripts/dev_tools/test_compute_complexity_floor.py` derives all inputs from the live catalog filtered to `floor: true` (`_floor_signals()`, l.24–47); no test feeds a non-floor or unknown signal.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` builds fixtures from `_floor_signal()` (first `floor: true` catalog entry, l.26–44) and computes expected floors by calling `compute_complexity_floor` itself (l.61–62); the only non-catalog inputs (`"not-a-list"`, `["ok", 123]`, l.184–215) hit the shape error before floor computation. All existing tests remain green after the fix; new cases are additive.
- `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` hard-codes exactly the four `floor: true` names (l.20–25) and never feeds a non-floor signal. Remains green.

(c) **Resumed orchestration whose checkpoint predates the change.** The complexity check runs in every validator mode whenever the `complexity_assessments` key is present (optional-key dispatch, `validate_orchestrator_state.py` l.437–453). A pre-change checkpoint whose entry recorded only non-floor signals necessarily recorded `floor: "C3"` (the old formula forced it); post-change it fails with `complexity_assessments #N floor C3 does not equal compute_complexity_floor(signals_present) C1.` and blocks resume until the entry is re-recorded. Exposure in this worktree: zero (the one live entry uses a floor signal). Other worktrees carry their own gitignored `artifacts/` outside this repo search scope; the same zero-forced-instances argument applies structurally only where assessments happened to use floor signals, so a nonzero residual risk exists there.

(d) **Recommendation: accept the break; no grace rule.** Justification: (i) zero observed invalidated instances in the repository; (ii) the affected artifact is runtime-local, gitignored, and regenerable — repair is re-running the documented resume reconciliation (SKILL.md l.39–47), which recomputes the floor and rewrites the entry; (iii) a legacy-acceptance rule ("accept floor C3 when recomputed C1") would permanently weaken invariant 3 of `.claude/rules/orchestrator-state.md`, is indistinguishable from the bug it excuses, and adds dead code once fleets roll forward. The PR body must state the consequence and the repair step.

### RQ2.5 — Config-parity tests binding the implementations to the config

Yes, parity infrastructure exists and is part of the change surface:

- `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` — the static config-parity Pester suite. Reads `config/orchestration-routing.json` (l.22–25) and pins `BASE_COMPLEXITY_TO_MODEL` per band (l.30–44), `PREFERRED_OVERLAY_AGENTS`/`BAND`/`MODEL` (l.48–77), `FLOOR_CANDIDATE_BAND`/`FLOOR_CEILING_BAND` = `C3` (l.80–90), and the disabled-policy literal (l.92–104). **Must be extended** to pin the new `$script:FLOOR_SIGNAL_NAMES` to the config's `floor: true` names.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` — byte-identity guard between `config/orchestration-routing.json` and the bundled mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` (l.33–56). Unaffected (config does not change) but names the second config copy that would need synchronizing if the config ever changed.
- `tests/scripts/dev_tools/test_compute_complexity_floor.py` — reads the live catalog's `floor: true` names (l.24–47). **Must be extended** with non-floor, unknown-signal, and mixed cases, plus a parity assertion `FLOOR_SIGNAL_NAMES == {names flagged floor: true in load_routing_matrix()}`, which becomes the Python-side static parity pin.
- `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` — behavioral Pester suite; must be extended with the same new cases.
- Cross-language byte parity of the module itself: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (l.100–125) requires every root `.claude/**` file (including `ModelRouting.psm1` and `OrchestratorState.psm1`) to have content-identical copies under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. Any edit to a root `.claude/lib` module must be copied to its resources mirror in the same batch or this test fails.

---

## Cross-cutting

### RQ6 — Complete file surface

**TypeScript mirror answer:** the MCP TS surface fully mirrors step-status validation (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `VALID_STEP_STATUS` l.84, completion check l.354–361) and must change in step for divergence 1. It does NOT mirror complexity-floor computation or `complexity_assessments` validation: `orchestrator-state-core.ts` dispatches only remediation, human-interaction, codex, and model-routing-existence validators (l.341–403), and `orchestrator-state-model-routing-existence.ts` contains no floor/complexity logic (grep `floor|compute|complexity_assessments`: no matches; core header l.131–136: "The authoritative Python validator performs full per-receipt correctness; this TS side performs the existence check only"). Divergence 2 therefore has zero TypeScript surface.

**Hooks answer:** only `enforce-epic-merge-gate.ps1` (reads `step9_status == 'passed'`; no change — already correct) and `enforce-completion-consistency.ps1` (step8/9/10 `== 'completed'` completion-assertion detector; optional follow-up only) read step statuses. No hook computes floors. `validate-orchestrator-output.ps1` is out of scope and, verified, requires no change: it carries no step-status or floor literals; all behavior flows through the Python validator and `OrchestratorState.psm1`. No follow-up dependency on the parallel orchestration is created.

Production/test surface (all paths repo-root-relative):

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

Explicitly unchanged (verified): `config/orchestration-routing.json` and its bundled mirror; `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md` and all documentation mirrors (docs are the authoritative side for both divergences); `scripts/dev_tools/_orchestrator_state_complexity.py` (passes the full recorded list — correct once the formula filters internally); `_orchestrator_state_routing.py`, `_orchestrator_state_preparation_terminal.py`, `_orchestrator_state_model_routing*.py`, `resolve_delegation_model.py`; `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/validate-orchestrator-output.ps1` (out of scope; no change needed), `.claude/hooks/enforce-pr-author-skill.ps1`; `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-preparation-terminal.ts`.

Note on `.claude` file counting: the two resources-mirror `.psm1` copies are byte copies required by `test_push_down_claude_resource_contracts.py`; they are counted as production PowerShell files in the batch caps below.

### RQ7 — Batch decomposition (caps: Python 3 prod + 3 test; PowerShell 2 prod + 3 test per batch, overall PowerShell scope of 4 prod files exceeds the 2-file direct-mode budget in `.claude/rules/powershell.md` l.39 and must route via `powershell-orchestrator`; TypeScript `direct_mode_enabled: false` in `config/orchestration-routing.json` routes to `typescript-engineer`):

1. **Batch 1 — Python, D1** (2 prod, 2 test): `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`; `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py`.
2. **Batch 2 — Python, D2** (1 prod, 2 test): `scripts/dev_tools/compute_complexity_floor.py`; `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py`.
3. **Batch 3 — PowerShell, D1** (2 prod, 1 test): `.claude/lib/orchestrator-state/OrchestratorState.psm1` + its resources mirror; `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.
4. **Batch 4 — PowerShell, D2** (2 prod, 2 test): `.claude/lib/model-routing/ModelRouting.psm1` + its resources mirror; `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`, `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`.
5. **Batch 5 — TypeScript, D1** (1 prod, 2 test; typescript-engineer): `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`; `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts`.

Ordering constraint: Batch 1 before Batch 5 (the TS port must copy the final Python error-message strings verbatim; `orchestrator-state-core.ts` l.49 contract). Batches 2, 3, 4 are mutually independent; Batch 3/4 mirror copies must land in the same batch as their root edits (push-down parity test). Both divergences are delivered; neither is dropped.

### RQ8 — Acceptance criteria for spec.md

D1:
1. `step9_status` values `passed`, `failed_remediation_required`, `blocked_ci_loop_limit` pass plain validation in the Python validator, the TS mirror, and `OrchestratorState.psm1`; the same values on any other `stepN_status` key are still rejected with `Checkpoint has invalid <key>: <value>`.
2. `step6_status: "blocked_remediation_loop_limit"` (SKILL.md l.200) is valid on `step6_status` only.
3. `--require-complete` fails with a completion-validation error when any step status is `failed_remediation_required`, `blocked_ci_loop_limit`, or `blocked_remediation_loop_limit` (in addition to the existing `pending`/`blocked`); `step9_status: "passed"` does not fail completion. Verified in both Python and TS with identical error strings.
4. `--require-pr-creation-ready` fails when `step6_status` is `blocked_remediation_loop_limit`.
5. A checkpoint with `epic_mode: true` and `step9_status: "passed"` passes plain validation and satisfies `enforce-epic-merge-gate.ps1` unchanged (regression scenario; no hook edits).
6. All existing valid checkpoints validate with zero new errors (backward-compatibility regression test).

D2:
7. `compute_complexity_floor` and `Get-ComplexityFloor` return `C1` for each `"floor": false` signal alone (`single_file_localized_edit`, `mechanical_rename_or_move`, `docs_or_comment_only`) and for unknown signal names; `C3` for each `"floor": true` signal alone and for any mixed list containing at least one floor signal; `C1` for `[]`; never `C4`. Both implementations produce identical outputs for identical inputs.
8. The floor-signal name set embedded in each implementation is pinned to the config's `floor: true` entries by a static parity assertion (extended `test_compute_complexity_floor.py`; extended `ModelRouting.Parity.Tests.ps1`).
9. The complexity validator accepts a recorded entry with only non-floor signals and `floor: "C1"`, and rejects the same entry with `floor: "C3"` (message names recomputed `C1`).
10. `compute_complexity_floor.py` docstrings no longer claim caller pre-filtering; the module remains pure (no file I/O) and under 500 lines; `ModelRouting.psm1` remains file-read-free.
11. Backward-compatibility statement recorded in the PR body: zero stored assessments invalidated (paths/counts per this research); pre-change checkpoints with non-floor-only assessments require re-recording via the documented resume reconciliation.

Cross-cutting:
12. Root `.claude/lib` modules and their `extensions/drm-copilot/resources/claude-customizations` mirrors are content-identical (`test_push_down_claude_resource_contracts.py` green).
13. Full toolchain green per language for every batch (format → lint → type-check → test), coverage thresholds maintained on changed files.

Follow-ups recorded, not in scope: (i) optional `enforce-completion-consistency.ps1` detector extension (`step9_status == 'passed'` as a completion assertion) plus its codex/resources mirrors and tests; (ii) optional additive validator check that every `signals_present` element is a catalog member (typo detection), requiring a config read in `_orchestrator_state_complexity.py`.

## Behavior Semantics

- S9 success: `step9_status: "passed"` iff `ci_gate.conclusion == "success"` and head-SHA match (SKILL.md l.222). Failure/timeout: `failed_remediation_required` (l.221, 267). Third failed CI pass: `blocked_ci_loop_limit`, halt, no DONE (l.273). All three must persist through the validator; the two failure values (plus step6's loop-limit value) must block `--require-complete` so DONE is unrepresentable on a recorded CI failure. Fail-closed default preserved: absent `step9_status` is treated as `pending` (l.263), which already blocks completion.
- Floor: `floor = C3` if `signals_present ∩ floor_signal_set ≠ ∅` else `C1`; never `C4`; deterministic and order-independent; unknown names contribute nothing. The validator recomputes over the full recorded array; `band >= floor` unchanged.

## Testing Implications

- New Python cases: per-key acceptance/rejection matrix for the extra statuses; completion blocklist for the three failure values; PR-creation-readiness rejection for step6; non-floor/unknown/mixed floor cases; floor-set parity assertion against `load_routing_matrix()`; validator acceptance of `floor: C1` with non-floor-only signals.
- New Pester cases mirroring the Python truth table for `Get-ComplexityFloor` and `Test-`-level checkpoint base checks; parity pin for `FLOOR_SIGNAL_NAMES`.
- New Vitest cases mirroring Python D1 message strings exactly.
- No fixture repair needed anywhere (RQ1.5, RQ2.4b). No temp files; all fixtures in-memory per repo test policy.

## Automation Feasibility

No human-interaction requirement identified. Both fixes are code/test changes in-repo, verified by the local toolchain and existing CI; no third-party UI, portal, or manual credential step is involved. The only environmental caveat is that this research session lacked a shell executor, so the planner must schedule the baseline fail-before commands listed in the Verification Method Disclosure as the first execution task.

## Rejected Alternatives (summary)

- D1: widening the shared `VALID_STEP_STATUS` (weakens per-step shape checking; completion blocklist needed anyway); re-vocabulary to existing values (larger surface across hooks/mirrors/tests, loses failure-mode distinctions, invalidates the epic merge gate contract).
- D2: implementations reading `config/orchestration-routing.json` at runtime (breaks the pushed-down `.claude`-only runtime, violates both modules' purity contracts); treating unknown signals as floor signals (recreates the dead-config defect); raising on unknown signals (incompatible with the error-string validator and harsher on legacy checkpoints).
