# Feature Audit: IDE launcher audit gaps (#338)

---

**Audit Date:** 2026-10-08
**Feature Folder:** `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338`
**Base Branch:** `origin/main`
**Head Branch:** `bug/potential-entry-ide-launcher-audit-gaps-338`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (structural regeneration; verdicts preserved)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `6dac65b0930b299dc7b3c3925a607735a05fca35`)
- **Head branch/commit:** `bug/potential-entry-ide-launcher-audit-gaps-338` (commit `f8203e46ffad15fe27fd8a4f1ed774c6c640b323`)
- **Merge base:** `6dac65b0930b299dc7b3c3925a607735a05fca35`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/**`
- **Feature folder used:** `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338`
- **Requirements source:** `issue.md`
- **Work mode resolution note:** The persisted `- Work Mode: minor-audit` marker in `issue.md` was used; the AC source is the explicit `## Acceptance Criteria` section (5 items).
- **Scope note:** Full branch diff against the resolved base. The verdicts below were produced in the earlier review pass and are preserved unchanged.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md` — only source (`## Acceptance Criteria`, checkbox-backed)

### Acceptance criteria

1. The stray docstring literal is removed from `_resolve_code_cli()` with no behavior change: a search for the token `as_posix() for file_path in files` in `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` returns no matches, and `poetry run ruff check` on those two files passes. The TypeScript launcher sources and both `new-potential-entry.ps1` copies are unchanged.
2. New Python tests pass and drive the previously untested launcher branches (backslash-to-forward-slash argv conversion, symmetric CLI fallback with a successful second probe, and each Insiders signal variable in `_INSIDERS_SIGNAL_NAMES`) for both modules: `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py` exits 0, and no test file exceeds 500 lines.
3. New TypeScript tests pass and drive the previously untested launcher branches (backslash conversion, symmetric CLI fallback, each Insiders signal variable, and the default lookup helpers) in `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts` and `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts`: `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts` run from `extensions/drm-copilot` exits 0.
4. Finding (B) is closed by isolated launcher coverage evidence stored under `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/qa-gates/` (each file recording Timestamp, Command, and EXIT_CODE) showing `scripts/dev_tools/new_potential_bug_entry.py`, `scripts/dev_tools/new_active_feature_folder_io.py`, `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts`, and `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts` each at line coverage >= 85% and branch coverage >= 75%. The 90% new-code figure is reported for information only.
5. Finding (C) (AC-1/AC-2 live-Windows verification) is resolved by `scope_change`: a timestamped closure record `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/other/ac1-ac2-scope-change-closure.<timestamp>.md` exists, names by file and test name the Python and TypeScript argv/CLI-selection contract tests asserting `--reuse-window`, file arguments, and Insiders-first CLI selection, and states the residual unobserved desktop-UI risk.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Stray docstring literal removed, no behavior change, ruff passes, protected files unchanged | PASS | Branch diff shows only a one-line docstring change in each of the two Python modules. `evidence/qa-gates/ac1-stray-token-final.2026-10-08T02-51.md` EXIT_CODE 1 (expected 1: no matches) against the two named files. `evidence/qa-gates/python-ruff.2026-10-08T02-48.md` EXIT_CODE 0. `protected-files-final.2026-10-08T02-51.md` EXIT_CODE 0; branch diff lists no TypeScript source or `new-potential-entry.ps1` change. | `git grep -n -F -e "as_posix() for file_path in files" -- scripts/dev_tools/new_potential_bug_entry.py scripts/dev_tools/new_active_feature_folder_io.py`; `poetry run ruff check <the two modules>` | Token also absent outside `docs/`. |
| 2 | New Python tests pass and drive the untested branches; no test file over 500 lines | PASS | Reviewer re-read `test_new_active_feature_folder_launcher.py` (backslash conversion, both fallbacks, parametrized `_INSIDERS_SIGNAL_NAMES`); `test_new_potential_bug_entry.py` gained the sibling tests. `ac2-pytest.2026-10-08T02-45.md`: 36 passed, EXIT_CODE 0. Line counts 415 and 142 (`test-file-line-counts.2026-10-08T02-45.md`). | `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py` | Reviewer used existing evidence and did not rerun tests. |
| 3 | New TypeScript tests pass and drive the untested branches | PASS (with note CR-1) | `ac3-jest.2026-10-08T02-45.md`: 2 suites, 46 tests, EXIT_CODE 0 for the exact AC command. The default-helper tests live in the new sibling `io-launcher.test.ts` rather than `io.test.ts` (500-line limit); `ac3-jest-new-tests.2026-10-08T02-45.md` and the full-suite run (254 suites, 3879 tests, EXIT_CODE 0) cover them. `io-launcher.ts` coverage rose from 97.87/84.61 to 100/93.75. | `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts` (from `extensions/drm-copilot`) | CR-1: recommend updating AC-3 wording at the next planning pass. |
| 4 | Finding (B) closed by isolated launcher coverage evidence (line >= 85, branch >= 75 for four files) | PASS | `evidence/qa-gates/` files carry Timestamp, Command, EXIT_CODE. Python: 91.89/76.67 and 97.27/88.00. TypeScript: 97.83/87.27 and 100/93.75. All meet floors and none regress from baseline (`coverage-delta.2026-10-08T02-51.md`). Reviewer independently computed TypeScript aggregate 97.14% line / 91.58% branch from `coverage/lcov.info`. | `npm run test:unit -- --coverage --coverageReporters=text --coverageReporters=lcov` (from `extensions/drm-copilot`); `poetry run pytest ... --cov-branch` | 90% new-code figure informational: no executable lines changed. |
| 5 | Finding (C) resolved by `scope_change` closure record | PASS | `evidence/other/ac1-ac2-scope-change-closure.2026-10-08T02-44.md` exists, records `Response: scope_change`, lists Python and TypeScript contract tests by file and name covering `--reuse-window`, file arguments, and Insiders-first selection, and states the residual unobserved desktop-UI risk. Reviewer confirmed all named Python test functions and TypeScript case names exist in the repository. `ac5-closure-record-check.2026-10-08T02-45.md` EXIT_CODE 0. | See `evidence/regression-testing/ac5-closure-record-check.2026-10-08T02-45.md` | Live Windows observation not performed; accepted. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Residual risk:** Live Windows observation of `code --reuse-window` window reuse (issue #116 AC-1/AC-2) was not performed; it is accepted as a scope change per AC-5.

**Recommended follow-up verification steps:**

1. Update AC-3 wording at the next planning pass to reference `io-launcher.test.ts` (CR-1).
2. Confirm a whole-repository Python coverage run in CI as the authoritative repo-wide check (policy audit advisory A1).

No remediation inputs are required.

---

## Acceptance Criteria Check-off

All five items were evaluated PASS and are checked off in `issue.md` (`- [ ]` to `- [x]`). No further source-file change was made in this regeneration pass.

### AC Status Summary

- Source: `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md` | 5 | 5 | 0 | Checkbox-backed; only authoritative source for minor-audit |

No source-file checkbox change was made in this pass because all items were already checked.
