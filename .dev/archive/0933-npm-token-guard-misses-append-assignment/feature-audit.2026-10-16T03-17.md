# Feature Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933`
**Work Mode:** `minor-audit`
**Audit Type:** Remediation cycle 2 re-review (reaudit, feature-vs-base)

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- **Head branch/commit:** `bug/npm-token-guard-misses-append-assignment-933` (commit `987161b95518fb0b621910c14a6f93861627b91e`, pushed)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 03:13:37 UTC; Head SHA `987161b95518fb0b621910c14a6f93861627b91e`; fresh at HEAD) and `artifacts/pr_context.appendix.txt`
  - Direct diff: `git diff origin/main...HEAD` (137 files; outside the feature folder only `M tests/scripts/dev_tools/npm_token_guard_test_support.py` and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py`)
  - Cycle 2 inputs and plan: `remediation-inputs.2026-10-16T02-27.md`, `remediation-plan.2026-10-16T02-27.md` (50/50 tasks)
  - Feature evidence: `evidence/baseline/*`, `evidence/regression-testing/*`, `evidence/qa-gates/*`, `evidence/remediation-baseline/rc2-*`, `evidence/qa-gates/rc2-*`
  - Reviewer reruns: guard module pytest (70 passed), black check, ruff, pyright (all clean), `validate_evidence_locations.py` (exit 0), lcov recomputation (93.7975% / 88.1124%), docstring-stripped AST comparison of both test-tree files between `6cb038e9e` and HEAD (code equal)
- **Feature folder used:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only
- **Work mode resolution note:** `issue.md` line 12 states `- Work Mode: minor-audit`. `spec.md` and `user-story.md` are absent, which is correct for minor-audit.
- **Scope note:** Operator decision D1 (`issue.md` line 59) reverses the #845 non-goal for bash `NPM_TOKEN+=x`. Decision D4 keeps the regex unchanged in both remediation cycles. Neither is a finding.

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
| AC-1 | Append form reported; three detection rows expect `[1]` | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:224-228` rows `bash-append-secret-expression`, `shell-export-append`, `powershell-env-append`; reviewer rerun 70 passed | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | Rows unchanged in cycle 2 (AST check) |
| AC-2 | Pinned row flipped to `[1]` and renamed `bash-append-reported`; old id absent | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:288`; `evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md` | Grep | Cycle 2 changed no test id |
| AC-3 | No existing negative or residual outcome changes; non-regression rows expect `[]` | PASS | All pre-existing rows pass (reviewer rerun); `NPM_TOKEN+==x` (lines 294-296), `NPM_TOKEN_V2+=x` (line 259), `(( NPM_TOKEN++ ))` (line 260) expect `[]` and pass; regex unchanged (`evidence/qa-gates/rc2-regex-unchanged.2026-10-16T03-09.md`) | pytest; regex digest probe | Cycle 2 rewrote only the non-matching test's docstring |
| AC-4 | Repository tree-scan tests still pass | PASS | `test_github_yaml_files_contain_no_npm_token_route[*]` pass within the 70 (reviewer rerun) | pytest | No file under `.github/` changed |
| AC-5 | Stale statements corrected in both docstrings | PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:302-311` records the #933 reversal and that `=` and `=~` remain reported; `tests/scripts/dev_tools/npm_token_guard_test_support.py:122-141` states that `+=` appends are reported and that `==` and `+==` are not (line 132 now reads "a ``+==`` sequence", F5) | File read | Cycle 2 improved wording without changing any claim |
| AC-6 | Fail-before / pass-after evidence | PASS | `evidence/regression-testing/fail-before.2026-10-16T00-25.md` (4 failed, the AC-1 and AC-2 rows); `pass-after.2026-10-16T00-27.md` (66 passed); cycle 2 `rc2-after-edit.2026-10-16T03-01.md` (70 passed) | File read | |
| AC-7 | Python toolchain clean; coverage not below baseline and meets thresholds; empty production diff | PASS | black/ruff/pyright clean (reviewer rerun; `evidence/qa-gates/rc2-final-*.2026-10-16T03-03.md`); full suite 7104 passed, 0 failed (`rc2-final-pytest-coverage.2026-10-16T03-07.md`); 93.79748% line / 88.11244% branch, equal to the original baseline (`evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md`) and above 85/75 (`rc2-coverage-comparison.2026-10-16T03-08.md`; reviewer lcov recomputation); `git diff --name-only origin/main...HEAD -- src scripts` empty (`rc2-coverage-comparison.2026-10-16T03-08.md`) | `poetry run black --check`, `ruff check --no-fix`, `pyright`, lcov awk | New/changed production-code coverage PASS: 0 production lines changed |
| AC-8 | Both changed files at or under 500 lines | PASS | 184 and 404 lines (`evidence/qa-gates/rc2-line-count.2026-10-16T03-09.md`; reviewer line scan) | `grep -c ""` | Longest lines 87 and 88 characters |
| AC-9 | `quality-checks7` passes on the PR head | UNVERIFIED (pending CI, non-blocking) | No CI result on the PR head is available to this review | Not runnable before CI runs on the PR head | CI-dependent criterion; the item's orchestrator run checks it off at S9 after `ci_gate.conclusion` is `success` |

---

## Remediation Cycle 2 Closure

| Input finding | Status | Evidence |
|---|---|---|
| F4 (CR-6) non-matching test docstring | Resolved | Line 265 per D7; `rc2-edit-f4.2026-10-16T02-59.md`, `rc2-docstring-f4.2026-10-16T03-09.md`; reviewer read confirms accuracy for all twelve rows |
| F5 (CR-6) article in support docstring | Resolved | Line 132; `rc2-edit-f5.2026-10-16T03-00.md`, `rc2-docstring-f5.2026-10-16T03-09.md` |
| F6 (CR-5 / PA-5) D6 deviation wording | Resolved | Cycle 1 plan line 242 diff (reviewer); `rc2-f6-old.2026-10-16T03-09.md` (0), `rc2-f6-new.2026-10-16T03-09.md` (1), `rc2-f6-field.2026-10-16T03-09.md` (3) |
| D4: no regex or executable change | Met | Reviewer AST check (code equal); `rc2-changed-lines.2026-10-16T03-09.md`; `rc2-regex-unchanged.2026-10-16T03-09.md` |
| Exit condition: single-pass toolchain loop and D6 floor | Met | `rc2-final-loop-single-pass.2026-10-16T03-08.md`; `rc2-coverage-comparison.2026-10-16T03-08.md` (Verdict PASS) |

---

## Summary

Remediation cycle 2 resolved F4, F5, and F6 by changing two docstring lines and one plan-deviation entry. No executable line, regex, row, id, or assertion changed. Both changed files remain within 500 lines and 88 characters per line. No production file changed, and coverage equals the original pre-change baseline.

AC-1 to AC-8: PASS. AC-9: pending PR CI (CI-dependent, non-blocking at this stage).

Non-blocking findings:
- PA-3 (pending CI): AC-9 check-off at S9.
- CR-7 / PA-6 (Info): cycle 2 plan header Status line is stale; optional correction.
- CR-4 (Info, carried): no action required.

Unrelated follow-ups (not item findings): UF-1 (prd-feature / spec.md residual of minor-audit routing) and UF-2 (production branch behind the 504/505 partial-branch variance). Neither was worsened by this branch.

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
