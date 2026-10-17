# Feature Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-token-guard-misses-append-assignment-933`
**Work Mode:** `minor-audit`
**Audit Type:** Initial feature review (feature-vs-base)

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- **Head branch/commit:** `bug/npm-token-guard-misses-append-assignment-933` (commit `5afda6fc7b0e168a13634f366e8f568bc2f4cd9e`, pushed)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (equals the `origin/main` tip)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (Head SHA `5afda6fc7b0e168a13634f366e8f568bc2f4cd9e`, merge base `adb9aa5f0`; fresh at HEAD) and `artifacts/pr_context.appendix.txt`
  - Direct diff: `git diff origin/main...HEAD` (42 files; outside the feature folder only `M tests/scripts/dev_tools/npm_token_guard_test_support.py` and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py`)
  - Feature evidence: `evidence/baseline/*`, `evidence/regression-testing/*`, `evidence/qa-gates/*`, `evidence/other/phase1-handoff.2026-10-16T00-22.md`
  - Reviewer reruns: guard module pytest (66 passed), black check, ruff, pyright (all clean), `validate_evidence_locations.py` (exit 0), lcov recomputation (93.80% / 88.13%), in-memory regex probe
- **Feature folder used:** `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only
- **Work mode resolution note:** `issue.md` line 12 states `- Work Mode: minor-audit`. `spec.md` and `user-story.md` are absent, which is correct for minor-audit.
- **Scope note:** Operator decision D1 (`issue.md` line 59) reverses the #845 non-goal for bash `NPM_TOKEN+=x`; this is the intended behavior change and is not a finding.

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
| AC-1 | Append form reported; three new detection rows expect `[1]` | PASS | `test_workflow_npm_token_guard.py:224-228` rows `bash-append-secret-expression`, `shell-export-append`, `powershell-env-append`; all PASSED in `pass-after.2026-10-16T00-27.md` | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` (reviewer: 66 passed) | Reviewer probe confirms all three inputs match the new pattern and not the old |
| AC-2 | Pinned row flipped to `[1]` and renamed `bash-append-reported`; old id absent | PASS | `test_workflow_npm_token_guard.py:284`; reviewer grep for `residual-bash-append-not-reported` under `tests/` and `scripts/` returns nothing; `evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md` | Grep | |
| AC-3 | No existing negative or residual outcome changes; new non-regression rows expect `[]` | PASS | All pre-existing rows pass (`pass-after.2026-10-16T00-27.md`); `fail-before.2026-10-16T00-25.md` lines 291-295 show only the four AC-1/AC-2 rows failing; new rows `longer-name-append`, `arithmetic-increment` (lines 256-257) and `accepted-append-double-equals-not-reported` (lines 290-292) pass | pytest; reviewer probe | Non-blocking related observations CR-1 and CR-2 in the code review concern untested and docstring-described edges, not existing rows |
| AC-4 | Repository tree-scan tests still pass | PASS | `test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` and the other three family rows PASSED (`pass-after.2026-10-16T00-27.md`; reviewer rerun) | pytest | No file under `.github/` changed |
| AC-5 | Stale statements corrected in both docstrings | PASS | `test_workflow_npm_token_guard.py:298-308` records the #933 reversal and that `=` and `=~` remain reported; `npm_token_guard_test_support.py:125-130` states `+=` reported and `==`, `+==` not reported; `evidence/qa-gates/ac5-docstring-pin.2026-10-16T00-37.md`, `ac5-docstring-support.2026-10-16T00-37.md` | File read | The prefixed-name sentence in the same docstring is imprecise for dot- and hyphen-prefixed assignments (code review CR-1, non-blocking, pre-existing behavior); the criterion's required statements are present |
| AC-6 | Fail-before / pass-after evidence | PASS | `evidence/regression-testing/fail-before.2026-10-16T00-25.md` (EXIT_CODE 1, 4 failed / 62 passed, failing nodes are the AC-1 and AC-2 rows); `pass-after.2026-10-16T00-27.md` (EXIT_CODE 0, 66 passed) | File read | Both stamps precede the test commit `10399c2b0` (00:28 UTC) |
| AC-7 | Python toolchain clean; coverage not below baseline and meets thresholds; empty production diff | PASS | black/ruff/pyright clean (reviewer rerun and `final-*.2026-10-16T00-30.md`); full suite 7100 passed, 0 failed (`final-pytest-coverage.2026-10-16T00-34.md`); 93.80% line / 88.13% branch versus baseline 93.80% / 88.11% (`coverage-comparison.2026-10-16T00-36.md`; reviewer lcov recomputation); `git diff --name-only origin/main...HEAD -- src scripts` empty (reviewer rerun) | `poetry run black --check`, `ruff check --no-fix`, `pyright`, lcov awk | |
| AC-8 | Both changed files at or under 500 lines | PASS | Reviewer `wc -l`: 180 and 400; `evidence/qa-gates/ac8-line-count.2026-10-16T00-38.md` | `wc -l` | |
| AC-9 | `quality-checks7` passes on the PR head | UNVERIFIED (pending CI, non-blocking) | No PR exists yet; `evidence/qa-gates/ac9-ci-pending.2026-10-16T00-39.md` | Not runnable before the PR exists | CI-dependent criterion; the item's orchestrator run checks it off at S9 after `ci_gate.conclusion` is `success` |

---

## Summary

The branch delivers the issue #933 fix: alternative B of `_NPM_TOKEN_ASSIGNMENT` now reports `NPM_TOKEN` append assignments in bash, `export`, and PowerShell forms, the #903 pinned row is flipped and renamed, and non-regression rows pin `+==`, `NPM_TOKEN_V2+=`, and `(( NPM_TOKEN++ ))` as not reported. The change only widens detection; no previously reported input becomes unreported (reviewer probe of old versus new pattern). No production file changed, and coverage is at or above baseline.

AC-1 to AC-8: PASS. AC-9: pending PR CI (CI-dependent, non-blocking at this stage).

Non-blocking findings recommended for resolution inside this item:
- CR-1 (Minor): docstring claim about prefixed names and context reads is inaccurate for `env.NPM_TOKEN += x` and `MY-NPM_TOKEN+=x`; reword, or align alternative B with alternative A's `(?<![\w.-])` lookbehind (reviewer probe shows every existing positive row still matches under that alignment).
- CR-2 (Nit): pin `(( NPM_TOKEN += 1 ))` as reported.
- CR-3 (Nit): "characterize existing behavior" wording in the pinned-residual docstring.

**Overall verdict:** PASS. Blocking findings: 0. No remediation inputs are required.

---

## Acceptance Criteria Check-off

- AC-1 to AC-8 were already checked off in `issue.md` (lines 61-68) by the executor. The reviewer evaluated each as PASS; no change to `issue.md` was needed.
- AC-9 remains unchecked (`issue.md` line 69); it is CI-dependent and is owned by the item's orchestrator run at S9.
- No AC item was newly checked off by this review.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md`
- Total AC items: 9
- Checked off (delivered): 8
- Remaining (unchecked): 1
- Items remaining: AC-9: The CI job `quality-checks7` (Code Quality & Tests) passes on the PR head (CI-dependent).
