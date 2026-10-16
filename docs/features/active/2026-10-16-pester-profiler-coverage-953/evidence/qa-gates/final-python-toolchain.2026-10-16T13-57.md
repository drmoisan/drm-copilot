# Final QC: Python Toolchain (P8-T16 / P6-T6, sharding path)

Timestamp: 2026-10-16T13-57
Command: git diff --name-only origin/main...HEAD -- '*.py'; git status --porcelain -- '*.py'; poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py; poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py; poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0

Output Summary:
- Changed Python files (base diff): `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; porcelain listing empty (committed).
- Black: exit 0, `1 file would be left unchanged.` (check mode, no write).
- Ruff: exit 0, `All checks passed!` (no `--fix`).
- Pyright: exit 0, `0 errors, 0 warnings, 0 informations`.
- Result: PASS.
