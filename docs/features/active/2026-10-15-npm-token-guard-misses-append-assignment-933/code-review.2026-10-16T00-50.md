# Code Review: npm token guard misses append assignment (#933)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main` (`adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933` (`5afda6fc7b0e168a13634f366e8f568bc2f4cd9e`)
**Review Type:** Initial feature review (feature-vs-base)

**Total blocking findings: 0.**

---

## Executive Summary

The branch changes two Python files in the test tree and no production file. In `tests/scripts/dev_tools/npm_token_guard_test_support.py:47`, alternative B of `_NPM_TOKEN_ASSIGNMENT` gains an optional `\+` before `=` so that `NPM_TOKEN+=...`, `export NPM_TOKEN+=...`, and `$env:NPM_TOKEN += ...` are reported. The `(?!=)` lookahead still excludes `==`, and because the lookahead applies after `\+?=`, `+==` is excluded on both backtracking paths. The `find_npm_token_assignments` docstring and the pinned-residual test docstring are updated to record the #933 reversal of the #845 append non-goal.

The reviewer verified the regex by reading it and by an in-memory probe of old and new patterns over 23 inputs. All inputs named in the review request behave as intended:

| Input | Old | New | Intended |
|---|---|---|---|
| `NPM_TOKEN+=x` | not reported | reported | reported |
| `NPM_TOKEN+=${{ secrets.X }}` | not reported | reported | reported |
| `export NPM_TOKEN+=x` | not reported | reported | reported |
| `$env:NPM_TOKEN += 'x'` | not reported | reported | reported |
| `NPM_TOKEN+==x` | not reported | not reported | not reported |
| `NPM_TOKEN_V2+=x` | not reported | not reported | not reported |
| `(( NPM_TOKEN++ ))` | not reported | not reported | not reported |
| `NPM_TOKEN==value`, `NPM_TOKEN == ''` | not reported | not reported | not reported |
| `env.NPM_TOKEN != ''` | not reported | not reported | not reported |
| `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}` | not reported | not reported | not reported |
| `[[ $NPM_TOKEN =~ ^npm_ ]]`, `NPM_TOKEN=` | reported | reported | reported (unchanged residuals) |

No input changed from reported to not reported, so the change cannot introduce a false negative relative to baseline; it only widens detection. Two related observations are recorded below (CR-1, CR-2). Neither blocks the PR.

**Top 3 risks:**
1. The rewritten docstring claims that a context read such as `env.NPM_TOKEN` and "a longer or prefixed name" are not reported, but `env.NPM_TOKEN += x` and `MY-NPM_TOKEN+=x` are reported because alternative B uses `\b` instead of alternative A's `(?<![\w.-])` lookbehind (CR-1). The effect is over-reporting, which fails closed for a guard.
2. Bash arithmetic `(( NPM_TOKEN += 1 ))` and the non-assignment `NPM_TOKEN +=x` are reported but not pinned by a test row (CR-2).
3. AC-9 depends on PR CI and cannot be verified until a PR exists.

**PR readiness recommendation:** **Ready** — CR-1 and CR-2 can be addressed inside this item as related follow-ups; neither is required for correctness of the issue fix.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `tests/scripts/dev_tools/npm_token_guard_test_support.py` | line 47 (alternative B) and lines 127-130 (docstring) | Alternative B begins with `\b`, which matches after `.` and `-`. `env.NPM_TOKEN += x` and `MY-NPM_TOKEN+=x` are reported, while the docstring states that a context read (`env.NPM_TOKEN`) and "a longer or prefixed name" are not reported. The `=` forms (`env.NPM_TOKEN = x`) were already reported before this branch; the branch extends the same behavior to `+=` and restates the inaccurate claim. | Either reword the docstring to state that only letter-, digit-, or underscore-prefixed names are excluded and that a dot- or hyphen-prefixed assignment is reported, or replace `\b` in alternative B with `(?<![\w.-])` (the alternative A lookbehind; reviewer probe shows all existing positive rows, including `$env:NPM_TOKEN`, `export NPM_TOKEN`, and `echo "NPM_TOKEN=x"`, keep matching) and add pinning rows for the dot and hyphen prefixes. | Docstring accuracy; the guard over-reports, so there is no security exposure. | Reviewer probe (`env.NPM_TOKEN += x` new=True, `MY-NPM_TOKEN+=x` new=True); file read lines 46-48, 121-138 |
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 244-258 and 271-293 | Accepted outcomes of the new `\+?` are not pinned: `(( NPM_TOKEN += 1 ))` and `NPM_TOKEN +=x` are reported; `NPM_TOKEN++=x` and `NPM_TOKEN+ =x` are not. | Add an `arithmetic-compound-append` row expecting `[1]` beside `arithmetic-increment`, so both bash arithmetic outcomes are characterized. | Makes a future change to these outcomes visible, in line with the purpose stated in the pinned-residual docstring. | Reviewer probe |
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 306-307 | The docstring ends "These rows characterize existing behavior", while the `bash-append-reported` row characterizes behavior introduced by #933. | Optional wording such as "These rows pin the current behavior". | Precision only. | File read |
| Info | `tests/scripts/dev_tools/npm_token_guard_test_support.py` | line 11 | The module docstring attributes the assignment family to issues #712 and #739 only; #845 and #933 refinements are cited in the function docstring. | No action required. | Traceability is present at function level. | File read |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

- **Correctness:** `\bNPM_TOKEN\s*\+?=(?!=)`. For `NPM_TOKEN+==x` the engine first tries `\+?` = `+`, matches `=`, and fails the `(?!=)` lookahead; it then backtracks to `\+?` empty and fails `=` against `+`. No match, as pinned. For `NPM_TOKEN++` the `=` never follows a single `+`. For `NPM_TOKEN_V2+=x`, `\s*\+?=` cannot match `_`. For `NPM_TOKEN == ''`, `\s*` backtracking cannot avoid either the lookahead or the space, so no match.
- **Performance:** The added optional token introduces no nested quantifier; no catastrophic-backtracking risk.
- **Typing:** No signature change; pyright 0 errors (reviewer rerun).
- **Suppressions:** None added.
- **Scope:** Alternative A and finders 1 to 3 are unchanged (diff read), as `issue.md` line 59 requires.
- **File size:** 180 and 400 lines.

### TypeScript implementation audit

N/A: no TypeScript file changed.

### PowerShell implementation audit

N/A: no PowerShell file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-before.2026-10-16T00-25.md`: 4 failed, 62 passed; the four failing nodes are exactly the three AC-1 rows and the AC-2 row (lines 59-61, 75, 291-295).
- `evidence/regression-testing/pass-after.2026-10-16T00-27.md`: 66 passed.
- `evidence/qa-gates/final-loop-single-pass.2026-10-16T00-35.md`: single clean pass after one Black reflow.
- `evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md`: coverage at or above baseline; no production file changed.
- `evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md`; reviewer grep confirms `residual-bash-append-not-reported` no longer occurs under `tests/` or `scripts/`.

### Quality assessment prompts

- **Determinism:** No clock, sleep, randomness, network, or temporary-file use (reviewer grep).
- **Isolation:** One input string and one finder per row.
- **Speed:** 66 rows in 0.29s.
- **Diagnostics:** Assertion messages include the ASCII-escaped input and actual result.
- **Arrange-Act-Assert:** Markers present in all three affected test functions.

---

## Security / Correctness Checks

- The change widens detection only; no previously reported input becomes unreported (reviewer probe, old versus new).
- The repository tree-scan rows (`test_github_yaml_files_contain_no_npm_token_route[*]`) pass, so no current file under `.github/` is newly reported.
- No secret, credential, or `.env` file is added.
- No workflow file changed; the `modified-workflow-needs-green-run` rule does not apply.

---

## Research Log

- `issue.md` lines 57-69 (adopted approach D1 and AC-1 to AC-9).
- `research/research.2026-10-15T17-50.md` (proposed pattern).
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 57: plan files are stamped in America/New_York and are outside the UTC evidence filename rule, so `plan.2026-10-15T17-44.md` is compliant.
- `quality-tiers.yml`: `tests/` falls under the root `.` entry (T4); no property-test obligation.

---

## Verdict

**Approve.** 0 blocking findings. One Minor and two Nit findings are recommended for resolution inside this item; one Info finding needs no action.
