# Feature Audit: handoff test independence from archived active directory (#765)

**Audit Date:** 2026-09-28
**Feature Folder:** `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765`
**Base Branch:** `main`
**Head Branch:** `bug/handoff-test-depends-on-archived-active-dir-765`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `5d0b93a0b0a15633b42559827fd7459d65c0b671`)
- **Head branch/commit:** `bug/handoff-test-depends-on-archived-active-dir-765` (commit `a760a7c139aedc53c7c290bd6ab5a30ce3a2e302`)
- **Merge base:** `5d0b93a0b0a15633b42559827fd7459d65c0b671`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/evidence/**`
  - Additional evidence: reviewer re-run of `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (13 passed)
- **Feature folder used:** `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765`
- **Requirements source:** `issue.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `Work Mode: minor-audit`; the acceptance criteria are the `## Acceptance Criteria` section of `issue.md`.
- **Scope note:** Full branch diff against the resolved base. CI status was not available at review time.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/issue.md` — only source

### Acceptance criteria

1. `test_plan_directory_rediscovery_blocks_before_write` no longer references `docs/features/active` and passes when no `docs/features/active/` directory exists.
2. The test still asserts that a directory plan path is rejected with `HandoffContractError`.
3. No production file changes.
4. The Python toolchain (Black, Ruff, Pyright, Pytest) passes locally for the changed test module.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Test no longer references `docs/features/active`; passes without that directory | PASS | Diff replaces the only literal with the tracked `FIXTURES` path; independence-grep shows zero matches for the removed literal; fixture-tracked evidence confirms the directory is tracked | `git grep -nF 'resolve_pinned_plan_path(ROOT, "docs/features/active")' -- tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (exit 1, no match) | The absent-directory case follows by inspection because the argument no longer touches that path |
| 2 | Test still asserts directory rejection with `HandoffContractError` | PASS | `pytest.raises(HandoffContractError)` retained; resolver raises at the `is_file()` check | `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (13 passed) | Reviewer re-run |
| 3 | No production file changes | PASS | Name-status lists one `tests/` modification plus documentation and evidence files | `git diff --name-status 5d0b93a0..a760a7c1` | Matches no-production-change evidence |
| 4 | Python toolchain passes for the changed module | PASS | Black, Ruff, Pyright exit 0; Pytest 13 passed | `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest` on the module | QA-gate evidence files at 19-48 |

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

1. Confirm the CI `quality-checks` job passes on the fix PR (CI status was not available at review time).
2. Confirm PR #761 passes after it is updated from main.

---

## Acceptance Criteria Check-off

All four criteria evaluated PASS. They were already checked in `issue.md`; no source-file change was needed.

### AC Status Summary

- Source: `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/issue.md`
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/issue.md` | 4 | 4 | 0 | Checkbox-backed |

No source-file checkbox change was made because all items were already checked.
