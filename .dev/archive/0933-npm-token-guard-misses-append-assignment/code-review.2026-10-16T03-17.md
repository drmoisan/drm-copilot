# Code Review: npm token guard misses append assignment (#933)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933` (`987161b95518fb0b621910c14a6f93861627b91e`)
**Review Type:** Remediation cycle 2 re-review (reaudit, feature-vs-base)

**Total blocking findings: 0.**

---

## Executive Summary

The full branch diff changes two Python files in the test tree and no production file. The regex change from the initial cycle (`\bNPM_TOKEN\s*\+?=(?!=)` in alternative B of `_NPM_TOKEN_ASSIGNMENT`, `tests/scripts/dev_tools/npm_token_guard_test_support.py:47`) is unchanged by both remediation cycles, as decision D4 requires.

Remediation cycle 2 (`3da42a36d`) changed exactly three lines outside its evidence: the docstring of `test_find_npm_token_assignments_ignores_non_matching_text` (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py:265`, F4), one docstring line of `find_npm_token_assignments` (`tests/scripts/dev_tools/npm_token_guard_test_support.py:132`, F5), and the revision 1.1 deviation entry of the cycle 1 plan (line 242, F6). A reviewer AST comparison with docstrings removed reports both test-tree files identical between `6cb038e9e` and HEAD, so no executable line changed.

F4, F5, and F6 are resolved. CR-5 is closed as far as this item's wording is concerned, and CR-6 is closed. One new Info observation concerns the stale Status line in the cycle 2 plan header (CR-7).

**Top 3 risks:**
1. AC-9 depends on PR CI and cannot be verified until CI runs on the PR head.
2. The full-suite partial-branch count varies between 504 and 505 on identical production source (UF-2, tracked outside this item); the D6 floor is met exactly by the cycle 2 run.
3. Over-reporting of dot- and hyphen-prefixed assignments is retained by design (D4); it fails closed and is documented and pinned.

**PR readiness recommendation:** **Ready**.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (Non-blocking) | `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T02-27.md` | lines 8-9 | CR-7: The header reads `Status: Authored; awaiting preflight` and `Version: 1.0`, while all 50 tasks are checked and "Plan Deviations" records revision 1.2. D9 accepts the Version value; the Status value is not covered by D9. | Optionally set the Status line to a completed state. | Header accuracy for later readers; no behavior or evidence impact. | File read; `grep -c '^- \[x\]'` = 50, `grep -c '^- \[ \]'` = 0 |
| Info | `tests/scripts/dev_tools/npm_token_guard_test_support.py` | line 11 | CR-4 (carried): the module docstring attributes the assignment family to issues #712 and #739 only. | No action required. | Traceability is present at function level. | File read |

No Blocker, Major, or Minor findings.

### Closure of prior findings

| Prior finding | Cycle input | Status | Verification |
|---|---|---|---|
| CR-6 (test docstring) | F4 | Closed | Line 265: "Text with no assignment operator applied to ``NPM_TOKEN`` is not reported." (84 characters). Accurate for every row at lines 250-261: context reads, prose, and the empty string carry no operator; `==` and `!=` are comparisons; the `:`/`+=` in `NPM_TOKEN_V2: x`, `MY_NPM_TOKEN: x`, and `NPM_TOKEN_V2+=x` apply to a different name; `++` in `(( NPM_TOKEN++ ))` is an increment operator, which the bash manual lists separately from the assignment operators; `NPM_TOKEN++=x` is not a valid shell assignment. Executor probe `rc2-docstring-f4.2026-10-16T03-09.md` prints `False True True`. |
| CR-6 (article) | F5 | Closed | Line 132: "comparison, a ``+==`` sequence, a name extended by a letter, digit, or"; probe `rc2-docstring-f5.2026-10-16T03-09.md` prints `False True True`. |
| CR-5 (D6 rationale) | F6 | Closed for this item's wording | The cycle 1 plan entry now states only what the runs show (505, 504, 504, 505 partial branches on identical production source), that the responsible branch is not identified, and that the D6 floor does not depend on the cause. The claims "tracks test-file changes" and "not nondeterminism" are absent (reviewer grep; `rc2-f6-old.2026-10-16T03-09.md`). Identifying the branch is UF-2, outside this item. |

---

## Implementation Audit

### Python implementation audit

- **Correctness:** No executable change in cycle 2. Reviewer AST check (docstrings removed) reports `code_ast_equal= True` for both files between `6cb038e9e` and HEAD; the regex digest `bc428627...d445` with flags 34 is unchanged (`rc2-regex-unchanged.2026-10-16T03-09.md`). The rewritten docstrings match the pattern's behavior verified in the cycle 1 reaudit probe.
- **Performance:** No change.
- **Typing:** No signature change; pyright 0 errors (reviewer rerun).
- **Suppressions:** None added.
- **Scope:** Cycle 2 changed only the three permitted lines plus cycle 2 inputs, plan, and `rc2-` evidence (`git diff --stat 6cb038e9e..HEAD`, reviewer rerun; `rc2-cycle-scope.2026-10-16T03-10.md`). `issue.md` unchanged (`rc2-issue-unchanged.2026-10-16T03-09.md`).
- **File size and width:** 184 and 404 lines; no line over 88 characters in either file (reviewer AST script line scan; `rc2-line-width.2026-10-16T03-09.md` prints `87 88`).

### TypeScript implementation audit

N/A: no TypeScript file changed.

### PowerShell implementation audit

N/A: no PowerShell file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/qa-gates/rc2-after-edit.2026-10-16T03-01.md`: line-level probe `(242, 242, [242]) (184, 184, [132]) (404, 404, [265])`, regex digest unchanged, 70 passed.
- `evidence/qa-gates/rc2-final-loop-single-pass.2026-10-16T03-08.md`: single clean pass of black, ruff, pyright, guard pytest, full-suite coverage, threshold gate, and percentage readout.
- `evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md`: 7104 passed, 6 skipped; TOTAL 17638 / 1094 / 6368 / 505.
- `evidence/qa-gates/rc2-coverage-comparison.2026-10-16T03-08.md`: Verdict PASS under D6; production-file listings empty.
- `evidence/qa-gates/rc2-f6-old.2026-10-16T03-09.md`, `rc2-f6-new.2026-10-16T03-09.md`, `rc2-f6-field.2026-10-16T03-09.md`: `0`, `1`, `3` as the plan requires.

### Quality assessment prompts

- **Determinism:** The changed tests use no clock, sleep, randomness, network, or temporary file.
- **Isolation:** One input string and one finder per row.
- **Speed:** 70 rows in 0.14s (reviewer rerun).
- **Diagnostics:** Assertion messages include the ASCII-escaped input and actual result.
- **Arrange-Act-Assert:** Markers present in the affected test function.

---

## Security / Correctness Checks

- The regex is unchanged in both remediation cycles, so detection breadth equals the initial review; relative to `origin/main` the change only widens detection.
- The repository tree-scan rows pass (70 passed), so no file under `.github/` is newly reported.
- No secret, credential, `.env` file, or workflow change.

---

## Research Log

- `remediation-inputs.2026-10-16T02-27.md` (F4-F6, scope, exit condition).
- `remediation-plan.2026-10-16T02-27.md` (50/50 tasks; "Exact Text for Phase 1" with the D7 rationale; "Plan Deviations" revision 1.2 for D8).
- `remediation-plan.2026-10-16T00-56.md` line 242 (F6 target), diffed against `6cb038e9e`.
- Prior review set `code-review.2026-10-16T02-19.md`.

---

## Verdict

**Approve.** 0 blocking findings. CR-5 and CR-6 are closed. CR-7 and CR-4 are Info and need no action for merge.
