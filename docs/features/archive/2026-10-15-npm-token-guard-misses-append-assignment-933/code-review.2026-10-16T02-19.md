# Code Review: npm token guard misses append assignment (#933)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933` (`9421a9b7a4cc4817486976b9023d62ed89a7f71c`)
**Review Type:** Remediation cycle 1 re-review (reaudit, feature-vs-base)

**Total blocking findings: 0.**

---

## Executive Summary

The full branch diff changes two Python files in the test tree and no production file. The regex change from the initial cycle (`\bNPM_TOKEN\s*\+?=(?!=)` in alternative B of `_NPM_TOKEN_ASSIGNMENT`, `tests/scripts/dev_tools/npm_token_guard_test_support.py:47`) is unchanged by remediation cycle 1, as decision D4 requires. Cycle 1 (`c3da25c20`) rewrote the `find_npm_token_assignments` docstring (lines 122-141), added four parametrize rows, and reworded the pinned-residual test docstring.

The reviewer probed the unchanged pattern in memory against 24 inputs covering every new row and every claim in the rewritten docstring:

| Input | Docstring / row claim | Pattern result |
|---|---|---|
| `env.NPM_TOKEN += x` | reported (dot prefix) | reported |
| `MY-NPM_TOKEN+=x` | reported (hyphen prefix) | reported |
| `env.NPM_TOKEN = x`, `secrets.NPM_TOKEN = x` | reported (dot-prefixed `=`) | reported |
| `(( NPM_TOKEN += 1 ))` | reported | reported |
| `NPM_TOKEN++=x` | not reported | not reported |
| `NPM_TOKEN+==x`, `NPM_TOKEN==value` | not reported | not reported |
| `MY_NPM_TOKEN+=x`, `MY_NPM_TOKEN=x`, `MYNPM_TOKEN=x`, `NPM_TOKENX=x`, `NPM_TOKEN_V2+=x` | not reported (letter, digit, or underscore extension) | not reported |
| `${{ secrets.NPM_TOKEN }}`, `if: ${{ env.NPM_TOKEN == '' }}` | not reported (context read without operator) | not reported |
| `set NPM_TOKEN in the settings page` | not reported (prose) | not reported |

0 mismatches. The prior findings CR-1, CR-2, and CR-3 are closed. One new Minor observation concerns the rationale of decision D6 (CR-5), and one Info observation concerns test-docstring wording (CR-6). Neither blocks the PR.

**Top 3 risks:**
1. The full-suite branch-coverage figure moves by one partial branch between runs on identical production source, and the responsible branch is not identified (CR-5). This does not affect this branch's correctness but can halt future coverage comparisons.
2. AC-9 depends on PR CI and cannot be verified until CI runs on the PR head.
3. Over-reporting of dot- and hyphen-prefixed assignments is retained by design (D4); it fails closed and is now documented and pinned.

**PR readiness recommendation:** **Ready**.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md` | "Plan Deviations", revision 1.1 entry (line 242) | CR-5: Decision D6's floor is sound (zero production lines changed; post-change branch coverage 88.11243718592965% equals the original pre-change baseline), but its rationale asserts that the swing "tracks test-file changes only" and is "not nondeterminism" without a mechanism. Pytest runs serially (no xdist in `pyproject.toml` `addopts`), `tests/*` is omitted, and the changed tests are pure in-memory calls. The flipping branch is not identified by file and line. | Diff per-file partial-branch counts between a 504 run and a 505 run (two `coverage.json` reports) and track the responsible branch as a separate determinism follow-up. No change to this branch. | Unidentified coverage variance can halt later coverage comparisons that use a cycle baseline as a floor. | `rc1-coverage-comparison.2026-10-16T02-11.md`; TOTAL rows in `baseline-pytest-coverage.2026-10-16T00-18.md` (505), `final-pytest-coverage.2026-10-16T00-34.md` (504), `rc1-baseline-pytest-coverage.2026-10-16T01-36.md` (504), `rc1-final-pytest-coverage.2026-10-16T01-47.md` (505) |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 259-265 | CR-6: The non-matching test's docstring reads "Text that reads but does not assign `NPM_TOKEN` is not reported", while it now also hosts `NPM_TOKEN++=x` (not valid shell syntax; neither a read nor an assignment) and, from the initial cycle, `(( NPM_TOKEN++ ))` (an arithmetic increment). In the support docstring, "an ``+==`` sequence" would read more naturally as "a ``+==`` sequence". | No action required; optional wording such as "Text that does not assign a value to `NPM_TOKEN`". | Precision only; behavior and row ids are correct. | File read |
| Info | `tests/scripts/dev_tools/npm_token_guard_test_support.py` | line 11 | CR-4 (carried): the module docstring attributes the assignment family to issues #712 and #739 only. | No action required. | Traceability is present at function level. | File read |

No Blocker or Major findings.

### Closure of prior findings

| Prior finding | Cycle input | Status | Verification |
|---|---|---|---|
| CR-1 (Minor) | F1 | Closed | Docstring lines 127-134 state the dot/hyphen behavior and the letter/digit/underscore exclusion; rows at lines 229-230; reviewer probe 0 mismatches; phrase "longer or prefixed" removed (executor probe `rc1-docstring-f1.2026-10-16T02-13.md`, reviewer read). |
| CR-2 (Nit) | F2 | Closed | Rows `arithmetic-compound-append` (line 231, `[1]`) and `double-plus-equals-not-reported` (line 261, `[]`); reviewer probe confirms both. |
| CR-3 (Nit) | F3 | Closed | Lines 310-311: "These rows pin the current behavior so a change to any outcome is visible."; "existing" absent. |

---

## Implementation Audit

### Python implementation audit

- **Correctness:** The pattern is unchanged in cycle 1 (`git diff 090b24817..HEAD` shows no change to line 47; executor digest `bc428627...d445`, flags 34, equal before and after). Docstring claims match the pattern: alternative B's `\b` matches after `.`, `-`, `:`, and whitespace, so prefixed assignment forms are reported; alternative A's `(?<![\w.-])` lookbehind keeps `env.NPM_TOKEN: x` unreported, which the docstring does not contradict. For `NPM_TOKEN++=x`, `\+?` consumes one `+` and `=` fails against the second `+`; the empty path fails `=` against `+`.
- **Performance:** No pattern change; no catastrophic-backtracking risk.
- **Typing:** No signature change; pyright 0 errors (reviewer rerun).
- **Suppressions:** None added.
- **Scope:** Cycle 1 changed only the two permitted files outside the feature folder (`git diff --name-only 090b24817..HEAD`, reviewer rerun); `issue.md` unchanged in the cycle.
- **File size and width:** 184 and 404 lines; longest lines 87 and 88 characters (reviewer `awk` found no line over 88).

### TypeScript implementation audit

N/A: no TypeScript file changed.

### PowerShell implementation audit

N/A: no PowerShell file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/remediation-baseline/rc1-baseline-characterization.2026-10-16T01-37.md`: `[1] [1] [1] []` for the four new inputs against the unchanged regex, recorded before the rows were added.
- `evidence/regression-testing/rc1-rows-f1.2026-10-16T01-40.md`, `rc1-rows-f2-detect.2026-10-16T01-40.md`, `rc1-rows-f2-ignore.2026-10-16T01-41.md`, `rc1-pass-after.2026-10-16T01-42.md`: new rows PASSED; module 70 passed.
- `evidence/qa-gates/rc1-final-loop-single-pass.2026-10-16T01-48.md`: single clean pass.
- `evidence/qa-gates/rc1-coverage-comparison.2026-10-16T02-11.md`: PASS under D6; supersedes the halted `rc1-coverage-comparison.2026-10-16T01-52.md`, which is retained unedited.
- `evidence/qa-gates/rc1-line-width.2026-10-16T02-13.md`, `rc1-line-count.2026-10-16T02-13.md`, `rc1-regex-unchanged.2026-10-16T02-13.md`: consistent with reviewer reruns.

### Quality assessment prompts

- **Determinism:** The changed tests use no clock, sleep, randomness, network, or temporary file.
- **Isolation:** One input string and one finder per row.
- **Speed:** 70 rows in 0.12s (reviewer rerun).
- **Diagnostics:** Assertion messages include the ASCII-escaped input and actual result.
- **Arrange-Act-Assert:** Markers present in all three affected test functions.

---

## Security / Correctness Checks

- The regex is unchanged in cycle 1, so detection breadth is identical to the initial review; relative to `origin/main` the change only widens detection.
- D4 retains fail-closed over-reporting for prefixed assignments; narrowing `\b` would stop reporting `env.NPM_TOKEN = x`, which was reported on `origin/main`. The reviewer agrees with D4.
- The repository tree-scan rows pass (70 passed), so no file under `.github/` is newly reported.
- No secret, credential, `.env` file, or workflow change.

---

## Research Log

- `remediation-inputs.2026-10-16T00-56.md` (F1-F3, D4, scope, exit condition).
- `remediation-plan.2026-10-16T00-56.md` (52/52 tasks; revision 1.1 and D6 in "Plan Deviations").
- `pyproject.toml` lines 116-124 (`addopts` has no xdist option; `[tool.coverage.run] omit` lists `tests/*`).
- Prior review set `code-review.2026-10-16T00-50.md`.

---

## Verdict

**Approve.** 0 blocking findings. CR-1, CR-2, and CR-3 are closed. CR-5 (Minor) is a non-blocking observation about the D6 rationale, to be tracked outside this item; CR-6 and CR-4 are Info and need no action.
