# Feature Audit: handoff test independence from archived active directory (#765)

**Audit Date:** 2026-09-29
**Feature Folder:** `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765`
**Base Branch:** `main`
**Head Branch:** `bug/handoff-test-depends-on-archived-active-dir-765`
**Work Mode:** `minor-audit`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `5d0b93a0b0a15633b42559827fd7459d65c0b671`)
- **Head branch/commit:** `bug/handoff-test-depends-on-archived-active-dir-765` (commit `3310fda705e2c9c2b63f6681637886b4314c29ac`)
- **Merge base:** `5d0b93a0b0a15633b42559827fd7459d65c0b671`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/evidence/**`
  - Additional evidence: reviewer re-run of `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (13 passed); `npm audit --audit-level=moderate` and `npm ls ip-address` in `.`, `extensions/drm-copilot`, and `packages/mcp-server`
- **Feature folder used:** `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765`
- **Requirements source:** `issue.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `Work Mode: minor-audit`; the acceptance criteria are the `## Acceptance Criteria` section of `issue.md`.
- **Scope note:** Full branch diff against the resolved base, including remediation commit 3310fda7 (npm `ip-address` override). The remediation restores the npm audit gate that failed on PR #766; it adds no acceptance criterion. CI on PR #766 had jobs pending at review time.

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
| 1 | Test no longer references `docs/features/active` and passes without that directory | PASS | The diff replaces the literal with `FIXTURES.relative_to(ROOT).as_posix()`, which is `tests/fixtures/orchestration-handoff/contract`, a tracked directory. `evidence/regression-testing/independence-grep.2026-09-28T19-35.md` records zero matches for the removed literal. | `git diff origin/main...HEAD -- tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | The test body no longer touches `docs/features/active/`; the resolver receives a tracked path that resolves and fails the `is_file()` check. |
| 2 | Test still asserts a directory plan path is rejected with `HandoffContractError` | PASS | The `pytest.raises(HandoffContractError)` block and `deny_write_boundaries` fixture are unchanged in the diff. | `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | Reviewer run: 13 passed. |
| 3 | No production file changes | PASS | Changed files outside `docs/` are one test file and six npm manifest and lockfile files. No file under `scripts/`, `src/`, `extensions/**/src`, `.claude/`, or `.github/` changed. | `git diff origin/main...HEAD --name-status` | The manifest and lockfile edits from remediation cycle 1 are dependency metadata, not source code; the criterion concerns production code and is read that way. `evidence/qa-gates/scope-check.2026-09-29T00-30.md` records the manifest scope. |
| 4 | Python toolchain passes locally for the changed test module | PASS | `evidence/qa-gates/final-black.2026-09-28T19-35.md`, `final-ruff`, `final-pyright`, and `final-pytest-coverage` record exit 0. | `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | Reviewer re-run of Pytest: 13 passed at head 3310fda7. The remediation did not alter any Python file. |

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

1. Confirm the CI jobs pending at review time on PR #766 (`quality-checks7` matrix, root TypeScript tests, poshqc, shell coverage) complete green.
2. Confirm `quality-checks7 / Code Quality & Tests (3.11)` passes, which is the job named in the issue as failing.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/issue.md`
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/issue.md` | 4 | 4 | 0 | Checkbox-backed |

All four items were already checked in `issue.md` and each was re-verified in this audit. No source-file change was made.
