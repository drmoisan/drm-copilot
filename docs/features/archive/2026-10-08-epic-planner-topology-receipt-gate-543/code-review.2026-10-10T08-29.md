# Code Review: Epic planner ready gate key-gates the planner topology receipt (#543)

- Review date: 2026-10-10
- Branch: `bug/epic-planner-topology-receipt-gate-543`
- Diff: `git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD` (head `e7612e93a4e88f68eadae6ee9e34ead251c82872`; merge base equals the `origin/main` tip)
- Work mode: `full-bug` (`issue.md` line 10)
- Reviewer: feature-review agent

## Executive Summary

The change adds one condition per runtime so that the planner-level `topology_receipt` check under `require_ready_for_execution` runs only when a Codex flag is asserted or the checkpoint carries the top-level key. The implementation is minimal, matches the spec's Approach A exactly, and keeps the two runtimes in lockstep:

- Python `scripts/dev_tools/validate_epic_planner_state.py:348`: `if not key_gated or "topology_receipt" in state:`
- TypeScript `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:444`: `if (!requireLaunchPaths || "topology_receipt" in value) {`

Both conditions are logically equivalent (`key_gated` and `requireLaunchPaths` are computed identically from the two Codex flags at Python line 332 and TypeScript lines 425-427). Key membership rather than value truthiness is used, so a present `null` still arms the check; this is pinned by tests in both runtimes. No error string, signature, export, or schema changed. The TypeScript `in` idiom matches the PR #829 precedent at `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts:238`. Because `value` is produced by `JSON.parse` and `topology_receipt` is not an `Object.prototype` member, the prototype-chain semantics of `in` do not introduce a false positive.

Tests cover the full truth table from `spec.md` lines 83-90 in both runtimes, including both disjuncts of the new condition, and the MCP dispatch path is asserted for both flags and the key-gated case. The reviewer re-ran format, lint, type-check, and targeted tests in both languages at head; all passed.

No blocking code-quality finding was identified. Three non-blocking observations are recorded. Coverage-artifact compliance is reported in the policy audit (PA-1) and is not repeated as a code finding here.

Blocking findings: 0. Non-blocking findings: 3.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (Minor) | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`; `scripts/dev_tools/validate_epic_planner_state.py` | TS lines 425-427, 444; Python lines 332, 348 | CR-1: The activation variables `requireLaunchPaths` (TypeScript) and `key_gated` (Python) now also govern the planner topology receipt, so the TypeScript name in particular describes less than it controls. The two names also have opposite polarity across runtimes (pre-existing). | Consider a rename such as `keyGatedMode` / `key_gated` in both runtimes in the follow-up issue that key-gates the per-feature receipts. | Accurate names reduce the risk of a later edit gating only one of the checks. The updated comments at TS 423-424 and Python 330-331 mitigate this. The rename was deliberately not adopted (`spec.md` line 61) to keep the diff minimal; that is a reasonable trade-off for a three-line fix. | `git diff` hunks at `epic-planner-state-core.ts:@@ -420` and `validate_epic_planner_state.py:@@ -325`. |
| Non-blocking (Minor) | `tests/scripts/dev_tools/test_validate_epic_planner_state.py` | line 222 | CR-2: `test_readiness_requires_epic_preparation_topology_receipts` now passes `require_codex_topology=True`, so its per-feature assertions (lines 228-234: `features[0].topology_receipt must be an object`, `execution_context must be 'epic_preparation_child'`) run only in Codex mode. No Python test now pins that per-feature `topology_receipt` checks stay enforced in key-gated mode, which `spec.md` Non-goals (line 56) states as an invariant of this change. The per-feature `model_routing_receipt` is still pinned in key-gated mode (lines 176-188), and the TypeScript test `requires each prepared child to route through an orchestrator` (`epic-planner-state-core.test.ts` lines 425-444) pins a present-but-wrong per-feature receipt in key-gated mode, but no test in either runtime pins an absent per-feature `topology_receipt` in key-gated mode. | Optional: add an assertion with no Codex flag that an absent `features[0].topology_receipt` still yields `features[0].topology_receipt must be an object`, or defer it to the follow-up issue, which will change that behaviour anyway. | The edit was mandated by AC5 and is correct for the planner-level assertion. The gap is small and will be superseded by the planned follow-up. | `git diff` hunk `@@ -219,7 +219,7 @@` in the test file; reviewer `Grep` of `topology_receipt must be an object` across `tests/scripts/dev_tools/` and `extensions/drm-copilot/test/`. |
| Non-blocking (Info) | `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` | lines 85-99 | CR-3: The module-level case tables `codexFlagCases` and `validReceiptCases` are placed between `readyState()` and the `describe` block, separated from the tests that use them by about 270 lines. | No change required. Optionally move each table next to its `it.each` call if the file is later split. | Proximity aids reading; the typed `Pick<ValidateEpicPlannerStateOptions, ...>` tables are otherwise a clean way to satisfy `exactOptionalPropertyTypes` (`tsconfig.json` line 14, cited in plan). | `git diff` hunk `@@ -81,6 +82,21 @@`. |

## Detailed Review

### Correctness

- **Truth table.** Verified against `spec.md` lines 83-90. With no flag and key absent, the check is skipped (Python 348 false -> 352; TypeScript 444 false). With either flag, the check runs regardless of the key. With the key present (including `null`), the check runs in both modes. The existing field-level errors for a present but wrong receipt are unchanged.
- **Parity.** Both runtimes compute the same predicate and call the unchanged validator. Error strings are byte-identical; the twin tests assert the same literal `Epic planner topology_receipt must be an object.`
- **Scope of effect.** The condition is inside the `require_ready_for_execution` branch in both runtimes (Python 329, TypeScript 422), so non-ready validation is unaffected.
- **Type safety.** In Python, `state` is a `dict[str, Any]` after the `isinstance` guard at line 300, so `in` is a dictionary key test. In TypeScript, `value` is the parsed root object, narrowed earlier in the function.

### Tests

- Python: four new tests (six cases) inserted at lines 254-317 plus one modified call at line 222. Assertions use exact membership for the error case and filtered-list equality for the no-error case, which prints offending strings on failure.
- TypeScript: four new tests (six cases) inserted at lines 364-424 plus three assertions in `validate-orchestration-service-call.test.ts` lines 205-211. The negative assertion `expect(keyGated).not.toContain("Epic planner topology_receipt")` is unambiguous because the per-feature prefix is `Epic planner checkpoint features[0].topology_receipt` (noted in `spec.md` line 193).
- Fail-before / pass-after recorded for the regression test in both runtimes (`evidence/regression-testing/fail-before-python.2026-10-10T08-07.md`, `fail-before-typescript.2026-10-10T08-08.md`, and the paired pass-after files). The git history agrees: the test commit `38d21557c` (08:08:32) precedes the fix commits `0192f0a0f` (08:09:21) and `bc8973bdf` (08:10:09).
- Fixtures are in memory; no temporary files, timers, or network access.

### Maintainability

- File sizes after change: 375, 474, 424, 490, 232 lines (reviewer `awk 'END{print NR}'`). `epic-planner-state-core.ts` has 26 lines of headroom and its test file has 10; any further growth in the follow-up will likely require a split of `epic-planner-state-core.test.ts`.
- Comments and the Python docstring were updated to describe the new gate accurately.
- No suppressions, no `any`, no new dependencies.

### Security and Robustness

- The change relaxes a validation gate only for checkpoints that lack the top-level key and only when no Codex flag is set. Codex callers assert both flags (`spec.md` lines 149, 241), and that is pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`. The residual risk (a Codex caller that omits both flags) is documented in `spec.md` Risks.

## Toolchain Verification (reviewer, check-only, head e7612e93)

| Stage | Python | TypeScript |
|---|---|---|
| Format | `black --check`: 2 unchanged | `prettier --check`: clean |
| Lint | `ruff check --no-fix`: passed | `npm run lint`: exit 0 |
| Type check | `pyright`: 0 errors | `npm run typecheck`: exit 0 |
| Tests | `pytest --no-cov` 4 files: 71 passed | `run-jest.cjs` 5 suites: 63 passed |

## Verdict

Code quality: acceptable for merge. Blocking findings: 0. Non-blocking: CR-1, CR-2, CR-3. Overall branch readiness is governed by the policy audit, which has one blocking coverage-artifact item (PA-1).
