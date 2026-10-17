# Research: key-gate the per-feature receipt checks in the epic-planner ready gate (Issue #543 remainder)

- **Issue:** #543 (closes the issue)
- **Branch:** `bug/epic-planner-receipt-checks-key-gate-543`
- **Feature folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543/`
- **Inputs read:** `issue.md`, `spec.md` (template, unfilled), `plan.2026-10-15T07-42.md` (template, unfilled) in this folder; the three prior #543 specs listed in section 2.
- **Timestamp note:** this session had no shell tool, so the host clock could not be read. The filename stamp is derived from the session date (2026-10-15) and is later than the plan stamp `07-42`.
- **Method:** Read and Grep against the current worktree tree only. No command was executed; no baseline pass/fail state was observed. The executor must capture baselines before editing.

---

## 1. Current State Analysis

### 1.1 Python per-feature receipt checks

`scripts/dev_tools/validate_epic_planner_state.py` (375 lines):

- `_validate_ready_features(features: list[dict[str, Any]]) -> list[str]` is defined at line 222. It takes no flag parameter.
- Model-routing receipt block, lines 241-269, runs for every feature:
  - 241-249: `validate_codex_model_routing_receipts([feature.get("model_routing_receipt")])`, with the prefix `Checkpoint codex_model_routing_receipts[0]` rewritten to `{prefix}.model_routing_receipt`. An absent key yields `Epic planner checkpoint features[i].model_routing_receipt must be an object.` (source string at `scripts/dev_tools/_orchestrator_state_codex_model_routing.py:80`).
  - 250-257: `logical_agent` must be `'orchestrator'`.
  - 258-269: `complexity_band` must match the feature; `execution_context` must be `'epic_preparation_child'`.
- Topology receipt block, lines 270-275: `_validate_child_topology_receipt(feature.get("topology_receipt"), prefix=f"{prefix}.topology_receipt")` for every feature. An absent key yields `Epic planner checkpoint features[i].topology_receipt must be an object.` (`scripts/dev_tools/_orchestrator_state_codex_topology.py:97`). `_validate_child_topology_receipt` is defined at lines 89-109.
- The only call site is line 342, inside `validate_epic_planner_state_text` (line 279) under `if require_ready_for_execution:` (line 329): `errors.extend(_validate_ready_features(features))`.

### 1.2 Existing key-gate logic (Python)

- Line 332: `key_gated = not (require_codex_model_routing or require_codex_topology)`, computed inside the ready branch. Comment at lines 330-331.
- Lines 343-347: `validate_epic_planner_child_launch_bindings(features, require_launch_paths=key_gated)` (PR #829).
- Lines 348-351: `if not key_gated or "topology_receipt" in state:` then `_validate_planner_topology_receipt(...)` (PR #874).
- Lines 364-367: `validate_epic_readiness_integrity(state, text, readiness_context, require_launch_paths=key_gated)` (PR #829).
- Docstring lines 287-294 describe the two existing gates; it does not mention the per-feature receipts.
- **Finding:** the Codex flags reach `validate_epic_planner_state_text` but do **not** reach `_validate_ready_features`; the `key_gated` value is computed at line 332 but not passed at line 342.

### 1.3 TypeScript twin

`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (474 lines):

- `validateReadyFeatures(features: ReadonlyArray<Record<string, unknown>>): string[]` at lines 292-364. It takes no flag parameter.
- Model receipt block, lines 329-354: `validateCodexModelRoutingReceipt(receipt, \`${prefix}.model_routing_receipt\`)`, then the `logical_agent`, `complexity_band`, and `execution_context` checks. The error strings are byte-identical to Python.
- Topology block, lines 355-360: `validateChildTopologyReceipt(feature["topology_receipt"], \`${prefix}.topology_receipt\`)`. The helper is defined at lines 116-127.
- Call site at line 438: `errors.push(...validateReadyFeatures(featureResult.features));`.
- The key-gate value is computed at lines 425-427: `const requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true;`. The name is historical (PR #829). It holds the same value as Python `key_gated` and is used at lines 441, 444, and 467.
- `ValidateEpicPlannerStateOptions` (lines 51-60) already declares `requireCodexModelRouting` and `requireCodexTopology`.

### 1.4 Interaction with the launch-binding validator (relevant to the design)

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:166-202` (`_validate_model_receipt`) validates `feature["model_routing_receipt"]` for every feature that the launch-binding validator does not skip. Under key gating, that means features that carry `launch_receipt_path` or `launch_status_path` (lines 205-208, 231-232). Its error prefix is `Epic planner checkpoint features[i] launch binding` (line 234), so its absent-receipt error is `Epic planner checkpoint features[i] launch binding.model_routing_receipt must be an object.`. The TypeScript port is at `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts:246-263`.

Consequences:

- A launch-keyed (Codex-provenance) feature that omits `model_routing_receipt` still fails without a Codex flag after this change, through the launch-binding check. This is unchanged PR #829 behaviour.
- The substring `model_routing_receipt must be an object` occurs in both the ready-feature error and the launch-binding error. Tests must assert the full `features[i].model_routing_receipt` form (with a dot after `]`) to tell them apart (section 5.1).
- No validator other than `_validate_ready_features` / `validateReadyFeatures` reads the per-feature `topology_receipt`. This was verified by Grep of both production files (section 12) and of the launch-binding module.

---

## 2. Prior #543 Work: Merged versus Deferred

| Change | Folder | Merged scope | Deferred (recorded in that spec) |
|---|---|---|---|
| PR #829 | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` | Added `require_codex_model_routing` / `require_codex_topology` to the Python validator and TS options. Added the `key_gated` / `requireLaunchPaths` activation value, a per-feature key-membership skip for launch bindings and launch evidence, MCP dispatch forwarding, and Codex guidance passing both flags (all ACs `[x]`). | Per-feature `model_routing_receipt` / `topology_receipt` and the top-level planner `topology_receipt` (spec lines 65-69, 351-355). Python CLI Codex flags (lines 64, 356). |
| PR #874 | `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` | Top-level planner `topology_receipt` key-gated with `not key_gated or "topology_receipt" in state` (all ACs `[x]`). | Per-feature receipts, explicitly out of scope (spec line 56; research §3.1 and rejected alternative D). Python CLI flags (line 57). Field-list gap (line 58). PR wording "Partially addresses #543" (line 254). |
| PR #912 | `docs/features/active/2026-10-11-epic-planner-field-list-remainder-543/spec.md` | Added `max_parallel_features` and `research_path` to the Claude `epic-planner.md` field list and its bundled mirror (all ACs `[x]`). | Per-feature receipt gating (line 37). Documenting optional validator fields (line 38, line 165). |

How #829 and #874 framed the gate:

- **One activation value for every Codex-only check in the planner ready gate.** #829 spec line 92 says "the ready gate computes one activation value in each runtime". #874 deliberately reused that same value for the top-level receipt rather than introducing per-flag logic (spec lines 76-79; rejected C).
- **Codex flags make the check unconditional, and "either flag" is enough.** The #829 matrix row "Any feature | yes (either flag)" (line 107). The #874 matrix rows "either flag" (lines 89-90). Both specs' tests parametrize over each single flag and expect unconditional behaviour (#829 AC at line 291; #874 AC at line 224).
- **Presence means key membership, not value truthiness.** #829 line 115; #874 line 96; `.claude/rules/orchestrator-state.md:228`.
- **Codex behaviour unchanged** whenever a flag is asserted (#874 line 97).

---

## 3. Gating Design Decision: Combined Rule versus Per-Flag

### Candidate A: combined rule, reuse `key_gated` (recommended)

Each per-feature check runs when `not key_gated or "<key>" in feature`, with `key_gated = not (require_codex_model_routing or require_codex_topology)`.

- Advantages:
  - It matches the issue's Expected Behavior literally: "When a Codex flag is asserted, the checks remain unconditional" (`issue.md:34`).
  - It matches the operator scope ("consistent with the existing key_gated pattern").
  - It is the same activation used by the other three gates in the same function (lines 345, 348, 366).
  - It is strictly a relaxation of the no-flag case only. Every flagged call, single or double, behaves exactly as today, so PR #829 and PR #874 behaviour is not reopened (`issue.md:51`).
  - It needs no new flag plumbing, because the value already exists in both runtimes.
- Limitations:
  - The model receipt stays required under `require_codex_topology` alone, and the topology receipt stays required under `require_codex_model_routing` alone. This is the current behaviour.

### Candidate B: per-flag gating (rejected)

`model_routing_receipt` would be gated by `require_codex_model_routing` and `topology_receipt` by `require_codex_topology`. This mirrors the epic-orchestrator validator (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:480-489`; `scripts/dev_tools/validate_epic_orchestrator_state.py:422-424`).

- Rejected because:
  - It changes Codex single-flag behaviour. For example, under `require_codex_topology` alone, an absent `model_routing_receipt` would newly pass. That contradicts the issue's "remain unconditional" sentence.
  - It would make this one check behave differently from the launch-binding and planner-topology gates that sit next to it in the same branch.
  - It needs two activation values instead of one.
- It gives no practical benefit to production callers. All Codex ready-gate callers assert both flags: `.agents/skills/epic-plan/SKILL.md:198-200`, `.agents/skills/epic-run/SKILL.md:24-26`, `.codex/agents/epic-orchestrator.toml:42-44`, and their mirrors, pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:407-423`.

### Other rejected alternatives

- **Value test (`feature.get(key) is not None`).** This breaks the key-membership rule and would accept `"model_routing_receipt": null`.
- **Filtering the feature list before the call.** This would renumber `features[i]` prefixes. The #829 invariant is an in-loop skip (#829 spec line 114).
- **Gating the whole `_validate_ready_features` call.** This would also skip `issue_num`, path, `preparation_status`, and `preflight_status` checks, which are not Codex-only.

### Recommendation

Adopt Candidate A, using key membership per receipt key and evaluated per feature, inside the existing loop.

---

## 4. Flag Plumbing (MCP and Python CLI)

| Surface | Status | Evidence |
|---|---|---|
| MCP input mapping | Maps `require_codex_model_routing`, `require_codex_topology`, `require_ready_for_execution` | `extensions/drm-copilot/src/mcp-tool-inputs.ts:462-481` |
| Service-call builder | Forwards all three | `extensions/drm-copilot/src/lib/validate/build-validate-orchestration-service-call-input.ts:50-58`; `extensions/drm-copilot/src/repo-automation-service.ts:395-396` |
| Service call | Forwards to `validateArtifactWithWarnings` | `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts:84-106` |
| Dispatch | `epic-planner-state` case spreads `requireReadyForExecution`, `requireCodexModelRouting`, `requireCodexTopology`, and builds `readinessContext` | `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:315-341` |
| TS core | Options declared; value computed at lines 425-427 | `epic-planner-state-core.ts:51-60` |
| Python core | Keyword args declared | `validate_epic_planner_state.py:279-286` |
| Python CLI | **No Codex flags.** The `epic-planner-state` subparser exposes only `path`, `--workspace-root`, `--require-ready-for-execution` | `scripts/dev_tools/validate_orchestration_artifacts.py:304-315`; dispatch at 434-444 |

**Conclusion:** no plumbing change is required. The value already reaches the function that calls `_validate_ready_features` / `validateReadyFeatures`. Only the call into that function (Python line 342, TS line 438) and its signature change. The Python CLI keeps running in key-gated mode, which is the #829 deferral (`validate_orchestration_artifacts.py` is outside scope). After this change the CLI therefore also skips absent per-feature receipts, which is the intended Claude-runtime behaviour. `test_cli_dispatches_planner_readiness_flag` (`tests/scripts/dev_tools/test_validate_epic_planner_state.py:393-424`) stubs the validator and is unaffected.

---

## 5. Tests

### 5.1 Existing tests that assert the current per-feature behaviour

Python, `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (424 lines; fixture builders `_feature` lines 24-61 and `_ready_state` lines 64-84; every feature carries both receipts and both launch keys):

| Test | Lines | Effect of the change | Action |
|---|---|---|---|
| `test_readiness_requires_resolved_child_model_receipt` | 176-188 | It pops `features[0].model_routing_receipt` with **no** Codex flag. After the change the ready-feature error disappears, but the assertion `"model_routing_receipt must be an object" in error` **still passes** because the launch-binding error `features[0] launch binding.model_routing_receipt must be an object.` matches the same substring (§1.4). The test would keep passing while pinning a different check. | **Update:** pass `require_codex_model_routing=True` (or `require_codex_topology=True`). Tighten the assertion to the exact `"Epic planner checkpoint features[0].model_routing_receipt must be an object." in errors`. |
| `test_readiness_requires_epic_preparation_topology_receipts` | 213-234 | Already passes `require_codex_topology=True`, so the per-feature topology check stays unconditional. | None (passes unchanged). |
| `test_readiness_cross_binds_feature_complexity_and_model_context` | 191-210 | Keys present; validated. | None. |
| `test_ready_checkpoint_passes_execution_readiness` | 87-94 | Keys present, all valid. | None. |

TypeScript, `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` (490 lines; builders `topologyReceipt` 7-15, `modelReceipt` 17-33, `feature` 35-66, `readyState` 68-83, `codexFlagCases` 90-93):

| Test | Lines | Effect | Action |
|---|---|---|---|
| `reports every unresolved or incomplete ready-feature field` | 260-296 | Uses `model_routing_receipt: null`. The key is present, so it is still validated. | None. |
| `requires canonical orchestrator routing receipts` | 298-322 | Receipt present. | None. |
| `cross-binds feature complexity and epic preparation model context` | 324-344 | Present. | None. |
| `requires each prepared child to route through an orchestrator` | 425-443 | Present. | None. |

No TypeScript test removes a per-feature receipt key.

`extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (232 lines), `it("threads the Codex flags into epic-planner-state")` (lines 160-212). Its feature has **no** receipts and no launch keys. Current assertions do not reference per-feature receipts, so it passes before and after. It is the natural place to add the MCP-level assertions (section 7).

Verified unaffected, because every fixture carries both per-feature receipts or the test does not reach the ready gate:

- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` (396 lines; `_feature` 36-70 keeps both receipts; `_strip_launch_binding` 29-33 removes only launch keys)
- `tests/scripts/dev_tools/test_epic_planner_readiness.py` (fixture lines 150-153, 179)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` (343 lines; fixture 55-91)
- `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` (fixture 175-199)
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts:240-256` (text `"{}"` / `"[]"`; asserts only `next_step` / root shape)
- `extensions/drm-copilot/test/mcp-server-epic-validation.test.ts:83-112` (service mocked)
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:397-404` (asserts that `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` appear after `if require_ready_for_execution:`; both literals are preserved by the recommended design)

### 5.2 Shared corpus or parity fixtures

There is no shared Python/TypeScript corpus or automated execution-parity test for the epic-planner validator. Each runtime builds its own in-memory fixtures. Parity is maintained by twin tests that assert byte-identical error strings, as in #829 and #874.

Python receipts come from `resolve_codex_deployment` / `resolve_codex_topology`. TypeScript uses a literal `modelReceipt` plus `resolveCodexTopology` (`extensions/drm-copilot/src/lib/validate/codex-topology-resolver`).

The test-support modules `tests/scripts/dev_tools/epic_planner_launch_evidence_test_support.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence-test-support.ts` cover launch evidence only.

---

## 6. Bundled Mirrors and Documentation

- **No bundled copy of either validator exists.** Glob `**/{validate_epic_planner_state.py,epic-planner-state-core.*}` returned only the two production files and the TS test. Grep for `_validate_ready_features|validateReadyFeatures` outside `docs/` matched only the two production files. There is no PowerShell twin: Grep for `Epic planner checkpoint` matched only Python and TS sources and tests.
- `.claude/rules/orchestrator-state.md:218-232` ("Epic Launch-Binding Activation Scope") covers the epic-orchestrator gate only and does not describe the planner per-feature receipts. **No drift.**
- `.claude/rules/` and `.github/instructions/`: Grep for planner per-feature receipt requirements found none. **No drift finding.**
- `.claude/agents/epic-planner.md:106-110` (Claude field list) lists no per-feature receipts. After the change this is consistent, because the receipts become optional without a Codex flag. **No edit required.**
- Codex guidance describes Codex-runtime obligations that remain accurate, because Codex callers assert both flags and stay unconditional:
  - `.agents/skills/epic-plan/SKILL.md:89-91, 191-193, 237-240`
  - `.codex/agents/epic-planner.toml:48-49, 73-75, 84`
  - their mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/`

  **No edit required.**
- The MCP tool descriptions (`extensions/drm-copilot/src/mcp-tool-definitions.ts:440-454`, and the twin in `mcp-repo-automation-tool-definitions.ts:385-399`) say nothing about planner per-feature receipts. **No edit required.**
- **In-file text that becomes inaccurate and must be updated:**
  - the Python docstring at `validate_epic_planner_state.py:287-294`
  - the comments at Python lines 330-331 and TS lines 423-424, which list only launch evidence and the planner receipt as key-gated
  - the `_validate_ready_features` / `validateReadyFeatures` docstrings, which should mention the key gate

---

## 7. Proposed Design and File Changes

### 7.1 Behaviour semantics (under `require_ready_for_execution=True`)

| Codex flag | Per-feature key state | Model-receipt block | Topology block |
|---|---|---|---|
| none | key absent | skipped, zero errors | skipped, zero errors |
| none | present, valid | zero errors | zero errors |
| none | present, `null` | `...features[i].model_routing_receipt must be an object.` | `...features[i].topology_receipt must be an object.` |
| none | present, wrong field | existing field errors (unchanged) | existing field errors (unchanged) |
| either flag | absent | `... must be an object.` (unchanged) | `... must be an object.` (unchanged) |
| either flag | present | validated in full (unchanged) | validated in full (unchanged) |

- Each key is gated independently. A feature carrying only `model_routing_receipt` has that receipt validated and its topology check skipped, and the reverse also holds.
- Error indices are preserved because the skip happens inside the loop.
- Without `require_ready_for_execution`, nothing changes.
- No error string is added, removed, or reworded.
- Error ordering within a feature is unchanged: model-receipt errors, then topology errors.

Resulting end-to-end property: a Claude-shaped ready checkpoint has no launch keys, no per-feature receipts, and no top-level `topology_receipt`. Validated with no Codex flag and no readiness context, it yields exactly `["Execution-ready planner validation requires repository context."]`. This is the #543 end-to-end outcome, so the PR can state "Closes #543".

### 7.2 Python (`scripts/dev_tools/validate_epic_planner_state.py`)

1. Extract lines 241-269 into a helper `_validate_feature_model_receipt(feature: dict[str, Any], *, prefix: str) -> list[str]` with an identical body and error order. This is required, not cosmetic: wrapping the block in another `if` adds 4 columns, and line 256 (`f"{prefix}.model_routing_receipt.logical_agent must be 'orchestrator'."`, 87 columns at its current 16-space indent) would reach 91 columns. That exceeds `line-length = 88` (`pyproject.toml:89`), and ruff `E` is selected (`pyproject.toml:95`), so E501 would fail.
2. Change the signature to `_validate_ready_features(features: list[dict[str, Any]], *, key_gated: bool = False) -> list[str]`. The keyword-only default `False` preserves unconditional behaviour for any direct caller.
3. In the loop:
   ```python
   if not key_gated or "model_routing_receipt" in feature:
       errors.extend(_validate_feature_model_receipt(feature, prefix=prefix))
   if not key_gated or "topology_receipt" in feature:
       errors.extend(_validate_child_topology_receipt(feature.get("topology_receipt"), prefix=f"{prefix}.topology_receipt"))
   ```
   (black will wrap the second call.)
4. Line 342: `errors.extend(_validate_ready_features(features, key_gated=key_gated))`.
5. Update the comment at lines 330-331 and the docstring at lines 287-294 to name the per-feature receipts.
6. The `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` literals stay untouched.
7. Estimated size after the change: about 385-390 lines (limit 500).

### 7.3 TypeScript (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`)

1. Change the signature to `validateReadyFeatures(features: ReadonlyArray<Record<string, unknown>>, keyGated: boolean): string[]`.
2. Wrap lines 329-354 in `if (!keyGated || "model_routing_receipt" in feature) { ... }` and lines 355-360 in `if (!keyGated || "topology_receipt" in feature) { ... }`. In-place wrapping is preferred here to save lines. ESLint has no `max-len` rule (no match in `extensions/drm-copilot/eslint.config.*`), and Prettier does not split template literals.
3. Line 438: `errors.push(...validateReadyFeatures(featureResult.features, requireLaunchPaths));`. Prettier will wrap this to 3 lines.
4. Do not rename `requireLaunchPaths`. This matches the #874 decision and keeps the diff small. Update the comment at lines 423-424 to name the per-feature receipts.
5. **Line budget:** 474 lines now. The estimate is +1 (signature), +4 (two `if` wrappers), +2 (call-site wrap), +1 to +2 (comment/doc), giving about 482-484 lines.
   - If Prettier output exceeds 500, extract the model-receipt block into `validateFeatureModelReceipt(feature, prefix)` in the same file, or move both ready-feature helpers into a new module `extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts`.
   - A new module needs a mirrored test location and falls under the existing T3 classification.
   - The executor must verify the count after Prettier.

### 7.4 Full list of files to change

Production:
- `scripts/dev_tools/validate_epic_planner_state.py`
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`

Tests:
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`: in-place update of `test_readiness_requires_resolved_child_model_receipt` only (section 5.1).
- **New** `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`. The existing file is at 424 lines, and five or more new tests at about 15 lines each would reach the 500 limit. This follows the precedent of `test_validate_epic_planner_state_launch_binding.py` and uses its own `_feature` / `_state` builders.
- **New** `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`. The existing core test is at 490 lines with no headroom. This follows the precedent of `epic-planner-state-launch-binding.test.ts`. `jest.config.cjs:4` `testMatch: ["**/test/**/*.test.ts"]` picks it up without configuration.
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (232 lines): extend `threads the Codex flags into epic-planner-state`.

Not changed:
- `scripts/dev_tools/validate_orchestration_artifacts.py`, the MCP input, definition, and dispatch files, and `jest.config.cjs`
- `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`, and `extensions/drm-copilot/resources/**`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`

---

## 8. Test Strategy (proposals; names are suggestions)

Python, in the new `test_validate_epic_planner_state_feature_receipts.py`:

1. `test_ready_gate_skips_feature_receipts_when_keys_absent` (**regression; must fail before the fix**). Build a Claude-shaped ready state: remove both receipts and all five launch-binding keys from every feature, and remove the top-level `topology_receipt`. Validate with `require_ready_for_execution=True` and no flag. Assert `errors == ["Execution-ready planner validation requires repository context."]`.
2. `test_codex_flag_keeps_feature_receipts_unconditional`, parametrized over `require_codex_model_routing` and `require_codex_topology`. With both receipts removed from `features[0]`, assert both `"Epic planner checkpoint features[0].model_routing_receipt must be an object."` and `"Epic planner checkpoint features[0].topology_receipt must be an object."` are in the errors. This pins the combined rule.
3. `test_ready_gate_validates_present_null_feature_receipt`, parametrized over the two keys. Set the key to `None` with no flag and assert the exact `must be an object.` string. This pins key membership.
4. `test_ready_gate_gates_each_feature_receipt_independently`. Remove `topology_receipt` and set `model_routing_receipt.logical_agent` to a wrong value with no flag. Assert the `logical_agent must be 'orchestrator'.` error is present and that no error contains `features[0].topology_receipt`.
5. `test_ready_gate_preserves_feature_index_when_receipts_skipped`. Make `features[0]` receipt-less and give `features[1]` a `None` topology receipt. Assert the error is prefixed `Epic planner checkpoint features[1].topology_receipt`.

TypeScript, in the new `epic-planner-state-feature-receipts.test.ts`: twins of tests 1-5 with byte-identical strings, using `it.each` for the parametrized cases.

MCP integration, extending `threads the Codex flags into epic-planner-state`:
- `routing` and `topology` each contain `features[0].model_routing_receipt must be an object.` and `features[0].topology_receipt must be an object.`
- `keyGated` contains neither `features[0].model_routing_receipt` nor `features[0].topology_receipt`. The dotted form avoids matching ` launch binding.model_routing_receipt`. The fixture has no launch keys, so no launch-binding receipt error arises in any case.

Every test uses in-memory JSON with no temporary files, clock, or network. Tests follow Arrange-Act-Assert with docstrings or descriptive names.

---

## 9. File Sizes (current, from Read line counts)

| File | Lines now | Expected after |
|---|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | 375 | about 385-390 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 474 | about 482-484 (verify after Prettier; see §7.3 contingency) |
| `tests/scripts/dev_tools/test_validate_epic_planner_state.py` | 424 | about 425 |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` | 490 | unchanged (no headroom) |
| `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` | 232 | about 245 |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | 396 | unchanged |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` | 343 | unchanged |
| new Python test file | 0 | about 150 |
| new TS test file | 0 | about 170 |

---

## 10. Toolchain Commands

Python, from the worktree root (`pyproject.toml`: black and ruff line length 88, ruff `E,F,I,B,UP,S,TID,TCH`, pyright strict):

```
poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing
```

`--cov` must use the dotted module name; a `.py` path measures nothing. `pyproject.toml:116` adds `--cov-report=lcov:artifacts/python/lcov.info` automatically.

TypeScript, from `extensions/drm-copilot/` (`package.json:207-213`):

```
npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts
npm run lint          # eslint --no-error-on-unmatched-pattern src test
npm run typecheck     # tsc -p ./ --noEmit && tsc -p tsconfig.jest.json --noEmit
node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts
node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
```

`jest.config.cjs` has no per-file `coverageThreshold` entry for `epic-planner-state-core.ts`; only `orchestration-artifacts.ts` has one, at line 119. Coverage for the changed file is read from the `text` reporter row. The extension has no dependency-cruiser configuration (Grep of `package.json` and `jest.config.cjs`), so the architecture stage has no tool for these files.

Evidence paths go under `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/<kind>/` (`baseline/`, `regression-testing/`, `qa-gates/`).

---

## 11. Quality-Tier Classification

From `quality-tiers.yml`:

- `scripts/dev_tools` is **T4** (lines 16-18). It covers `validate_epic_planner_state.py` and the Python tests.
- `extensions/drm-copilot` is **T3** (lines 7-9). It covers `epic-planner-state-core.ts` and the TS tests.
- Uniform gates apply: line coverage >= 85% and branch coverage >= 75% (pytest-cov and Jest both measure branches), no changed-line regression, 0 lint and type errors.
- Tier-dependent gates: T3 allows <= 5 justified `any` per file, and no property tests or mutation tests are required for T3/T4.
- No new project is added, so no tier-file edit is needed.

---

## 12. Numeric Derivation Evidence

Claim: the per-feature receipt checks have exactly **one** production call path per runtime (2 call sites total), and exactly **4** per-feature receipt reads (2 per runtime), all inside the ready-feature function.

- **Complete Family:** production definitions and call sites of the ready-feature validator, plus per-feature reads of `model_routing_receipt` / `topology_receipt` in the epic-planner validator files.
- **Exhaustive Search Scope:** `scripts/**`, `extensions/drm-copilot/src/**`, `tests/**`, `extensions/drm-copilot/test/**`, `.claude/**`, `.codex/**`, `.agents/**`, `extensions/drm-copilot/resources/**`.
- **Inclusion Rules:** function definitions and invocations of `_validate_ready_features` / `validateReadyFeatures`; feature-scoped reads of either receipt key in `validate_epic_planner_state.py` and `epic-planner-state-core.ts`.
- **Exclusion Rules:** `docs/**` (historical records); top-level `state`/`value` reads of `topology_receipt`; error-string literals; import lines; the launch-binding module's `_validate_model_receipt` (a separate, already key-gated check per §1.4).
- **Primary Search Strategy:** Grep `_validate_ready_features|validateReadyFeatures` over the full scope.
- **Primary Member Set:** `validate_epic_planner_state.py:222` (def), `:342` (call); `epic-planner-state-core.ts:292` (def), `:438` (call).
- **Primary Count:** 2 call sites (plus 2 definitions).
- **Cross-check Search Strategy:** Grep `(model_routing_receipt|topology_receipt)` restricted to the two production files, then classification of each match by enclosing function from a full Read of both files.
- **Cross-check Member Set:**
  - Feature-scoped reads: Python `:241` (`feature.get("model_routing_receipt")`) and `:272` (`feature.get("topology_receipt")`); TS `:329` (`feature["model_routing_receipt"]`) and `:357` (`feature["topology_receipt"]`). All four lie inside the function bodies at Python 222-276 and TS 292-364.
  - Each enclosing function is invoked only from Python `:342` and TS `:438`.
- **Cross-check Count:** 4 feature-scoped reads, inside 2 functions with 2 call sites.
- **Member-set Comparison:** the call sites from the primary set (Python `:342`, TS `:438`) equal the invocation sites of the functions enclosing the cross-check reads. The sets agree.

No numeric acceptance criterion beyond this is proposed.

---

## 13. Automation Feasibility

- Every step can be automated with no human interaction:
  - in-place edits to two production files and two existing test files
  - two new test files
  - Poetry and npm toolchain runs
- No secret, network service, GitHub mutation, or interactive prompt is needed before the PR stage.
- Pester is not required: no `.ps1`, guidance, or mirror file changes.
- Known environment constraints from earlier sessions:
  - Agent worktrees may deny commands whose text contains `bash`/`pwsh`/`wsl`. Use `poetry run ...` and `node run-jest.cjs ...` directly.
  - Multi-line `poetry run python -c` is a silent no-op. Do not use it for evidence capture.
  - `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally on gitignored state (issue #510). Deselect it in full-suite runs, as the #874 spec did, and rely on CI for it.
- Regression-first ordering is feasible. Test 1 (§8) fails on the current tree, because the current code emits `features[i].model_routing_receipt must be an object.` and `features[i].topology_receipt must be an object.` for each feature. It passes after the fix.

---

## 14. Risks and Mitigations

- **Risk: a Codex caller omits both flags, so absent per-feature receipts are skipped.**
  - Mitigation: all Codex ready-gate callers assert both flags, pinned by `test_push_down_codex_and_agents_customizations.py:407-423`.
  - Mitigation: launch-keyed features still require `model_routing_receipt` through the launch-binding check (§1.4).
  - Residual: under the no-flag mode, a launch-keyed feature's `topology_receipt` is no longer required.
- **Risk: a test keeps passing on a different check** (`model_routing_receipt must be an object` substring overlap).
  - Mitigation: use exact or dotted-form assertions (§5.1, §8).
- **Risk: `epic-planner-state-core.ts` crosses 500 lines.**
  - Mitigation: verify after Prettier; use the extraction contingency in §7.3.
- **Risk: Python E501 from deeper nesting.**
  - Mitigation: extract the helper (§7.2 step 1).
- **Risk: the Python and TS runtimes diverge.**
  - Mitigation: twin tests with byte-identical strings, and an identical gating predicate in both runtimes.
- **Rollback:** revert the change set. Callers that need the previous behaviour can assert either Codex flag.
