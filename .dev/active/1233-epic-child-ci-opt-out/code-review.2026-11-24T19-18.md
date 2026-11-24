# Code Review: Epic Child CI Opt-Out (#1233)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Feature Folder Selection Rule:** named by the caller and matching issue #1233 and the branch name
**Base Branch:** `main` (merge base `11b2c598652eb6cf6c3a3ccb1e7ea4340dda57d2`)
**Head Branch:** `feature/epic-child-ci-opt-out-1233` (head `9ad75122a69296f69938e5fb64d80a35ede5eb38`, pushed; no pull request yet)
**Review Type:** Re-audit after remediation cycle 2

---

## Executive Summary

This re-audit covers the full branch diff `11b2c5986..9ad75122a` and, in detail, the cycle-2 changes `502309bcd..9ad75122a`: commit `27fb9c67f` (cycle-1 review records), `61702e988` (the F2 fix, two corpus fixtures, two completion rows, the known-limitation paragraph and its contract rows, ledger `0015` update), `3abe730f4` (QA records, self-review, S7/U7 check-off), the main-sync merge `4fadc01eb` (#1240), and `9ad75122a` (post-sync record).

Specific checks performed:

- F2 closure: `missingObjectKeys` treats `undefined`, `null`, and whitespace-only strings as missing, the same predicate as Python `_missing_object_keys` (`item is None` or blank after `str.strip`) and `_missing_pr_gate_keys`. Its three callers (`validateCompletionPrGate`, `validateCompletionCiGate`, `validateCompletionLocalQcGate`) are the only ones in `extensions/drm-copilot/src`; error strings and order are unchanged.
- Cross-runtime probe: 16 checkpoint variants built from `opt-out-accepted.json` (null fields, null conclusion, all null, null heads, `0`, `false`, `[]`, `{}`, blank string, `null` and array gates, and four `ci_gate` cases without the opt-out) produced identical error lists from Python, the esbuild bundle of the branch TypeScript module, and the PowerShell module.
- Test discrimination: with `item === null ||` removed from the bundle, the 25-fixture corpus fails exactly `local-qc-gate-null-fields` and `local-qc-gate-null-heads`; with it present all 25 match. The executor's fail-before record names the same two corpus rows plus the two new completion rows.
- Ledger: the two new `orchestrator-state-completion.ts` blocks and the new test-file block each have a `Current` that occurs once at head, and replaying them under the parser's fence convention (lines joined without a final terminator) restores the merge-base bytes of both files.
- Known limitation: the paragraph sits in the issue #1233 section of the rule source; the generated rule and bundle copy share blob `7405bfaed`; the `X-LIMIT` rows have a fail-before record.
- Main sync: per-path numstat of the branch against `c030729de` at `3abe730f4` equals that against `11b2c5986` at `9ad75122a`, except the added post-sync record.

**Top 3 risks:**
1. `child_ci` is self-declared by the item checkpoint; the live-base check, the concurrent review, and the evidence file bound it (disclosed in the rule and ledger `0015`).
2. The whitespace sets of the three blank-string tests still differ (now a documented known limitation); a field holding only U+0085, U+001C, or U+FEFF is graded differently across runtimes.
3. Isolated subagents run the default branch's hooks, so the gate and completion behavior is proven by mocked Pester rows until the branch merges; the pull request's own `CI` run is still to come.

**PR readiness recommendation:** **Go**, subject to a green pull request `CI` run at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts` | `missingObjectKeys` | F2 is closed. The `null` condition also changes what the TypeScript `ci_gate` and `pr_gate` checks accept: a `null` required field is now reported as missing, matching Python. No existing test or fixture relied on the previous behavior. | None. | The orchestrator note chose the root fix so the pre-existing `ci_gate` and `pr_gate` divergence closes in this item. | Reviewer probe (16 of 16 identical); mutant check; `fail-before-f2.2026-11-24T18-39.md`. |
| Info | `.dev/engineering/process-reductions/0015-epic-child-ci-opt-out.md` | `## Summary`, `Merge commit: pending (PR #1233)` | Carried from the prior review: the line names the issue number; no pull request exists yet. | Back-fill the merge commit at the records stage as the README states. | The checker requires only the line's format. | README line 31. |
| Info | `artifacts/test-execution/run-scope.jest-extension.json`, `artifacts/test-execution/run-scope.pytest.json` | whole files | The reviewer's targeted Jest and pytest runs rewrote both run-scope records with their own selection windows; no coverage file was rewritten. | None. Re-run a selection with coverage if a stop hook grades `extensions/drm-copilot/coverage/lcov.info`; the file holds only the two measured modules, both at 100%. | Disclosure of reviewer side effects. | Run-scope record contents; coverage file modification times. |

No Blocker or Major finding. No covered file is at or above 700 lines (largest: `extensions/drm-copilot/jest.config.cjs`, 689 logical lines; child-CI helper 629; completion-checks module 592), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The fix is one condition in the shared helper, so `local_qc_gate`, `ci_gate`, and `pr_gate` share one presence rule, as in Python.
- `isObject` excludes `null` and arrays, matching Python `isinstance(value, dict)`; the probe's `gate_null` and `gate_array` variants agree in all three runtimes.
- Non-string present values (`0`, `false`, `[]`, `{}`) count as present in all three runtimes, so no new divergence was introduced.

#### API and safety notes

- `missingObjectKeys` remains exported with an unchanged signature; the TSDoc summary and inline comment name JSON `null`.

### PowerShell implementation audit

- No production change in cycle 2. The two `X-LIMIT` rows read the issue #1233 section of each rule copy through the suite's existing helpers and are added to `$script:CaseCount`.

### Python implementation audit

- No change in cycle 2.

---

## Test Quality Audit

The cycle adds two corpus fixtures (each asserted by the Python, TypeScript, and PowerShell corpus suites), two Jest completion rows for `null` `ci_gate` and `pr_gate` fields, and two contract rows for the known-limitation paragraph. Each set has a fail-before record with `ExpectedExitCode: 1` naming exactly the new rows. The reviewer mutant check confirms the corpus fixtures discriminate the `null` clause. Selection pass counts rose by exactly the added rows (Jest 797 to 801, Pester 913 to 917, pytest 224 to 226).

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-before-f2.2026-11-24T18-39.md`
- `evidence/regression-testing/fail-before-known-limitation.2026-11-24T18-43.md`
- `evidence/qa-gates/rc2-final-jest-selection.2026-11-24T18-58.md`
- `evidence/qa-gates/rc2-final-pester-selection.2026-11-24T19-01.md`
- `evidence/qa-gates/rc2-final-pytest-selection.2026-11-24T19-02.md`
- `evidence/qa-gates/rc2-final-typescript-static.2026-11-24T18-53.md`
- `evidence/qa-gates/rc2-final-powershell-static.2026-11-24T18-57.md`
- `evidence/qa-gates/rc2-contract-check.2026-11-24T19-03.md`
- `evidence/qa-gates/post-sync-check.2026-11-24T19-10.md`
- `evidence/qa-gates/self-review.2026-11-24T19-04.md`

---

## Documentation and Contract Audit

- The known-limitation paragraph is made through `scripts/harness-generation/sources/rules/orchestrator-state.md`; the generated rule and the bundle copy are identical, and `-Check` reports no drift after the main sync.
- Ledger `0015` lists the two cycle-2 files in `## Files Changed`, adds three revert blocks, extends the rule-section `Current` text, and adds the completion test file to revert step 6; the chain and ledger suites pass on the committed tree.
- `.github/workflows/`, `.claude/lib/docs`, the agent sources, and `extensions/drm-copilot/jest.config.cjs` are unchanged in cycle 2.

---

## Verdict

**PASS.** F2 and the whitespace-set Minor are closed (the latter as a documented known limitation). No blocking finding remains. Spec S19 is pending the pull request's own `CI` run.
