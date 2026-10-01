# Feature Audit: potential_to_issue file-size decomposition (#406)

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406`
**Base Branch:** `main`
**Head Branch:** `bug/potential-to-issue-python-files-oversized-406`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (replaces the structurally invalid pass dated 2026-09-30T14-10; conclusions re-verified)

---

## Scope and Baseline

- **Base branch:** `main` (merge base commit `2b0121abf74f5862a3d12929d833504668941156`)
- **Head branch/commit:** `bug/potential-to-issue-python-files-oversized-406` (commit `c9b3cb67da0d673f850d125b031c2552e92a7ca2`)
- **Merge base:** `2b0121abf74f5862a3d12929d833504668941156`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (records head SHA `c9b3cb67...` and the merge base above, so it is current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: reviewer re-runs at head (Black, Ruff, Pyright, Pytest, `pytest --collect-only`, `wc -l`, `validate_evidence_locations.py`) and `artifacts/python/lcov.info`
- **Feature folder used:** `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406`
- **Requirements source:** `issue.md`
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: minor-audit`; the authoritative acceptance criteria are the checkbox items under `## Acceptance Criteria` in `issue.md`. Other checkbox sections (Impact, Proposed Fix, Next Step) are not treated as acceptance criteria.
- **Scope note:** The audit covers the full branch diff against the merge base: eight non-documentation Python paths (two production, six test) plus feature-folder documents. No path under `extensions/` changed. Plan deviations D1 to D4 in `plan.2026-09-29T14-12.md` (post-#623 adaptation) were reviewed and do not weaken any criterion.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/issue.md` — only source (checkbox-backed)

### Acceptance criteria

1. `scripts/dev_tools/potential_to_issue.py` is decomposed to <= 500 lines per file, preserving public behavior.
2. `tests/scripts/dev_tools/test_potential_to_issue.py` is decomposed to <= 500 lines per file, preserving test coverage.
3. TS/Python config-parity test continues to pass (no behavioral drift introduced by the split).
4. Full Python toolchain (Black → Ruff → Pyright → Pytest) passes with no coverage regression.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Production module decomposed to <= 500 lines per file, behavior preserved | PASS | `potential_to_issue.py` 438 lines (baseline 559) and `potential_to_issue_adapters.py` 154 lines. The fifteen previously public names are re-exported through `__all__`; the diff shows a verbatim move. `evidence/qa-gates/cli-help-smoke.md` records `usage: potential_to_issue.py` output. | `wc -l scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_adapters.py` | Re-measured at head by the reviewer. |
| 2 | Test file decomposed to <= 500 lines per file, test coverage preserved | PASS | `test_potential_to_issue.py` 282 lines (baseline 1076); split and helper files 116, 288, 235, 138, 295 lines. Collected tests 59 before and after with identical sorted names (`evidence/qa-gates/collected-count.md`). | `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_potential_to_i*.py` | Reviewer re-collected 59 tests. No scenario removed. |
| 3 | TS/Python config-parity test continues to pass | PASS | Jest parity run recorded at baseline and post-change: 9 suites and 131 tests, equal (`evidence/baseline/jest-parity.md`, `evidence/qa-gates/jest-parity.md`). The diff contains no `extensions/` path, and the Python behavior is a verbatim move. | `npm --prefix extensions/drm-copilot run test:unit -- test/lib/potential-to-issue test/extension.potential-to-issue.test.ts` | The Jest result is taken from the recorded artifact and was not rerun. No TypeScript file changed, so drift on that side is not possible from this branch. |
| 4 | Python toolchain passes with no coverage regression | PASS | Reviewer re-runs: Black 533 files unchanged; Ruff all checks passed; Pyright 0 errors, 0 warnings, 0 informations; Pytest 59 passed. Coverage: uncovered lines 4 to 4; partial branches 10 to 10; computed line cover 98.68% to 98.71%; adapters module 100.0% lines and 75.0% branches (`evidence/qa-gates/coverage-delta.md`, `artifacts/python/lcov.info`). | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py` | Coverage generation was not rerun; the lcov artifact was parsed. The coverage artifact is scoped to four modules, so the repo-wide Python percentage is not derived. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 4 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the pre-merge CI run on the branch head is green (repo-wide Python coverage is evaluated there, because the local artifact is scoped to four modules).
2. Optionally record accurate system-clock timestamps in future executor evidence files (code review finding M1).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/issue.md`
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/issue.md` | 4 | 4 | 0 | Checkbox-backed; authoritative for `minor-audit` |

All four items were already checked in `issue.md` at head (commit `c9b3cb67`). Each was re-evaluated PASS in this audit, so no source-file change was needed and none was made.
