# Remediation Inputs — minor-audit-small-change-28

**Timestamp:** 2026-02-20T21-30

## Required Fixes (Ordered)

1. **Fix Pytest collection on Windows**
   - **Files:** `pyproject.toml` (Pytest config) and/or `tests/conftest.py` (new)
   - **Issue:** `ModuleNotFoundError: No module named 'scripts'` during collection.
   - **Expected behavior:** `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` completes without import errors on Windows.
   - **Acceptance criteria:**
     - Pytest collection succeeds with repo root on `sys.path`.
     - Full toolchain loop passes (format → lint → type-check → test).
   - **Verification commands:**
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

2. **Bring Python docstrings/comments into compliance**
   - **Files:** `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py`, `tests/scripts/dev_tools/test_potential_to_issue.py`, `tests/scripts/dev_tools/test_new_active_feature_folder.py`
   - **Issue:** Missing mandatory intent-first docstrings and loop/branch intent comments.
   - **Expected behavior:** Every function/class has compliant docstrings; loops/branches have intent comments per policy.
   - **Acceptance criteria:**
     - All modified Python functions/classes include required docstrings.
     - Loop/branch intent comments added where required.
   - **Verification commands:**
     - `poetry run ruff check`
     - `poetry run pyright`

3. **Align subprocess suppressions with pre-authorized format**
   - **Files:** `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py`
   - **Issue:** `# noqa: S603` lacks required comment format.
   - **Expected behavior:** Use pre-authorized S603 pattern with required comment text, or refactor to avoid suppression.
   - **Acceptance criteria:**
     - Each subprocess call using a resolved executable includes `# noqa: S603 - static analysis can't verify runtime validation` and validated `shutil.which()` logic in close proximity.
   - **Verification commands:**
     - `poetry run ruff check`

4. **Remove temporary filesystem usage in tests**
   - **Files:** `tests/scripts/dev_tools/test_potential_to_issue.py`
   - **Issue:** `tmp_path` usage violates unit test policy (no temporary files).
   - **Expected behavior:** Tests use in-memory fakes only.
   - **Acceptance criteria:**
     - All tests avoid `tmp_path` or any filesystem temp creation.
   - **Verification commands:**
     - `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py`

5. **Add explicit minor-audit policy statement**
   - **Files:** `docs/engineering/Feature Playbook.md` and/or `docs/features/templates/README.md`
   - **Issue:** Missing explicit statement that broad regression and extended design docs are not required by default for minor-audit path.
   - **Expected behavior:** Documentation clearly states reduced regression/docs requirements for minor-audit by default.
   - **Acceptance criteria:**
     - Document contains explicit sentence addressing regression/doc expectations.
   - **Verification commands:**
     - Manual doc review

6. **Capture targeted verification evidence**
   - **Files:** `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/other/` (new)
   - **Issue:** Targeted verification artifact missing.
   - **Expected behavior:** Evidence artifact with required schema (Timestamp, Command, EXIT_CODE) documenting targeted verification for changed behavior.
   - **Acceptance criteria:**
     - Evidence artifact exists with required schema and relevant output summary.
   - **Verification commands:**
     - Manual check of evidence folder

## Do Not Do

- Do **not** weaken policies or add broad suppressions (`# noqa`, `# type: ignore`) outside pre-authorized patterns.
- Do **not** skip tests or reduce coverage requirements to “make it pass.”
- Do **not** introduce new dependencies unless explicitly approved.
- Do **not** remove existing acceptance criteria or evidence requirements.

## Unmet Acceptance Criteria (from Feature Audit)

- **AC3:** Minimum audit evidence captured as baseline + end-state + targeted verification — targeted verification artifact missing.
- **AC4:** Policy explicitly states broad regression and extended design docs are not required by default — missing explicit doc statement.
- **AC5:** Reviewer can determine completeness from issue + minimum evidence — blocked by missing targeted verification and failing tests.
