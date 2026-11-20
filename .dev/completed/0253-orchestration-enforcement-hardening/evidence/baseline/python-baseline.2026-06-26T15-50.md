# Python Baseline — Issue #253

- Timestamp: 2026-06-26T15-50

## Command 1 — Black (check)

- Timestamp: 2026-06-26T15-50
- Command: `poetry run black --check .`
- EXIT_CODE: 0
- Output Summary: All done. 206 files would be left unchanged. No formatting changes required.

## Command 2 — Ruff

- Timestamp: 2026-06-26T15-50
- Command: `poetry run ruff check .`
- EXIT_CODE: 0
- Output Summary: All checks passed. Zero lint findings.

## Command 3 — Pyright

- Timestamp: 2026-06-26T15-50
- Command: `poetry run pyright`
- EXIT_CODE: 0
- Output Summary: 0 errors, 0 warnings, 0 informations.

## Command 4 — Pytest with coverage

- Timestamp: 2026-06-26T15-50
- Command: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`
- EXIT_CODE: 0
- Output Summary: 1122 passed, 19 skipped. Coverage headline values for `scripts/dev_tools`:
  - Overall TOTAL (whole measured tree): 83% line coverage (8620 stmts, 1231 miss; 3080 branches, 432 partial). Note: the TOTAL spans the full `scripts.dev_tools` package, which includes unrelated low-coverage modules (e.g., `shell_qc.py` 0%, `tk_dialog_helpers.py` 45%) outside this feature's scope.
  - Per-module (in scope for this feature):
    - `validate_orchestrator_state.py`: 94% line/branch coverage (175 stmts, 6 miss; 94 branches, 9 partial).
    - `_orchestrator_state_routing.py`: 90% line/branch coverage (128 stmts, 9 miss; 68 branches, 10 partial).
    - `validate_orchestration_artifacts.py`: 88% line/branch coverage (85 stmts, 8 miss; 36 branches, 7 partial).
