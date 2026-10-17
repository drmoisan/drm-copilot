# Feature Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933`
**Work Mode:** `minor-audit`
**Audit Type:** Remediation cycle 1 re-review (reaudit, feature-vs-base)

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- **Head branch/commit:** `bug/npm-token-guard-misses-append-assignment-933` (commit `9421a9b7a4cc4817486976b9023d62ed89a7f71c`, pushed)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (Head SHA `9421a9b7a4cc4817486976b9023d62ed89a7f71c`; fresh at HEAD) and `artifacts/pr_context.appendix.txt`
  - Direct diff: `git diff origin/main...HEAD` (90 files; outside the feature folder only `M tests/scripts/dev_tools/npm_token_guard_test_support.py` and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py`)
  - Cycle 1 inputs and plan: `remediation-inputs.2026-10-16T00-56.md`, `remediation-plan.2026-10-16T00-56.md` (52/52 tasks)
  - Feature evidence: `evidence/baseline/*`, `evidence/regression-testing/*`, `evidence/qa-gates/*`, `evidence/remediation-baseline/rc1-*`, `evidence/other/rc1-phase1-handoff.2026-10-16T01-39.md`
  - Reviewer reruns: guard module pytest (70 passed), black check, ruff, pyright (all clean), `validate_evidence_locations.py` (exit 0), lcov recomputation (93.7975% / 88.1124%), in-memory regex probe over 24 inputs (0 mismatches)
- **Feature folder used:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only
- **Work mode resolution note:** `issue.md` line 12 states `- Work Mode: minor-audit`. `spec.md` and `user-story.md` are absent, which is correct for minor-audit.
- **Scope note:** Operator decision D1 (`issue.md` line 59) reverses the #845 non-goal for bash `NPM_TOKEN+=x`. Decision D4 keeps the regex unchanged in cycle 1. Neither is a finding.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md` — only source (`## Acceptance Criteria`, AC-1 to AC-9, checkbox format, lines 61-69)

### Acceptance criteria

AC-1 to AC-9 as written in `issue.md` lines 61-69. The evaluation table uses the AC number and a short label.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC-1 | Append form reported; three detection rows expect `[1]` | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:224-228` rows `bash-append-secret-expression`, `shell-export-append`, `powershell-env-append`; reviewer rerun 70 passed | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | Cycle 1 added three further detection rows (lines 229-231); AC-1 rows unchanged |
| AC-2 | Pinned row flipped to `[1]` and renamed `bash-append-reported`; old id absent | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:288`; `evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md`; `evidence/remediation-baseline/rc1-baseline-id-absence.2026-10-16T01-32.md` | Grep | Cycle 1 did not reintroduce the old id |
| AC-3 | No existing negative or residual outcome changes; non-regression rows expect `[]` | PASS | All pre-existing rows pass (reviewer rerun); `NPM_TOKEN+==x` (lines 294-296), `NPM_TOKEN_V2+=x` (line 259), `(( NPM_TOKEN++ ))` (line 260) expect `[]` and pass; regex unchanged in cycle 1 (`evidence/qa-gates/rc1-regex-unchanged.2026-10-16T02-13.md`) | pytest; reviewer probe | Cycle 1 adds `double-plus-equals-not-reported` (line 261) |
| AC-4 | Repository tree-scan tests still pass | PASS | `test_github_yaml_files_contain_no_npm_token_route[*]` pass within the 70 (reviewer rerun) | pytest | No file under `.github/` changed |
| AC-5 | Stale statements corrected in both docstrings | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:302-311` records the #933 reversal and that `=` and `=~` remain reported; `tests/scripts/dev_tools/npm_token_guard_test_support.py:122-141` states that `+=` appends are reported and that `==` and `+==` are not; reviewer probe confirms every claim in that docstring | File read; probe | The prior CR-1 inaccuracy in the same docstring is resolved (F1) |
| AC-6 | Fail-before / pass-after evidence | PASS | `evidence/regression-testing/fail-before.2026-10-16T00-25.md` (4 failed, the AC-1 and AC-2 rows); `pass-after.2026-10-16T00-27.md` (66 passed); cycle 1 `rc1-pass-after.2026-10-16T01-42.md` (70 passed) | File read | |
| AC-7 | Python toolchain clean; coverage not below baseline and meets thresholds; empty production diff | PASS | black/ruff/pyright clean (reviewer rerun; `evidence/qa-gates/rc1-final-*.2026-10-16T01-44.md`); full suite 7104 passed, 0 failed (`rc1-final-pytest-coverage.2026-10-16T01-47.md`); 93.79748% line / 88.11244% branch, equal to the original baseline (`evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md`) and above 85/75 (`rc1-coverage-comparison.2026-10-16T02-11.md`; reviewer lcov recomputation); `git diff --name-only origin/main...HEAD -- src scripts` empty (reviewer rerun) | `poetry run black --check`, `ruff check --no-fix`, `pyright`, lcov awk | Branch figure is one partial branch below the cycle-entry run; D6 compares against the original baseline. Judged sound; rationale observation CR-5 / PA-5 is non-blocking |
| AC-8 | Both changed files at or under 500 lines | PASS | Reviewer `wc -l`: 184 and 404; `evidence/qa-gates/rc1-line-count.2026-10-16T02-13.md` | `wc -l` | Longest lines 87 and 88 characters |
| AC-9 | `quality-checks7` passes on the PR head | UNVERIFIED (pending CI, non-blocking) | No CI result on the PR head is available to this review | Not runnable before CI runs on the PR head | CI-dependent criterion; the item's orchestrator run checks it off at S9 after `ci_gate.conclusion` is `success` |

---

## Remediation Cycle 1 Closure

| Input finding | Status | Evidence |
|---|---|---|
| F1 (CR-1 / PA-1) docstring accuracy and prefixed pinning rows | Resolved | Docstring lines 127-134; rows `dot-prefixed-append-reported`, `hyphen-prefixed-append-reported` (lines 229-230); `rc1-rows-f1.2026-10-16T01-40.md`; reviewer probe |
| F2 (CR-2 / PA-2) arithmetic compound append and `++=` rows | Resolved | Rows at lines 231 and 261; `rc1-rows-f2-detect.2026-10-16T01-40.md`, `rc1-rows-f2-ignore.2026-10-16T01-41.md` |
| F3 (CR-3) pinned-residual docstring wording | Resolved | Lines 310-311; `rc1-docstring-f3.2026-10-16T02-13.md` |
| Exit condition: single-pass toolchain loop and coverage floor | Met under D6 | `rc1-final-loop-single-pass.2026-10-16T01-48.md`; `rc1-coverage-comparison.2026-10-16T02-11.md` |

---

## Summary

Remediation cycle 1 resolved F1, F2, and F3 without changing the regex (D4). The rewritten `find_npm_token_assignments` docstring is accurate for every behavior the reviewer probed, the new rows pin the prefixed, arithmetic-compound, and `++=` outcomes, and both changed files remain within 500 lines and 88 characters per line. No production file changed, and coverage equals the original pre-change baseline.

AC-1 to AC-8: PASS. AC-9: pending PR CI (CI-dependent, non-blocking at this stage).

Non-blocking findings:
- CR-5 / PA-5 (Minor): the D6 floor is sound, but its rationale ("tracks test-file changes only", "not nondeterminism") is not supported by an identified mechanism or branch; track the one-partial-branch variance as a separate determinism follow-up.
- CR-6 (Info): non-matching test docstring wording; no action required.
- CR-4 (Info, carried): no action required.

**Overall verdict:** PASS. Blocking findings: 0. No remediation inputs are required.

---

## Acceptance Criteria Check-off

- AC-1 to AC-8 were already checked off in `issue.md` (lines 61-68). The reviewer evaluated each as PASS; no change to `issue.md` was needed.
- AC-9 remains unchecked (`issue.md` line 69); it is CI-dependent and is owned by the item's orchestrator run at S9.
- No AC item was newly checked off by this review.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md`
- Total AC items: 9
- Checked off (delivered): 8
- Remaining (unchecked): 1
- Items remaining: AC-9: The CI job `quality-checks7` (Code Quality & Tests) passes on the PR head (CI-dependent).
