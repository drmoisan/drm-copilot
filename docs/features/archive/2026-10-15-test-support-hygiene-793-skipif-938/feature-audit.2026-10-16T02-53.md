# Feature Audit: Test-support hygiene and stale skipif (#938)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main`
**Head Branch:** `bug/test-support-hygiene-793-skipif-938`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit after remediation cycle 2

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (merge base `97559c3e0`)
- **Head branch/commit:** `bug/test-support-hygiene-793-skipif-938` (`c8281987b`)
- **Evidence sources:**
  - Primary: full branch diff against `origin/main` (12 non-documentation files) and the cycle 2 commit diff, read directly by the reviewer
  - Feature evidence: `evidence/baseline/**`, `evidence/remediation-baseline/**`, `evidence/regression-testing/**`, `evidence/qa-gates/**`, `evidence/other/**`
  - Coverage: `artifacts/python/lcov.info` (93.80% line, 88.13% branch); TypeScript `evidence/qa-gates/ts-jest-coverage.2026-10-16T01-42.md` (97.26% line, 92.28% branch)
- **Requirements source:** `issue.md` `## Acceptance Criteria` only (work mode `minor-audit`, marker on line 12)
- **Remediation inputs addressed:** RI-2 (dispatch test imports from two modules) and RI-3 (three builders remained in the old module) from `remediation-inputs.2026-10-16T02-07.md`.

---

## Acceptance Criteria Inventory

Ten checkbox items under `## Acceptance Criteria` in `issue.md`, labelled AC-1 to AC-10 in document order.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Support module with both builders, verbatim | PASS | Module exists (285 lines); `build_valid_epic_state` at line 12 and `build_read_text_stub` at line 54; cycle 2 only added three further builders | Grep `def build_` over the module | Original builders unchanged by cycle 2 |
| AC-2 | No `test_*.py` defines either builder | PASS | Reviewer Grep over `tests/` for the five builder names returns definitions only in the support module for the two #793 builders | Grep `def build_(valid_epic_state\|read_text_stub)` | Cycle 2 also removed the three additional builders from the old module (`cycle2-builder-def-negative`: `[]`) |
| AC-3 | No cross-test-module builder imports; four named modules import from support module | PASS | Grep for `test_validate_orchestration_artifacts import` returns nothing; merge_status, dispatch, plan_gates, parallel_dispatch import from the support module; dispatch imports all four builders only from it | AST searches in `cycle2-importer-ast-negative` and `cycle2-importer-ast-positive` | RI-2 closed; no re-export |
| AC-4 | Docstring and TypeScript comment cite the support module | PASS | Unchanged since the prior audit; the cycle 2 diff does not touch either file | Prior-cycle grep evidence | |
| AC-5 | Parity file has no `skipif`, `_requires_codex_runtime`, or unused `import pytest` | PASS | Reviewer Grep count 0 on the parity file | `grep -c` | Not touched in cycle 2 |
| AC-6 | Parity file: five passed, none skipped | PASS | Cycle 1 evidence; the cycle 2 ten-file group (which includes it) reports 135 passed and 0 skipped | `poetry run pytest <file> -q -rs` | |
| AC-7 | Named files pass; count not below baseline | PASS | Ten-file group: 135 collected, 135 passed, equal to the cycle 2 baseline (`cycle2-pytest-ten-files-coverage.2026-10-16T02-50.md`); full suite 7099 passed, 6 skipped, 0 failed | `poetry run pytest <files>` | The 7094 count in the remediation input predated #940 tests |
| AC-8 | Black, Ruff, Pyright clean on every touched Python file | PASS | `cycle2-black-check`, `cycle2-ruff-check`, `cycle2-pyright` (all 02-50) exit 0 on the four cycle 2 files; earlier cycles cover the rest | commands recorded in evidence | |
| AC-9 | TypeScript toolchain passes | PASS | `prettier-check`, `eslint`, `tsc-src`, `tsc-test`, `jest-epic-core`, `ts-jest-coverage` exit 0; the TypeScript file is not modified in cycle 2 | commands recorded in evidence | |
| AC-10 | Every touched or created file at most 500 lines | PASS | Cycle 2 files: 285, 144, 278, 154 (reviewer `wc -l`); the largest earlier touched file is 475 | `wc -l` | |

---

## Summary

All ten acceptance criteria are PASS. Remediation findings RI-2 and RI-3 are closed: the dispatch test imports shared builders only from `validate_orchestration_artifacts_test_support`, and the three remaining builders live in that module with unchanged bodies, signatures, and no re-export. The change is test-only and the test count is not lower than baseline.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/issue.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none

---

## Acceptance Criteria Check-off

All ten items under `## Acceptance Criteria` were already `- [x]` at review start. The reviewer verified each independently and found none to uncheck. No newly checked-off items. The `Proposed Fix / Validation Ideas` and `Next Step` checkbox sections are not acceptance criteria for `minor-audit` and remain unchecked.

---

## Non-blocking Observations

- The remediation-input baseline of 7094 passed differs from the cycle 2 result of 7099 passed because #940 tests were merged from `origin/main`; no test failed and no skip count changed (6).
- `evidence/qa-gates/cycle2-pyright.2026-10-16T02-41.md` and the 02-41/02-42 loop artifacts record an environmental Pyright failure and are superseded by the 02-50/02-51 artifacts.
