# Code Review: npm token guard comparison false positive and stale docstring (#845)

**Review Date:** 2026-10-09
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845`
**Review Type:** Initial review (structure rewrite of the 2026-10-09T21-30 pass)

---

## Executive Summary

The branch changes one file, `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (9 insertions, 4 deletions), reviewed with `git diff origin/main...HEAD`. Blocking findings: 0. Non-blocking findings: 3 (CR-1, CR-2, CR-3). Verdict: APPROVE.

**What changed:**
1. `_NPM_TOKEN_ASSIGNMENT` alternative B changed from `\bNPM_TOKEN\s*=` to `\bNPM_TOKEN\s*=(?!=)`. Alternative A and `re.IGNORECASE` are unchanged.
2. `find_npm_token_assignments` docstring now lists an `==` comparison among the non-reported inputs.
3. Summary line of `test_find_npm_token_references_detects_reintroduced_reference` changed to "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported."
4. New rows: positive `empty-assignment-end-of-line`; negative `equality-comparison`, `shell-equality-test`, `inequality-comparison`.

**Top risks:**
1. The test file is at 497 of 500 lines, which constrains further additions (CR-1).
2. Pre-existing residual matches (single-`=` shell tests, Bash `=~`) are undocumented by tests (CR-2).
3. The accepted narrowing for `NPM_TOKEN==value` has no explicit row (CR-3).

**PR readiness recommendation:** **Go** - the change is minimal, fail-first verified, and all 56 module tests pass.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | whole file | CR-1: File is at 497 of 500 lines; further parametrized rows will require splitting the module | No action for this change; if more rows are needed, move the `find_npm_token_assignments` tests to a sibling module | The 500-line limit leaves 3 lines of headroom | `final-line-count.md`; reviewer `wc -l` |
| Minor | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | `_NPM_TOKEN_ASSIGNMENT` tests | CR-2: Pre-existing residuals documented in `spec.md` as non-goals have no test row: `[ $NPM_TOKEN = "" ]` and Bash `=~` are still reported; `NPM_TOKEN+=x` is not reported | Optional future work only | Residuals are known and accepted; documenting them in tests would pin behavior | `spec.md` non-goals |
| Minor | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | `ignores_non_matching_text` rows | CR-3: The accepted narrowing that `NPM_TOKEN==value` (assigns `=value` in shell) is no longer reported has no explicit row | Optional documentation only | Acknowledged in the spec's backward-compatibility section and covered indirectly by `shell-equality-test` | `spec.md` backward compatibility |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | diff | Numstat shows 4 removed lines, none containing `pytest.param(`; all 13 pre-existing rows preserved | None | Confirms no existing coverage was weakened | `evidence/qa-gates/diff-numstat.md` |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### Correctness analysis

- The lookahead is a fixed-width, zero-consumption assertion. For `env.NPM_TOKEN == ''` alternative A is rejected by the `(?<![\w.-])` lookbehind and alternative B now fails because the character after the first `=` is `=`. Regex backtracking over `\s*` cannot produce another match position because the name must be followed by optional whitespace and a single `=` not followed by `=`. Verified by the fail-first/pass-after evidence and the reviewer's re-run (56 passed).
- `NPM_TOKEN=` at end of line still matches because the negative lookahead succeeds at end of input; this is guarded by the `empty-assignment-end-of-line` row.
- `!=`, `<=`, and `>=` never matched alternative B and remain unmatched; `inequality-comparison` pins the `!=` case.
- Fail-first discipline was followed: the two comparison rows failed (`returned [1], expected []`) before the pattern change and passed after, while the two boundary rows passed in both states, which is the intended outcome.

#### Maintainability and style

- The change is minimal and confined to one file; the diff is readable and the new row ids are descriptive.
- Docstring wording is accurate. The finder docstring is consistent with the behavior; the test docstring now covers both `secrets` and `vars` rows.
- Line lengths comply with the 88-character limit (Ruff clean, Black unchanged). File length is 497 lines (limit 500).
- No new dependencies, no I/O, no clock or temp-file use.

#### Error handling and logging

- Not applicable; no error-handling paths changed.

---

## Test Quality Audit

The only changed file is a test file. The new rows are pure in-memory parametrize cases on synthetic strings, covering positive, negative, and boundary scenarios. The module run reports 56 passed.

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-first-assignment-rows.md` and `pass-after-assignment-rows.md` - fail-first and pass-after node results.
- `evidence/qa-gates/final-pytest-module.md` - 56 passed, exit 0.
- `evidence/qa-gates/integration-retest.md` - integration nodes passed.
- `evidence/qa-gates/final-black-check.md`, `final-ruff.md`, `final-pyright.md` - clean in one pass.

### Quality assessment prompts

- **Determinism:** Pure functions on literal strings; no clock, network, or filesystem.
- **Isolation:** Each row targets one finder behavior.
- **Speed:** In-memory only.
- **Diagnostics:** Row ids are descriptive; assertion messages unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Test inputs are synthetic strings; no real token value appears |
| No unsafe subprocess or command construction | N/A | No code of that kind changed |
| Input validation at boundaries | N/A | Test-only change |
| Detection coverage preserved | PASS | `NPM_TOKEN=${{ secrets.X }}` and YAML key forms remain detected; the sibling finder detects `secrets`/`vars` references, so the narrowing does not reopen a functional token route |

---

## Research Log

No external research was required. The review relied on `spec.md`, the evidence artifacts, and reviewer re-runs of pytest (56 passed) and Ruff (clean).

---

## Verdict

APPROVE. Blocking findings: 0. Non-blocking findings: 3 (CR-1, CR-2, CR-3).
