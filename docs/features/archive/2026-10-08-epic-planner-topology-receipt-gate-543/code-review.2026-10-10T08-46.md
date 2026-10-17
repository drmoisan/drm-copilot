# Code Review: Epic planner ready gate key-gates the planner topology receipt (#543)

- Review date: 2026-10-10
- Review type: Remediation cycle 1 re-review (review pass 2). Supersedes `code-review.2026-10-10T08-29.md`.
- Branch: `bug/epic-planner-topology-receipt-gate-543`
- Diff: `git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD` (head `ab36c108a4f72fc710f824a26100351352526286`; merge base equals the `origin/main` tip)
- Work mode: `full-bug` (`issue.md` line 10)
- Reviewer: feature-review agent

## Executive Summary

No production or test code changed since the prior review: `git diff --name-status e7612e93..HEAD` lists only 14 added feature-folder documents. The reviewer re-read the full code diff against the base and reaches the same conclusions as the prior review.

The change adds one condition per runtime so that the planner-level `topology_receipt` check under `require_ready_for_execution` runs only when a Codex flag is asserted or the checkpoint carries the top-level key:

- Python `scripts/dev_tools/validate_epic_planner_state.py:348`: `if not key_gated or "topology_receipt" in state:`
- TypeScript `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:444`: `if (!requireLaunchPaths || "topology_receipt" in value) {`

The two predicates are logically equivalent (`key_gated` at Python line 332 and `requireLaunchPaths` at TypeScript lines 425-427 are computed identically from the two Codex flags). Key membership, not truthiness, is used, so a present `null` still arms the check; tests pin this in both runtimes. No error string, signature, export, or schema changed.

Coverage of the new lines is now artifact-verified in both runtimes: TypeScript `DA:444,46`, `DA:445,42`, `DA:446,42` with both `BRDA:444` records non-zero (38, 42) in `extensions/drm-copilot/coverage/lcov.info`; Python `DA:348,1`, `DA:349,1` with both `BRDA:348` arms taken in `artifacts/python/lcov.info`.

The reviewer re-ran format, lint, type-check, and targeted tests in both languages at head `ab36c108`; all exited 0.

Blocking findings: 0. Non-blocking findings: 3 (CR-1 to CR-3, carried forward unchanged; none was in the remediation's required scope).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (Minor) | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`; `scripts/dev_tools/validate_epic_planner_state.py` | TS lines 425-427, 444; Python lines 332, 348 | CR-1: The activation variables `requireLaunchPaths` (TypeScript) and `key_gated` (Python) now also govern the planner topology receipt, so the TypeScript name describes less than it controls. The two names also have opposite polarity across runtimes (pre-existing). | Consider a common rename (for example `keyGatedMode` / `key_gated`) in the follow-up issue that key-gates the per-feature receipts. | The updated comments (TS 423-424, Python 330-331) mitigate the naming gap. `spec.md` line 61 deliberately defers the rename to keep the diff minimal. | `git diff` hunks `epic-planner-state-core.ts @@ -420` and `validate_epic_planner_state.py @@ -325`. |
| Non-blocking (Minor) | `tests/scripts/dev_tools/test_validate_epic_planner_state.py` | line 222 | CR-2: `test_readiness_requires_epic_preparation_topology_receipts` now passes `require_codex_topology=True`, so its per-feature assertions run only in Codex mode. No test in either runtime now pins that an absent per-feature `topology_receipt` still errors in key-gated mode, which `spec.md` Non-goals states as an invariant of this change. | Optional: add a no-flag assertion that an absent `features[0].topology_receipt` still yields `features[0].topology_receipt must be an object`, or defer to the follow-up issue, which will change that behaviour. | The edit is mandated by AC5 and is correct for the planner-level assertion. The gap is small and expected to be superseded. | `git diff` hunk `@@ -219,7 +219,7 @@` in the test file. |
| Non-blocking (Info) | `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` | lines 85-98 | CR-3: The case tables `codexFlagCases` and `validReceiptCases` sit between `readyState()` and the `describe` block, about 270 lines from the `it.each` calls that use them. | No change required. Optionally co-locate them if the file is later split. | The file is at 490 lines (10 lines of headroom), so a split is likely in the follow-up. | `git diff` hunk `@@ -81,6 +82,21 @@`. |

## Detailed Review

### Correctness

- Truth table verified against `spec.md` Proposed Fix: no flag and key absent skips the check (Python 348 false -> 352; TypeScript 444 false); either flag runs it regardless of the key; a present key (including `null`) runs it in both modes.
- Parity: both runtimes call their unchanged validator with the same predicate; asserted strings are byte-identical.
- Scope of effect: the condition sits inside the `require_ready_for_execution` branch in both runtimes, so non-ready validation is unaffected.
- The TypeScript `in` operator is applied to the `JSON.parse` result; `topology_receipt` is not an `Object.prototype` member, so prototype-chain lookup cannot produce a false positive.

### Tests

- Python: four new tests (six cases) plus one modified call at line 222.
- TypeScript: four new tests (six cases) plus three assertions in `validate-orchestration-service-call.test.ts` lines 205-211.
- Fail-before / pass-after recorded in both runtimes under `evidence/regression-testing/`; commit order (test `38d21557c` before fixes `0192f0a0f`, `bc8973bdf`) is consistent.

### Maintainability

- File sizes at head: 375, 474, 424, 490, 232 lines (reviewer `awk 'END{print NR}'`), all within the 500-line limit.
- No suppressions, no `any`, no new dependencies.

### Security and Robustness

- The gate is relaxed only for checkpoints lacking the top-level key and only when no Codex flag is set. Codex callers assert both flags; residual risk (a Codex caller omitting both flags) is documented in `spec.md` Risks.

## Toolchain Verification (reviewer, check-only, head ab36c108)

| Stage | Python | TypeScript |
|---|---|---|
| Format | `black --check`: 2 unchanged | `prettier --check`: clean |
| Lint | `ruff check --no-fix`: passed | `npm run lint`: exit 0 |
| Type check | `pyright`: 0 errors | `npm run typecheck`: exit 0 |
| Tests | `pytest --no-cov` 4 files: 71 passed | `run-jest.cjs` 5 suites: 63 passed |
| Coverage (artifact) | 91.76% lines / 84.38% branches | 98.31% lines / 93.81% branches |

## Verdict

Code quality: acceptable for merge. Blocking findings: 0. Non-blocking: CR-1, CR-2, CR-3.
