# Research: epic-planner ready gate demands a Codex-only planner topology receipt (Issue #543, residual scope)

- Timestamp: 2026-10-08T14-00
- Issue: #543 (work mode `full-bug`)
- Branch: `bug/epic-planner-topology-receipt-gate-543`
- Feature folder: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/`
- Precedent (context only): `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/` (PR #829, merge commit 869c4fad)
- Method: file read and search tools only. No shell command (git, pytest, jest, black, prettier) was executed in this session. Baseline pass/fail state was **not observed**. All line citations were derived from the current worktree tree.

---

## 1. Current State Analysis

### 1.1 Python planner topology-receipt check and call site

`scripts/dev_tools/validate_epic_planner_state.py` (369 lines):

- Definition, lines 62-86, `_validate_planner_topology_receipt(value: object) -> list[str]`:
  - Lines 65-70 run `validate_codex_topology_receipts([value])` and rewrite the prefix `"Checkpoint codex_topology_receipts[0]"` to `"Epic planner topology_receipt"`.
  - Lines 71-72 return early when `value` is not a `dict`.
  - Lines 74-85 compare five fields against the forced planner receipt: `execution_context == "standalone"`, `root_persona == "epic-planner"`, `route == "epic"`, `topology == "epic_persona"`, `logical_agent == "epic-planner"`. Each mismatch appends `f"Epic planner topology_receipt.{key} must be {expected_value!r}."`.
- Call site, line 345, inside `if require_ready_for_execution:` (line 327):

  ```python
  errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))
  ```

  The call is not conditioned on `key_gated` (line 329) or on any key test.
- Error for an absent key: `state.get("topology_receipt")` returns `None`. `validate_codex_topology_receipts([None])` (`scripts/dev_tools/_orchestrator_state_codex_topology.py:94-98`) appends `"Checkpoint codex_topology_receipts[0] must be an object."`. After the prefix rewrite and the early return at line 72, the result is exactly one error:

  `Epic planner topology_receipt must be an object.`

### 1.2 TypeScript parity port and call site

`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (471 lines):

- Helper, lines 83-100, `validateExpectedTopologyFields(value, prefix, expected)`. It calls `validateCodexTopologyReceipt(value, prefix)`, returns early when `!isObject(value)`, and then appends `${prefix}.${key} must be ${repr}.` per mismatch.
- Definition, lines 102-114, `validatePlannerTopologyReceipt(value: unknown)`. It uses the prefix `"Epic planner topology_receipt"` and the same five expected fields as Python.
- Call site, line 443, inside `if (options.requireReadyForExecution === true)` (line 422):

  ```ts
  errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"]));
  ```

  The call is not conditioned on `requireLaunchPaths` (lines 424-426) or on any key test.
- Error for an absent key: `value["topology_receipt"]` is `undefined`. `validateReceipt` (`extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts:116-118`) returns `[`${prefix} must be an object.`]`, and `validateExpectedTopologyFields` returns early at line 89. The result is exactly one error, byte-identical to Python:

  `Epic planner topology_receipt must be an object.`

### 1.3 What a Claude-prepared checkpoint carries

The Claude `epic-planner` checkpoint contract (`.claude/agents/epic-planner.md:106-110`) lists:

- Top level: `objective`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `epic_issue_num`, `epic_worthiness`, `features[]`, `kickoff_prompt_path`, `completed_steps`, `next_step`, `last_updated`.
- Per feature: `issue_num`, `feature_folder`, `depends_on`, `wave`, `complexity_band`, `preparation_status`, `plan_path`, `preflight_status`.

The contract lists no top-level `topology_receipt`, no per-feature `topology_receipt`, no per-feature `model_routing_receipt`, and no launch keys. `.claude/skills/epic-plan/SKILL.md:220-221` defers to the same field list.

---

## 2. PR #829 Key-Gating Semantics and the Equivalent Rule (Q2)

PR #829 used these semantics:

- `key_gated = not (require_codex_model_routing or require_codex_topology)` at `validate_epic_planner_state.py:329`. The TS equivalent is `requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` at `epic-planner-state-core.ts:424-426`.
- The value is passed as `require_launch_paths=key_gated` to `validate_epic_planner_child_launch_bindings` (line 342) and to `validate_epic_readiness_integrity` (line 360). In TS it is passed as `{ requireLaunchPaths }` at lines 439-441 and 464.
- The presence predicate is key membership. Python uses `feature_carries_launch_path` (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:205-208`): `"launch_receipt_path" in feature or "launch_status_path" in feature`. TS uses `featureCarriesLaunchPath` (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts:235-239`), which applies the same `in` test.
- Skip rule: `if require_launch_paths and not feature_carries_launch_path(feature): continue` (`_epic_orchestrator_state_launch_binding.py:231-232`; `epic_planner_launch_evidence.py:324-325`).
- The behaviour matrix is:
  - Codex flag asserted: validate unconditionally.
  - No Codex flag, key present (including an empty or null value): validate in full.
  - No Codex flag, key absent: skip, with zero errors.
- The present-with-null case is pinned by `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py:220-237` (`test_ready_gate_validates_feature_with_empty_launch_path_value`, parametrized over `""` and `None`).
- The prose authority is `.claude/rules/orchestrator-state.md:197`: "Presence means key membership, not value truthiness: a key present with an empty or null value still arms the gate."

**Recommended equivalent for the top-level `topology_receipt` key:** use key membership on the parsed state mapping, not a `None`/`undefined` value test.

- Python: `if not key_gated or "topology_receipt" in state:`, then call `_validate_planner_topology_receipt(state.get("topology_receipt"))`.
- TS: `if (!requireLaunchPaths || "topology_receipt" in value) { errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"])); }`.
- Under JSON parsing, `{"topology_receipt": null}` yields a key that is present in both runtimes (Python `dict`, TS object with an own property). That case is validated and yields `Epic planner topology_receipt must be an object.`, which matches the #829 rule that a present-but-null key arms the gate.

---

## 3. Remaining Unconditional Demands (Q3)

### 3.1 Per-feature receipts in `_validate_ready_features`: unconditional, still blocking

Python, `scripts/dev_tools/validate_epic_planner_state.py:222-276`, is called at line 339 under the ready gate with no flag parameter:

- Lines 241-249 run `validate_codex_model_routing_receipts([feature.get("model_routing_receipt")])` for every feature. An absent receipt yields `Epic planner checkpoint features[i].model_routing_receipt must be an object.` (`scripts/dev_tools/_orchestrator_state_codex_model_routing.py:80`, with the prefix rewritten).
- Lines 270-275 call `_validate_child_topology_receipt(feature.get("topology_receipt"), prefix=...)` for every feature. An absent receipt yields `Epic planner checkpoint features[i].topology_receipt must be an object.`

TS, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:292-364`, is called at line 437 with no options:

- Lines 329-335: `validateCodexModelRoutingReceipt(receipt, ...)`. An absent receipt yields `... must be an object.` (`orchestrator-state-codex-model-routing.ts:282`).
- Lines 355-360: `validateChildTopologyReceipt(feature["topology_receipt"], ...)`.

**Finding:** these per-feature checks are unconditional. After the planner-level fix, they still block a Claude-prepared checkpoint under `require_ready_for_execution`, emitting two errors per feature. The issue #543 residual scope (the issue.md "Summary" and "Suspected Cause" sections, and spec.md "Context") names only the planner-level check, so the per-feature checks are **out of scope** for this fix. The PR #829 research §1.3 and §9 recorded the same items for a follow-up. A follow-up issue is still required before a Claude-prepared checkpoint can pass the ready gate end to end.

### 3.2 Structural-mode gaps in the Claude contract (observation, out of scope)

These checks run without `require_ready_for_execution`:

- `REQUIRED_KEYS` (`validate_epic_planner_state.py:34-46`) includes `max_parallel_features`, which is absent from the Claude field list at `.claude/agents/epic-planner.md:106-110`.
- `REQUIRED_FEATURE_KEYS` (lines 47-57) includes `research_path`, which is also absent from that list.

If a Claude checkpoint follows the documented field list literally, it fails structural validation with `missing required key: max_parallel_features` and `missing required keys: research_path`. Whether the #770/#771 checkpoints actually omitted these keys was **not verified**; the issue evidence reports only topology-receipt errors. This is recorded as a follow-up observation only.

### 3.3 Readiness integrity and launch evidence

- `scripts/dev_tools/epic_planner_readiness.py` contains no `topology` or `model_routing_receipt` reference (Grep count 0). Its only launch-related call is `validate_epic_planner_launch_evidence(state, context, require_launch_paths=require_launch_paths)` (lines 363-364), which is already key-gated by #829.
- `scripts/dev_tools/epic_planner_launch_evidence.py:92` reads `model_routing_receipt` only inside `_expected_feature_bindings`. That code runs only for features that pass the key-gated skip at lines 324-325.
- `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` and every other `epic-planner-*.ts` module have no `topology` reference (Grep over `src/lib/validate/epic-planner-*.ts`: matches only in `epic-planner-state-core.ts`).

**Finding:** there is no other unconditional topology-receipt demand outside `epic-planner-state-core.ts` / `validate_epic_planner_state.py`.

---

## 4. Flag Plumbing (Q4)

| Surface | Passes Codex flags to the planner validator? | Evidence |
|---|---|---|
| Python CLI `validate_orchestration_artifacts.py` | **No.** The `epic-planner-state` subparser (lines 301-312) exposes only `path`, `--workspace-root`, and `--require-ready-for-execution`. Dispatch (lines 431-441) passes only `require_ready_for_execution` and `readiness_context`. | Deliberate deferral recorded by PR #829 (file is 495 lines). The CLI therefore always runs in key-gated (Claude) mode. |
| MCP input mapping | Yes | `extensions/drm-copilot/src/mcp-tool-inputs.ts:462-481` maps `require_codex_model_routing`, `require_codex_topology`, and `require_ready_for_execution`. |
| Service call | Yes | `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts:93-101`; `build-validate-orchestration-service-call-input.ts:50-58`. |
| Dispatch to core | Yes | `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:315-341` spreads `requireReadyForExecution`, `requireCodexModelRouting`, and `requireCodexTopology` into `ValidateEpicPlannerStateOptions`, then calls `validateEpicPlannerStateText`. |
| Python core signature | Yes | `validate_epic_planner_state_text(..., require_codex_model_routing=False, require_codex_topology=False)` at lines 279-286. |
| TS core options | Yes | `ValidateEpicPlannerStateOptions.requireCodexModelRouting` / `requireCodexTopology` at lines 57-59. |

End-to-end TS threading is already proven by `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts:160-205` (`threads the Codex flags into epic-planner-state`).

**Conclusion:** no plumbing change is needed. The fix is confined to the two call sites, lines 345 (Python) and 443 (TS).

Codex callers already assert both flags, so the topology check stays unconditional for them after the fix:

- `.agents/skills/epic-plan/SKILL.md:183-185`
- `.agents/skills/epic-run/SKILL.md:24-26`
- `.codex/agents/epic-orchestrator.toml:42-44`
- The byte-identical mirrors of all three under `extensions/drm-copilot/resources/codex-and-agents-customizations/` (same lines)

These are pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:407-423`.

---

## 5. Candidate Approaches

### A. Key-gate the call site on the existing `key_gated` / `requireLaunchPaths` value plus key membership (Recommended)

Python, at the call site replacing line 345:

```python
if not key_gated or "topology_receipt" in state:
    errors.extend(
        _validate_planner_topology_receipt(state.get("topology_receipt"))
    )
```

TS, replacing line 443:

```ts
if (!requireLaunchPaths || "topology_receipt" in value) {
  errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"]));
}
```

Also update the comments at Python line 328 and TS line 423, and the Python docstring at lines 289-291, so they state that the planner topology receipt is key-gated under the same rule.

- Advantages: a two-site change that reuses the #829 predicate and its key-membership semantics. It adds no error strings and changes no signatures. Codex callers are unaffected because they assert both flags.
- Limitations: the local name `key_gated` / `requireLaunchPaths` now also governs a non-launch check. A comment update is sufficient. A rename (for example, TS `requireLaunchPaths` to `keyGated`) is optional and enlarges the diff.

### Rejected alternatives

- **B. Value test (`state.get("topology_receipt") is not None`).** This diverges from the #829 key-membership rule (`.claude/rules/orchestrator-state.md:197`) and would silently accept `"topology_receipt": null`.
- **C. Push the gate into `_validate_planner_topology_receipt` with a `required` parameter.** This changes a helper signature in both runtimes for no behavioural gain. The call-site gate matches how #829 conditioned its calls.
- **D. Also key-gate the per-feature `model_routing_receipt` / `topology_receipt` checks.** This is outside the stated residual scope (§3.1) and needs its own spec decision, so it is recorded for a follow-up issue.

---

## 6. Behaviour Semantics (target)

Under `require_ready_for_execution=True`:

| Codex flag | Top-level `topology_receipt` | Planner topology result |
|---|---|---|
| none | key absent | skipped; zero `Epic planner topology_receipt` errors |
| none | present, valid forced receipt | zero errors |
| none | present, `null` | `Epic planner topology_receipt must be an object.` |
| none | present, wrong field (e.g. `root_persona`) | existing field errors (unchanged) |
| either flag | key absent | `Epic planner topology_receipt must be an object.` (unchanged) |
| either flag | present | validated in full (unchanged) |

Without `require_ready_for_execution`, nothing changes, because the check never ran in that mode. No error string is added, removed, or reworded in either runtime.

Remaining errors for a Claude-shaped checkpoint after this fix (out of scope, §3.1): two per feature, `features[i].model_routing_receipt must be an object.` and `features[i].topology_receipt must be an object.`

---

## 7. Tests (Q5)

### 7.1 Existing tests that pin the defect (must change)

- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_epic_preparation_topology_receipts` (lines 213-234). It pops the top-level `topology_receipt` (line 217) and, with no Codex flag, asserts `"Epic planner topology_receipt must be an object"` (lines 225-227). **This test fails after the fix.**
  - Update: pass `require_codex_topology=True` for the top-level assertion, or split the test. The per-feature assertions at lines 228-234 remain valid in either mode. Because the fixture carries launch keys, a Codex flag adds no launch errors, and the assertions use `any(...)`.

No TypeScript test asserts the absent-key planner error:

- Grep `Epic planner topology_receipt` under `extensions/drm-copilot/test` matched only `epic-planner-state-core.test.ts:341,344`. That test (`requires the forced epic-planner topology receipt`, lines 330-346) supplies a present receipt with a wrong `logical_agent`, so it remains valid under key gating.

### 7.2 Existing tests expected to be unaffected

Every fixture below carries a top-level `topology_receipt`:

- Python: `test_validate_epic_planner_state.py:83`, `test_validate_epic_planner_state_launch_binding.py:92`, `test_epic_planner_readiness.py:179`, including `test_readiness_requires_forced_epic_planner_persona` (lines 237-251, present receipt, no flag).
- TS: `epic-planner-state-core.test.ts:80`, `epic-planner-state-launch-binding.test.ts:91`, `epic-planner-readiness-integrity.test.ts:199`.
- `validate-orchestration-service-call.test.ts::threads the Codex flags into epic-planner-state` (lines 160-205). Its fixture has no top-level `topology_receipt`, and its key-gated assertion only excludes `" launch binding"`, so it passes before and after.
- `test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` (lines 368-404). It asserts that `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` appear after `if require_ready_for_execution:`. Both literals are untouched by Approach A.
- `test_validate_epic_planner_state.py::test_cli_dispatches_planner_readiness_flag` (lines 329-360) is unaffected because the CLI is unchanged.

### 7.3 Proposed new tests (names are proposals)

Python, in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (360 lines; about 60 lines of headroom are needed):

- `test_ready_gate_skips_planner_topology_receipt_when_key_absent`: pop the top-level key, call without a flag, and assert no error contains `"Epic planner topology_receipt"`. This is the **regression-first** test and must fail before the fix.
- `test_codex_flag_keeps_planner_topology_receipt_unconditional`: parametrize over `require_codex_model_routing` and `require_codex_topology`, pop the key, and assert that `"Epic planner topology_receipt must be an object."` is in the errors.
- `test_ready_gate_validates_present_null_planner_topology_receipt`: set the key to `None` with no flag and assert the same error, to pin key-membership semantics.
- The present-invalid, no-flag case is already covered by `test_readiness_requires_forced_epic_planner_persona`.

TypeScript, in `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` (413 lines):

- Add three twins of the Python tests above, with byte-identical error strings: key absent and key-gated; Codex flag with the key absent (`it.each` over both flags); present `null`.

TypeScript, in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (225 lines):

- Extend `threads the Codex flags into epic-planner-state` with `expect(routing).toContain("Epic planner topology_receipt must be an object.")`, the same for `topology`, and `expect(keyGated).not.toContain("Epic planner topology_receipt")`. This covers the issue's MCP integration scenario. The substring `Epic planner topology_receipt` does not occur inside the per-feature prefix `Epic planner checkpoint features[0].topology_receipt`, so the negative assertion is unambiguous.

Policy notes: tests are pure in-memory JSON with no temporary files, clock, or network. Each test needs a docstring or descriptive name and the Arrange-Act-Assert layout.

---

## 8. Bundled Mirrors and Guidance (Q6)

- Production files: Glob `**/{validate_epic_planner_state.py,epic-planner-state-core.ts,epic-planner-state-core.js}` returned only `scripts/dev_tools/validate_epic_planner_state.py` and `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`. **No bundled copy exists.**
- Grep `topology_receipt|validate_epic_planner_state|epic-planner-state-core` under `extensions/drm-copilot/resources` found no copy of either validator. The matches are Codex routing config, PowerShell `codex_topology_receipts` modules, the parallel-planner guidance, and the epic-plan skill mirror described below.
- Guidance that mentions the planner topology receipt:
  - `.agents/skills/epic-plan/SKILL.md:175-177` ("the checkpoint has a forced `epic-planner` topology receipt") and `:222` ("forced root `topology_receipt`").
  - The byte-identical mirror at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md` (same lines).
  - `.agents/skills/epic-run/SKILL.md` and `.codex/agents/epic-orchestrator.toml` mention only the Codex flags (lines 24-26 and 42-44), not the receipt itself.
  - `.codex/agents/epic-planner.toml:48` mentions only per-child topology receipts.
- **Finding:** all of this guidance describes Codex-runtime obligations, and every Codex ready-gate invocation already asserts both Codex flags (§4). Under Approach A, Codex behaviour is unchanged, so **no guidance, mirror, or push-down contract test update is required**.
- `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/epic-run/` contain no `topology_receipt` text and no `epic-planner-state` validator invocation. The `epic-planner-state` matches are checkpoint-path references at lines 155 and 220 only.
- `.claude/rules/orchestrator-state.md:187-201` ("Epic Launch-Binding Activation Scope") covers the epic-orchestrator launch gate only and is not made false by this change. No rule-file edit is needed, and editing a policy rule file would need explicit authorization.

---

## 9. File Sizes (Q7)

Counts use Grep `^` line counts against the 500-line limit.

| File | Lines | Expected change | Headroom |
|---|---|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | 369 | about +4 (black wraps the call inside `if`; line 345 is already about 88 characters) | ample |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 471 | about +3 | 29 lines; keep the change minimal |
| `tests/scripts/dev_tools/test_validate_epic_planner_state.py` | 360 | about +55 to +65 | adequate |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` | 413 | about +50 | adequate (about 37 lines remain at +50) |
| `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` | 225 | about +5 | ample |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | 396 | none planned | not a recommended home |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` | 343 | none planned | n/a |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | 495 | **do not change** | 5 |

---

## 10. Jest Coverage Thresholds (Q8)

- `extensions/drm-copilot/jest.config.cjs:25` opens `coverageThreshold`, a per-file map with no `global` key (comments at lines 20-24).
- Grep `src/lib/validate/epic|orchestration-artifacts` in `jest.config.cjs` matched only `./src/lib/validate/orchestration-artifacts.ts` (line 113). **There is no entry for `./src/lib/validate/epic-planner-state-core.ts`.**
- The per-file Jest gate therefore does not enforce coverage on this file, and PR #829 changed it without adding an entry.
- The repository policy (85% line / 75% branch, with no regression on changed lines) still applies. The executor should record the `text` reporter row for `epic-planner-state-core.ts` from the full coverage run and show that both new branches of the conditional are exercised: flag-asserted, key-present, and key-absent-and-gated.
- Adding a threshold entry is optional. It should be added only after the measured row is known to be at or above 85/75; otherwise the full run fails on pre-existing uncovered lines.

---

## 11. Toolchain Commands (Q9)

These commands were used by the PR #829 plan (`plan.2026-09-29T16-06.md`, tasks P0-T8..T16, P8-T1..T7, P9-T1..T6). None were run in this session.

Python, from the worktree root:

```
poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent" -vv
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

The first pytest command is the expect-fail run before the fix and the pass run after it. `--cov` must use the dotted module name, because a `.py` path measures nothing. The `--deselect` matches #829 P0-T10/P8-T5.

TypeScript, from `extensions/drm-copilot/`:

```
npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts
npm run lint
npm run typecheck
node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts
node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
```

Notes:

- The targeted Jest run omits `--coverage`, because per-file thresholds fail a subset run.
- If the Prettier check fails, use `npx prettier --write` on the same paths, not `npm run format`.
- Architecture-boundary and contract stages follow #829: P0-T15 / P8-T4 / P9-T4 discovery commands, and the P8-T7 / P9-T6 `git diff --stat` checks confirming `validate_orchestration_artifacts.py` and the MCP tool-definition and input files are unchanged.
- No Pester run is needed because no guidance or mirror file changes.

---

## 12. Numeric Derivation Evidence

Numeric claim: the number of production call sites that invoke the planner-level (top-level) topology-receipt check and must be key-gated. The answer is 2.

- **Complete Family:** every production (non-test, non-docs) call site that validates the top-level epic-planner `topology_receipt` in any runtime (Python, TypeScript, PowerShell, bundled resources).
- **Exhaustive Search Scope:** the entire worktree excluding `docs/**` and the test trees (`tests/**`, `extensions/drm-copilot/test/**`). This covers `scripts/**`, `extensions/drm-copilot/src/**`, `extensions/drm-copilot/resources/**`, `.claude/**`, `.agents/**`, `.codex/**`, and `.github/**`.
- **Inclusion Rules:** a call expression that passes the top-level state's `topology_receipt` value to a planner topology validator.
- **Exclusion Rules:** function definitions; per-feature reads (`feature.get("topology_receipt")`, `feature["topology_receipt"]`); test files; prose.
- **Primary Search Strategy or Query Expression:** Grep `_validate_planner_topology_receipt|validatePlannerTopologyReceipt` over the worktree with glob `!docs/**`. This returned four lines (two definitions, two calls); applying the exclusion rules removes the definitions.
- **Primary Member Set:** `scripts/dev_tools/validate_epic_planner_state.py:345`; `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:443`.
- **Primary Count:** 2
- **Cross-check Search Strategy or Query Expression:** Grep `(state|value)(\.get\(|\[)"topology_receipt"` over the worktree with glob `!{docs,tests}/**`. This finds top-level-state reads of the key independently of the validator's name. It returned three lines; `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts:334` is excluded as a test file.
- **Cross-check Member Set:** `scripts/dev_tools/validate_epic_planner_state.py:345`; `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:443`.
- **Cross-check Count:** 2
- **Member-set Comparison:** the normalized sets (file:line) are identical. Neither search found a PowerShell, resources, `.claude`, `.agents`, or `.codex` member. The Glob for bundled copies in §8 independently confirms that no mirror of either production file exists.

---

## 13. Automation Feasibility

No third-party UI is involved. Every change is a local source or test edit verified by deterministic tools: black, ruff, pyright, pytest, prettier, ESLint, tsc, and Jest. There is no external service, credential, or manual step. The single design decision (key membership versus a value test) is resolved in §2 from the #829 precedent and `.claude/rules/orchestrator-state.md:197`, so the plan can be executed without user input.

---

## 14. Recommendation Summary

1. Python: gate `validate_epic_planner_state.py:345` with `if not key_gated or "topology_receipt" in state:`, and update the comment at line 328 and the docstring at lines 289-291.
2. TS: gate `epic-planner-state-core.ts:443` with `if (!requireLaunchPaths || "topology_receipt" in value)`, and update the comment at line 423.
3. Update `test_readiness_requires_epic_preparation_topology_receipts` to assert the top-level error under a Codex flag.
4. Add Python and TS twin tests for: key absent and key-gated (regression-first), Codex flag with the key absent, and present `null`. Extend the service-call threading test.
5. Make no changes to plumbing, CLI, guidance, mirrors, rules, or `jest.config.cjs`.
6. File a follow-up issue for the unconditional per-feature `model_routing_receipt` and `topology_receipt` checks (§3.1) and the Claude contract's omission of `max_parallel_features` and `research_path` (§3.2). Until those are resolved, a Claude-prepared checkpoint still cannot pass the strict ready gate.
