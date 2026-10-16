# Code Review: Epic-planner per-feature receipt-checks key gate (#543)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-543` suffix matches the branch name.
**Base Branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543` @ `5e338716153fcf29c2d9e3c3ba23d16906220cd4`
**Review Type:** Initial review

---

## Executive Summary

The branch completes the remaining #543 gap left by PRs #829 and #874. Under `require_ready_for_execution` with no Codex flag, the per-feature `model_routing_receipt` and `topology_receipt` checks now run only for a feature that carries the corresponding key, so a Claude-prepared epic-planner checkpoint can pass the ready gate. Either Codex flag keeps both checks unconditional. The change is small (Python +64/-42, TypeScript +43/-29) and mirrors the same predicate in both runtimes. Reviewed evidence: the full branch diff, `artifacts/pr_context.summary.txt`, the 57 evidence files, `artifacts/python/lcov.info`, and reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (68 passed), and targeted Jest (68 passed).

**What changed:**
- `scripts/dev_tools/validate_epic_planner_state.py`: the model-receipt block moves unchanged into the new private helper `_validate_feature_model_receipt`; `_validate_ready_features` gains keyword-only `key_gated: bool = False` and wraps each receipt block in `if not key_gated or "<key>" in feature:`; the call site passes `key_gated=key_gated`. Docstring and comment updated.
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`: `validateReadyFeatures` gains `keyGated: boolean`; the two receipt blocks are wrapped in `if (!keyGated || "<key>" in feature)`; the call site passes `requireLaunchPaths`.
- New behaviour-matrix tests in both runtimes; the defect-pinning Python test and the MCP threading test are updated.

**Top 3 risks:**
1. TypeScript coverage is not artifact-verified: no `lcov.info` exists because the final run replaced the configured `lcov` reporter with `text` (CR-1).
2. `epic-planner-state-core.ts` is at 488 of the 500-line limit; the next change to this file is likely to require a split (CR-4).
3. With no Codex flag, a checkpoint that omits both receipt keys now passes the receipt part of the ready gate. This is the specified behaviour; the safety of the Codex path depends on Codex callers continuing to assert a Codex flag, which the MCP threading test covers.

**PR readiness recommendation:** **Needs Revision** - the code is correct and fully tested, but the mandatory TypeScript coverage artifact must be regenerated before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | coverage artifact `coverage/lcov.info` / `extensions/drm-copilot/coverage/lcov.info` | CR-1: The TypeScript coverage artifact is absent. The final run used `--coverageReporters=text --coverageReporters=text-summary`, overriding the `lcov` reporter configured in `extensions/drm-copilot/jest.config.cjs` line 18, so no `lcov.info` was written. | Run `npm --prefix extensions/drm-copilot run test:coverage`; confirm `extensions/drm-copilot/coverage/lcov.info` exists; record repo-wide and per-file line/branch figures for `src/lib/validate/epic-planner-state-core.ts` from it under `evidence/qa-gates/`. | Coverage verification for every language with changed files is mandatory and artifact-based. The text figures (98.36% lines / 94.06% branches) indicate the thresholds are met, so no code change is expected. | `find . -name lcov.info -not -path "*/node_modules/*"` returns only `./artifacts/python/lcov.info`; `evidence/qa-gates/final-typescript-test-coverage.2026-10-16T01-13.md` |
| Minor | `artifacts/python/lcov.info` | whole file | CR-2: The Python artifact contains one `SF:` record (`validate_epic_planner_state.py`), produced by `--cov=scripts.dev_tools.validate_epic_planner_state`. It does not give a repository-wide Python figure. | When regenerating coverage for CR-1, optionally also run the Python suite with `--cov=scripts --cov-branch` to record a repository-wide figure. | The changed file meets thresholds (92.55% / 86.00%); the gap is in repository-wide reporting only. | `grep "^SF:" artifacts/python/lcov.info` (1 record) |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | lines 437-439, 450-452 | CR-3: The call site passes `requireLaunchPaths` as `keyGated`. The variable now gates the per-feature receipts and the planner receipt as well as launch paths, and `validateReadyFeatures` takes a positional boolean while the sibling call uses an options object (`{ requireLaunchPaths }`). | In a later change, consider renaming the local to `keyGated` and passing an options object. | Readability only; the spec mandated this form (AC10), and behaviour is correct. | `git diff adb9aa5f0..HEAD -- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` |
| Info | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | whole file (488 lines) | CR-4: The file is at 488 of 500 lines (baseline 474). Python extracted `_validate_feature_model_receipt`; TypeScript kept the block inline. | Plan a module split (for example, move `validateReadyFeatures` into its own module) before the next addition to this file. | Within the limit today; headroom is 12 lines. | `evidence/qa-gates/line-counts-final.2026-10-16T01-17.md` |
| Info | `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | `_extract_features` line 140-146; `extractFeatures` lines 175-181 | CR-5 (pre-existing, not introduced): non-object entries in `features` are dropped before `_validate_ready_features` / `validateReadyFeatures` enumerate, so their `features[i]` prefixes use the compacted index when a non-object entry precedes. | Out of scope for this change; consider passing original indices if this is addressed later. | Affects error-message indices only for checkpoints that already fail with `features[i] must be an object.`. | Source inspection of both functions |

No Major findings. One Blocker (CR-1), which concerns evidence rather than code.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The model-receipt logic moved into `_validate_feature_model_receipt` unchanged (error strings byte-identical; `evidence/qa-gates/error-strings-unchanged.2026-10-16T01-03.md`), which keeps `_validate_ready_features` short and readable.
- `key_gated` is keyword-only with default `False`, so any caller that omits it gets the strict (unconditional) behaviour.
- Key membership (`"<key>" in feature`), not truthiness, arms each check, so a present `null` receipt is still rejected.

#### Typing and API notes

- No new public Python API. Signatures are fully annotated; `cast("dict[str, Any]", ...)` follows the module's existing pattern. Pyright reports 0 errors.

#### Error handling and logging

- The validator continues to return error strings. No exceptions or logging changed.

### TypeScript implementation audit

#### What changed well

- The predicate matches the Python twin exactly, and the call site reuses the existing `requireLaunchPaths` activation value, so both runtimes derive the gate from the same two flags.
- Error strings and their order are unchanged.

#### Type safety and maintainability

- No `any`, casts, or suppressions added. `"<key>" in feature` on `Record<string, unknown>` is type-safe; the features come from `JSON.parse` and pass `isObject` in `extractFeatures`, so the prototype chain contributes no receipt keys.
- See CR-3 (naming / positional boolean) and CR-4 (file size headroom).

#### Error handling and logging

- No change to boundary validation; failures remain aggregated error strings.

---

## Test Quality Audit

Both runtimes cover every row of the spec behaviour matrix, and the MCP-level test confirms the Codex flags are threaded through `validateOrchestrationServiceCall`. Fail-before / pass-after evidence exists for the primary regression test in both runtimes. Coverage numbers are artifact-verified for Python and text-reporter-only for TypeScript (CR-1).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` - 7 cases covering absent keys, each Codex flag, present `null` per key, independent per-key gating, and index preservation. Exact-string assertions.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` - TypeScript twin with identical error literals (`evidence/qa-gates/byte-identical-strings.2026-10-16T01-04.md`).
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` - six added assertions on the Codex-flag and key-gated results.
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_resolved_child_model_receipt` - now asserts the exact string under `require_codex_model_routing=True`.
- `evidence/regression-testing/fail-before-python.2026-10-16T00-41.md`, `fail-before-typescript.2026-10-16T00-42.md` (exit 1) and `pass-after-*.md` (exit 0) - prove the regression test detects the defect.
- `evidence/qa-gates/coverage-delta-verification.2026-10-16T01-16.md` - no regression; zero added lines uncovered.

### Quality assessment prompts

- **Determinism:** pure in-memory validation; receipts built by deterministic resolvers.
- **Isolation:** each test builds its own state and checks one matrix row.
- **Speed:** 68 Python tests in 0.85s (reviewer run).
- **Diagnostics:** exact-string membership and list-equality assertions print the full error list on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | The two `# noqa: S105 - test fixture data` lines mark error-message substrings, not credentials; format is pre-authorized. |
| No unsafe subprocess or command construction | N/A | No subprocess code changed. |
| Input validation at boundaries | PASS | Present-but-invalid receipts are still validated; only absent keys skip under the no-Codex-flag path. |
| Error handling remains explicit | PASS | All error strings unchanged and asserted exactly. |
| Configuration / path handling is safe | N/A | No path handling changed. |
| Codex strictness preserved | PASS | Either Codex flag keeps both checks unconditional (Python parametrized test, TypeScript `it.each`, MCP threading test). |

---

## Research Log

No external research was required. The design follows `research/research.2026-10-15T08-05.md` Candidate A and the precedent set by PRs #829 and #874.

---

## Verdict

The implementation is correct, minimal, consistent across runtimes, and covered by tests for every behaviour-matrix row. All format, lint, type, and test stages pass on reviewer re-run. The change is not ready for PR flow until CR-1 is resolved: the TypeScript coverage artifact must be regenerated with the configured `lcov` reporter and its figures recorded. CR-2 through CR-5 are non-blocking.
