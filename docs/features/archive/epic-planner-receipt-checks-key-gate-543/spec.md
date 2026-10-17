# epic-planner-receipt-checks-key-gate (Spec)

- **Issue:** #543 (remainder; this change closes the issue)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T08-15
- **Status:** Ready for Planning
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md` is created)
- **Design source:** `docs/features/active/epic-planner-receipt-checks-key-gate-543/research/research.2026-10-15T08-05.md` (recommended Candidate A, research §3)
- **Precedents (context only, not edited):** PR #829 (`docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`), PR #874 (`docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`), PR #912 (`docs/features/active/2026-10-11-epic-planner-field-list-remainder-543/spec.md`)

## Context

- Summary: under `require_ready_for_execution`, `_validate_ready_features` in `scripts/dev_tools/validate_epic_planner_state.py` validates each feature's `model_routing_receipt` (via `validate_codex_model_routing_receipts`, plus the `logical_agent`, `complexity_band`, and `execution_context` checks) and each feature's `topology_receipt` (via `_validate_child_topology_receipt`) unconditionally. Both receipts are Codex-runtime evidence that no Claude-runtime producer writes, so a fully prepared Claude epic-planner checkpoint fails the ready gate on every feature. The TypeScript twin `validateReadyFeatures` in `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` carries the same unconditional checks.
- Prior #543 work: PR #829 key-gated the per-feature launch bindings and launch evidence; PR #874 key-gated the top-level planner `topology_receipt`; PR #912 corrected the Claude `epic-planner.md` field list. Each of those specs recorded the per-feature receipt checks as deferred (research §2). This change closes that last gap.
- Observed environment(s): any OS (observed on Windows 11); repository Poetry environment; `extensions/drm-copilot` Node toolchain.
- Customer impact and severity: Medium. Every Claude-runtime epic-planner checkpoint validated with `require_ready_for_execution` and no Codex flag is rejected, through both the Python validator and the MCP `validate_orchestration_artifacts` route. Codex callers, which assert both Codex flags, are not affected.
- First observed date and version(s) impacted: reported under issue #543 (2026-08-24 lifecycle record); present on `main` at commit 0349ed1f0.

## Repro & Evidence

- Steps to reproduce:
  1. Author an epic-planner checkpoint with at least two fully prepared features, no per-feature `model_routing_receipt` or `topology_receipt` key, no launch-binding keys, and no top-level `topology_receipt`.
  2. Validate it with `validate_epic_planner_state_text(text, require_ready_for_execution=True)` and no Codex flag, or through MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state` and `require_ready_for_execution: true`.
  3. Observe per-feature receipt errors.
- Expected: when neither `require_codex_model_routing` nor `require_codex_topology` is asserted, each per-feature receipt check runs only when its key is present on the feature. With no readiness context, the Claude-shaped checkpoint yields exactly `["Execution-ready planner validation requires repository context."]`. When either Codex flag is asserted, both checks remain unconditional. Python and TypeScript behave identically.
- Actual: for every feature `i`, both runtimes emit `Epic planner checkpoint features[i].model_routing_receipt must be an object.` (source string `scripts/dev_tools/_orchestrator_state_codex_model_routing.py:80`, prefix-rewritten) and `Epic planner checkpoint features[i].topology_receipt must be an object.` (`scripts/dev_tools/_orchestrator_state_codex_topology.py:97`).
- Logs/screenshots/error snippets: the two strings above; see issue #543 history.
- Frequency / determinism: deterministic; occurs for every feature lacking either key whenever the ready gate runs without a Codex flag.

## Scope & Non-Goals

- In scope:
  - Python: key-gate the per-feature model-receipt block and topology-receipt block inside `_validate_ready_features` (`scripts/dev_tools/validate_epic_planner_state.py:222-276`), passing the existing `key_gated` value from the call site at line 342.
  - TypeScript: key-gate the same two blocks inside `validateReadyFeatures` (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:292-364`), passing the existing `requireLaunchPaths` value from the call site at line 438.
  - Update the in-file docstrings and comments that describe which ready-gate checks are key-gated.
  - Tests: in-place update of `test_readiness_requires_resolved_child_model_receipt` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py`; new `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`; new `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`; extension of `it("threads the Codex flags into epic-planner-state")` in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`.
- Out of scope / non-goals:
  - Python CLI Codex flags. `scripts/dev_tools/validate_orchestration_artifacts.py` is not changed; the CLI continues to run in key-gated mode only (PR #829 deferral; research §4).
  - Per-flag gating (research Candidate B, rejected), value-truthiness gating, filtering the feature list before the call, or gating the whole `_validate_ready_features` call (research §3).
  - Renaming `key_gated` or `requireLaunchPaths`.
  - Adding, removing, or rewording any error string in either runtime.
  - Reopening PR #829, PR #874, or PR #912 behaviour, including the launch-binding `_validate_model_receipt` check (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:166-202`).
- Explicitly excluded systems, integrations, or datasets:
  - `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`.
  - `extensions/drm-copilot/resources/**`. No bundled mirror of either validator exists (research §6), so no mirror edit is required.
  - MCP input mapping, tool definitions, dispatch (`extensions/drm-copilot/src/mcp-tool-inputs.ts`, `mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`, `src/lib/validate/orchestration-artifacts.ts`) and `extensions/drm-copilot/jest.config.cjs`.
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` (no headroom; unchanged).

## Root Cause Analysis

- Confirmed root cause: the Codex flags reach `validate_epic_planner_state_text`, which computes `key_gated = not (require_codex_model_routing or require_codex_topology)` at `scripts/dev_tools/validate_epic_planner_state.py:332`, but the call `errors.extend(_validate_ready_features(features))` at line 342 does not pass it, and `_validate_ready_features(features: list[dict[str, Any]])` (line 222) takes no flag parameter. Its model-receipt block (lines 241-269) and topology block (lines 270-275) therefore run for every feature. The TypeScript twin computes `requireLaunchPaths` at `epic-planner-state-core.ts:425-427` but calls `validateReadyFeatures(featureResult.features)` at line 438 without it; the model-receipt block (lines 329-354) and topology block (lines 355-360) run for every feature.
- Signals/evidence: verified by reading both production files on 2026-10-15 (research §1.1-§1.3, §12). The same `key_gated` value already gates the adjacent launch-binding call (Python lines 343-347), the planner topology receipt (lines 348-351), and readiness integrity (lines 364-367).
- Affected components/modules:
  - `scripts/dev_tools/validate_epic_planner_state.py` (`_validate_ready_features`, `validate_epic_planner_state_text`)
  - `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (`validateReadyFeatures`, `validateEpicPlannerStateText`)
  - MCP route `validate_orchestration_artifacts` with `artifact_type: epic-planner-state` (behaviour only; no code change)

## Proposed Fix

### Design summary (what changes where):

Adopt research Candidate A: reuse the existing single activation value and apply a per-feature, per-key membership predicate inside the existing loop.

- Python: each block runs when `not key_gated or "<key>" in feature`.
- TypeScript: each block runs when `!keyGated || "<key>" in feature`, with the call site passing `requireLaunchPaths` as `keyGated`.

Behaviour matrix under `require_ready_for_execution=True` (research §7.1):

| Codex flag | Per-feature key state | Model-receipt block | Topology block |
|---|---|---|---|
| none | key absent | skipped, zero errors | skipped, zero errors |
| none | present, valid | zero errors | zero errors |
| none | present, `null` | `...features[i].model_routing_receipt must be an object.` | `...features[i].topology_receipt must be an object.` |
| none | present, wrong field | existing field errors (unchanged) | existing field errors (unchanged) |
| either flag | absent | `... must be an object.` (unchanged) | `... must be an object.` (unchanged) |
| either flag | present | validated in full (unchanged) | validated in full (unchanged) |

- Each key is gated independently: a feature carrying only `model_routing_receipt` has that receipt validated and its topology check skipped, and the reverse also holds.
- Without `require_ready_for_execution`, nothing changes.

### Boundaries and invariants to preserve:

- **Key membership, not value truthiness.** A present key with a `null` value arms the check (PR #829 and PR #874 precedent; `.claude/rules/orchestrator-state.md:228`).
- **Codex behaviour unchanged.** Under either Codex flag, single or combined, both per-feature checks run unconditionally, exactly as before.
- **Feature index preserved.** The skip happens inside the loop, so `features[i]` prefixes keep the original index.
- **Error strings and ordering unchanged.** No error string is added, removed, or reworded; within a feature, model-receipt errors precede topology errors. Python and TypeScript strings remain byte-identical.
- **Non-Codex per-feature checks unchanged.** `issue_num`, `feature_folder`, `research_path`, `plan_path`, `preparation_status`, `preflight_status`, and the at-least-two-features check still run for every feature.
- **Source-text contract preserved.** The literals `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` asserted by `test_push_down_codex_and_agents_customizations.py:397-404` are not modified.
- **Direct-caller default.** The new Python keyword-only parameter defaults to `False`, preserving unconditional behaviour for any direct caller.
- **500-line limit** for every touched file.

### Dependencies or blocked work:

- None. The Codex flags, `key_gated`, `requireLaunchPaths`, and MCP flag forwarding are already on `main` from PR #829 (research §4).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production:
- `scripts/dev_tools/validate_epic_planner_state.py` (375 lines; expected about 385-390)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (474 lines; expected about 482-484, verified after Prettier)

Tests:
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (424 lines; in-place update of one test)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (new; about 150 lines)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` (new; about 170 lines; matched by `jest.config.cjs` `testMatch` without configuration)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (232 lines; about 245)

#### Functions/classes/CLI commands impacted:

- Python:
  - New private helper `_validate_feature_model_receipt(feature: dict[str, Any], *, prefix: str) -> list[str]`, containing the body of lines 241-269 with identical error order. Extraction is required to avoid ruff E501: an additional `if` indent would take line 256 from 87 to 91 columns against `line-length = 88` (`pyproject.toml:89`).
  - `_validate_ready_features(features: list[dict[str, Any]], *, key_gated: bool = False) -> list[str]`.
  - `validate_epic_planner_state_text`: call site at line 342 becomes `_validate_ready_features(features, key_gated=key_gated)`; public signature unchanged.
- TypeScript:
  - `validateReadyFeatures(features: ReadonlyArray<Record<string, unknown>>, keyGated: boolean): string[]` (module-private).
  - `validateEpicPlannerStateText`: call site at line 438 passes `requireLaunchPaths`; exported signature and `ValidateEpicPlannerStateOptions` unchanged.
- MCP `validate_orchestration_artifacts` (`artifact_type: epic-planner-state`): behaviour changes only for features lacking a receipt key when no Codex flag is supplied; schema unchanged.
- Python CLI `validate_orchestration_artifacts.py epic-planner-state`: no code change; it runs key-gated, so it also skips absent per-feature receipts after this change.

#### Data flow and validation changes:

- No new keys are read or written. The only change is whether the existing per-feature receipt checks run for a feature that lacks the corresponding key when no Codex flag is asserted.
- A launch-keyed feature (carrying `launch_receipt_path` or `launch_status_path`) that omits `model_routing_receipt` still fails without a Codex flag through the launch-binding check, with the distinct prefix `Epic planner checkpoint features[i] launch binding.model_routing_receipt` (research §1.4). This is unchanged PR #829 behaviour.

#### Error handling and logging updates:

- None. No error string is added, removed, or reworded. No logging changes.
- Docstrings and comments updated: the `validate_epic_planner_state_text` docstring (Python lines 287-294), the comment at Python lines 330-331, the comment at TypeScript lines 423-424, and the `_validate_ready_features` / `validateReadyFeatures` docstrings, so each names the per-feature receipts as key-gated under the same rule.

#### Rollback/feature-flag considerations (if applicable):

- Rollback is a revert of the change set. Callers that need the previous behaviour can assert either Codex flag. No feature flag is introduced.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Inputs: checkpoint JSON text, `require_ready_for_execution`, readiness context, `require_codex_model_routing`, `require_codex_topology` (TypeScript: `requireReadyForExecution`, `readinessContext`, `requireCodexModelRouting`, `requireCodexTopology`). Output: a list of error strings in the existing format.

#### Required configuration keys and defaults:

- No new configuration keys. Existing defaults: `require_codex_model_routing=False`, `require_codex_topology=False` (Python); `undefined` (TypeScript). New Python parameter `key_gated` defaults to `False`.

#### Backward-compatibility expectations:

- Codex ready-gate callers assert both flags (`.agents/skills/epic-plan/SKILL.md:198-200`, `.agents/skills/epic-run/SKILL.md:24-26`, `.codex/agents/epic-orchestrator.toml:42-44`, and their mirrors, pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:407-423`) and are validated exactly as before.
- Any feature carrying a per-feature receipt key is validated exactly as before, in every mode.
- Pre-existing fixtures in `test_validate_epic_planner_state_launch_binding.py`, `test_epic_planner_readiness.py`, `epic-planner-state-core.test.ts`, `epic-planner-state-launch-binding.test.ts`, and `epic-planner-readiness-integrity.test.ts` carry both receipts or do not reach the ready gate, and are expected to pass unchanged (research §5.1).

#### Performance constraints (latency/throughput/memory):

- No new constraints; the change adds up to two key-membership tests per feature per validation.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - Work mode is `full-bug`; `spec.md` is the sole AC source and no `user-story.md` is created.
  - No new GitHub issue is created; the change is tracked against and closes issue #543.
  - Key membership is the correct presence predicate (PR #829 / PR #874 precedent).
  - No automated Python-to-TypeScript execution parity test exists; parity is maintained by twin tests asserting byte-identical strings (research §5.2).
  - Research ran no shell commands; baseline pass/fail state was not observed. The executor must capture a baseline before editing.
  - `extensions/drm-copilot/jest.config.cjs` has no per-file threshold for `epic-planner-state-core.ts`; its coverage is read from the full-run `text` reporter row.
- Constraints: 500-line limit per production and test file; no edits under the excluded paths listed in Scope; quality tiers per `quality-tiers.yml` (`scripts/dev_tools` T4, `extensions/drm-copilot` T3), with uniform line >= 85% and branch >= 75% coverage and no changed-line regression.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: the MCP and Python ready gates no longer reject a feature for lacking `model_routing_receipt` or `topology_receipt` when no Codex flag is asserted. Present keys are still validated in full.
- Data or migration considerations: none. Existing checkpoints remain valid or invalid as before, except that Claude-shaped checkpoints lacking the receipt keys now pass these checks.
- Logging/telemetry updates: none.
- Compatibility notes: Python CLI `epic-planner-state` subparser unchanged (key-gated mode only); MCP schema unchanged.

## Test Strategy

- Regression tests to add or update:
  - Regression (fail-before / pass-after): `test_ready_gate_skips_feature_receipts_when_keys_absent` in the new Python file, and its TypeScript twin in the new TS file. Fixture: a Claude-shaped ready state with both receipts and all launch-binding keys removed from every feature and no top-level `topology_receipt`; no Codex flag; no readiness context. Expected: exactly `["Execution-ready planner validation requires repository context."]`.
  - Update: `test_readiness_requires_resolved_child_model_receipt` (`tests/scripts/dev_tools/test_validate_epic_planner_state.py:176-188`). It currently removes `features[0].model_routing_receipt` without a Codex flag and asserts the substring `model_routing_receipt must be an object`; after the fix that substring would still match the launch-binding error, so the test would pass while pinning a different check. It is updated to assert a Codex flag and the exact string `Epic planner checkpoint features[0].model_routing_receipt must be an object.`.
- Unit tests (pytest and Jest) for the fixed behaviour and boundaries, in the new files:
  - `test_codex_flag_keeps_feature_receipts_unconditional`, parametrized over `require_codex_model_routing=True` and `require_codex_topology=True`.
  - `test_ready_gate_validates_present_null_feature_receipt`, parametrized over the two receipt keys.
  - `test_ready_gate_gates_each_feature_receipt_independently`.
  - `test_ready_gate_preserves_feature_index_when_receipts_skipped`.
  - TypeScript twins of all five Python tests, using `it.each` for parametrized cases, with byte-identical asserted strings.
- Edge cases and negative scenarios: present `null` keys with no flag; key absent under each single Codex flag; mixed features (one receipt-less, one with a `null` receipt) to pin index preservation; one key present with a wrong field and the other absent.
- Integration: extend `it("threads the Codex flags into epic-planner-state")` so the `requireCodexModelRouting` and `requireCodexTopology` results each contain both `features[0].model_routing_receipt must be an object.` and `features[0].topology_receipt must be an object.`, and the key-gated result contains neither `features[0].model_routing_receipt` nor `features[0].topology_receipt`. The dotted form avoids matching ` launch binding.model_routing_receipt`.
- Error handling and logging verification: assertions use exact strings or the dotted `features[i].<key>` form to distinguish ready-feature errors from launch-binding errors.
- Coverage impact and targets: line >= 85% and branch >= 75% for both changed production files; both outcomes of each new conditional (check run and check skipped) exercised in each runtime; no regression on changed lines relative to the recorded baseline.
- All tests use in-memory JSON fixtures with no temporary files, clock, or network, and follow Arrange-Act-Assert with descriptive names or docstrings.
- Toolchain commands (Python, from the worktree root):

```
poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing
```

`--cov` must use the dotted module name; a `.py` path measures nothing.

- Toolchain commands (TypeScript, from `extensions/drm-copilot/`):

```
npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts
npm run lint
npm run typecheck
node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts
node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
```

- Architecture stage: the extension has no dependency-cruiser configuration and the Python scope has no architecture-boundary tool for these files; record the stage as not applicable with that reason.
- Evidence: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/<kind>/` (`baseline/`, `regression-testing/`, `qa-gates/`).
- Manual validation steps: none required.

## Acceptance Criteria

- [x] **Python regression (fail-before / pass-after).** `test_ready_gate_skips_feature_receipts_when_keys_absent` in `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` builds a Claude-shaped ready checkpoint (no per-feature `model_routing_receipt` or `topology_receipt`, no launch-binding keys, no top-level `topology_receipt`), calls `validate_epic_planner_state_text` with `require_ready_for_execution=True`, no Codex flag, and no readiness context, and asserts `errors == ["Execution-ready planner validation requires repository context."]`. The test is recorded failing on the pre-fix tree and passing after the fix with `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv`, with both runs saved under `evidence/regression-testing/`.
- [x] **TypeScript regression (fail-before / pass-after).** The twin test in `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` builds the same Claude-shaped checkpoint, calls `validateEpicPlannerStateText` with `requireReadyForExecution: true` and no Codex option, and asserts the result equals `["Execution-ready planner validation requires repository context."]`. The test is recorded failing on the pre-fix tree and passing after the fix with `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts`, with both runs saved under `evidence/regression-testing/`.
- [x] **Codex flags keep the checks unconditional.** `test_codex_flag_keeps_feature_receipts_unconditional` in the new Python file is parametrized over `require_codex_model_routing=True` and `require_codex_topology=True` (each flag alone), removes both receipt keys from `features[0]`, and asserts that both `"Epic planner checkpoint features[0].model_routing_receipt must be an object."` and `"Epic planner checkpoint features[0].topology_receipt must be an object."` are in the errors. Its TypeScript twin (`it.each` over `requireCodexModelRouting: true` and `requireCodexTopology: true`) asserts the same strings. Both pass under the targeted pytest and Jest commands in Test Strategy.
- [x] **Present-`null` key is still validated.** `test_ready_gate_validates_present_null_feature_receipt` in the new Python file is parametrized over `model_routing_receipt` and `topology_receipt`, sets the key to `None` on `features[0]` with no Codex flag, and asserts the exact `"Epic planner checkpoint features[0].<key> must be an object."` string is in the errors. Its TypeScript twin sets the key to `null` and asserts the same strings. Both pass.
- [x] **Independent per-key gating.** `test_ready_gate_gates_each_feature_receipt_independently` in the new Python file removes `topology_receipt` from `features[0]` and sets `features[0].model_routing_receipt.logical_agent` to a value other than `orchestrator`, with no Codex flag, and asserts that `"Epic planner checkpoint features[0].model_routing_receipt.logical_agent must be 'orchestrator'."` is in the errors and that no error contains `features[0].topology_receipt`. Its TypeScript twin asserts the same. Both pass.
- [x] **Feature index preserved.** `test_ready_gate_preserves_feature_index_when_receipts_skipped` in the new Python file makes `features[0]` receipt-less and sets `features[1].topology_receipt` to `None`, with no Codex flag, and asserts that `"Epic planner checkpoint features[1].topology_receipt must be an object."` is in the errors and that no error contains `features[0].topology_receipt` or `features[0].model_routing_receipt`. Its TypeScript twin asserts the same. Both pass.
- [x] **Byte-identical error strings across runtimes.** Every error string asserted in `epic-planner-state-feature-receipts.test.ts` is byte-identical to the corresponding string asserted in `test_validate_epic_planner_state_feature_receipts.py`, verified by a side-by-side comparison of the asserted literals recorded under `evidence/qa-gates/`.
- [x] **Defect-pinning test updated.** `test_readiness_requires_resolved_child_model_receipt` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` is updated in place to pass `require_codex_model_routing=True` (or `require_codex_topology=True`) and to assert the exact string `"Epic planner checkpoint features[0].model_routing_receipt must be an object."` is in the errors, replacing the substring assertion. The test passes.
- [x] **MCP-level threading.** `it("threads the Codex flags into epic-planner-state")` in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` additionally asserts that the `requireCodexModelRouting` result and the `requireCodexTopology` result each contain `features[0].model_routing_receipt must be an object.` and `features[0].topology_receipt must be an object.`, and that the key-gated (no Codex flag) result contains no error with the substring `features[0].model_routing_receipt` or `features[0].topology_receipt`. The test passes under `node run-jest.cjs test/lib/validate/validate-orchestration-service-call.test.ts`.
- [x] **Gating predicate implemented as specified.** Reading the source confirms that in `_validate_ready_features` and `validateReadyFeatures` the model-receipt block runs only when the Codex-flag-derived gate is off or `"model_routing_receipt"` is a key of the feature, and the topology block runs only when the gate is off or `"topology_receipt"` is a key of the feature; that both checks remain inside the per-feature loop; that the Python call site passes `key_gated=key_gated` and the TypeScript call site passes `requireLaunchPaths`; and that the non-Codex per-feature checks are not conditioned.
- [x] **No error string added, removed, or reworded.** `git diff main -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` shows no added or removed string literal containing `Epic planner`, `must be`, or `must match` other than lines moved unchanged into `_validate_feature_model_receipt` or re-indented inside the new `if` blocks, verified by review of the diff recorded under `evidence/qa-gates/`.
- [x] **Pre-existing tests pass unmodified.** `test_readiness_requires_epic_preparation_topology_receipts`, `test_readiness_cross_binds_feature_complexity_and_model_context`, `test_ready_checkpoint_passes_execution_readiness`, `test_cli_dispatches_planner_readiness_flag`, `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`, the launch-binding and readiness test files, and all tests in `epic-planner-state-core.test.ts`, `epic-planner-state-launch-binding.test.ts`, and `epic-planner-readiness-integrity.test.ts` pass without modification, verified by the targeted `poetry run pytest` and `node run-jest.cjs` commands in Test Strategy exiting 0.
- [x] **Out-of-scope paths unchanged.** `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` produces no output.
- [x] **In-file documentation updated.** The `validate_epic_planner_state_text` docstring, the comment above `key_gated` in `validate_epic_planner_state.py`, the comment above `requireLaunchPaths` in `epic-planner-state-core.ts`, and the `_validate_ready_features` / `validateReadyFeatures` docstrings each state that the per-feature `model_routing_receipt` and `topology_receipt` checks are key-gated unless a Codex flag is asserted, verified by reading the source.
- [x] **500-line limit.** Every production and test file listed under "Files/modules to change" is at most 500 lines after formatting, verified with `(Get-Content <path>).Count` for each file and recorded under `evidence/qa-gates/`.
- [x] **Python toolchain clean pass.** `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` on the Python files listed in the Test Strategy commands exit 0, and `poetry run pytest ... --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing` (the full command in Test Strategy) exits 0 and reports at least 85% line and 75% branch coverage for `scripts/dev_tools/validate_epic_planner_state.py`, with no coverage regression on changed lines relative to the recorded baseline. All stages complete in a single pass, with output recorded under `evidence/qa-gates/`.
- [x] **TypeScript toolchain clean pass.** From `extensions/drm-copilot/`, `npx prettier --check` on the TypeScript files listed in the Test Strategy commands, `npm run lint`, and `npm run typecheck` exit 0, and `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 with the `text` reporter row for `src/lib/validate/epic-planner-state-core.ts` showing at least 85% line and 75% branch coverage and no coverage regression on changed lines relative to the recorded baseline. Both outcomes of each new conditional are exercised. All stages complete in a single pass, with output recorded under `evidence/qa-gates/`.
- [x] **PR closes the issue (CI-dependent; checked off at S9).** The pull request body states `Closes #543`, and CI on the final PR head completes with conclusion `success`.

## Risks & Mitigations

- Risk: a Codex caller that omits both flags would have absent per-feature receipts skipped.
  - Mitigation: all Codex ready-gate callers assert both flags, pinned by `test_push_down_codex_and_agents_customizations.py:407-423`. Launch-keyed features still require `model_routing_receipt` through the launch-binding check.
  - Residual: in no-flag mode, a launch-keyed feature's `topology_receipt` is no longer required.
- Risk: a test keeps passing on a different check, because `model_routing_receipt must be an object` is a substring of both the ready-feature error and the launch-binding error.
  - Mitigation: exact-string or dotted `features[i].<key>` assertions in all new and updated tests.
- Risk: `epic-planner-state-core.ts` (474 lines) crosses 500 lines after Prettier.
  - Mitigation: verify the count after formatting; if needed, extract the model-receipt block into `validateFeatureModelReceipt(feature, prefix)` in the same file, or move both ready-feature helpers into `extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts` with a mirrored test location (research §7.3).
- Risk: ruff E501 from deeper nesting in Python.
  - Mitigation: extract `_validate_feature_model_receipt` (research §7.2).
- Risk: Python and TypeScript diverge.
  - Mitigation: identical gating predicate in both runtimes and twin tests with byte-identical strings.
- Risk: `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on gitignored state (issue #510).
  - Mitigation: deselect it in any local full-suite run and rely on CI.
- Rollback: revert the change set; callers needing the previous behaviour can assert either Codex flag.

## Rollout & Follow-up

- Release/rollout steps: ship with the next extension release. No bundled mirror, guidance, or rule-file changes are required.
- End-to-end status: after this fix, a Claude-shaped ready checkpoint with no Codex flag passes all Codex-only ready-gate checks; with no readiness context it yields only the repository-context error. This is the #543 end-to-end outcome, so the PR states "Closes #543".
- Post-fix monitoring or clean-up tasks:
  - Conditional follow-up carried from PR #829: add Codex flags to the Python CLI `epic-planner-state` subparser if CLI parity is later required.
  - Optional: documenting optional validator fields for the Claude epic-planner contract, deferred by PR #912.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/543
  - Research: `docs/features/active/epic-planner-receipt-checks-key-gate-543/research/research.2026-10-15T08-05.md`
  - Precedents: PR #829, PR #874, PR #912 (folders listed in the header)
