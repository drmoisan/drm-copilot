# Python toolchain baseline (P0-T17, rule 16)

Timestamp: 2026-10-16T23-27
Command: poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
EXIT_CODE: 0
Output Summary: Black "1 file would be left unchanged."; Ruff "All checks passed!"; Pyright "0 errors, 0 warnings, 0 informations"; single-file pytest 6 passed; three-file pytest 80 passed. All exit codes 0. CI job: quality-checks7 / Code Quality & Tests (ubuntu-latest).

PY-CONTRACT-BASELINE-PASSED: 6
PY-THREE-FILE-BASELINE-PASSED: 80

## Commands and exit codes

- black EXIT_CODE: 0
- `poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` EXIT_CODE: 0
- `poetry run pyright tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` EXIT_CODE: 0
- `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` EXIT_CODE: 0
- `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py` EXIT_CODE: 0

## black output

```
All done! ✨ \U0001f370 ✨
1 file would be left unchanged.
```

## ruff output

```
All checks passed!
```

## pyright output

```
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## pytest (single file) output (host path redacted)

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 6 items

tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py ...... [100%]

============================== 6 passed in 0.17s ==============================
```

## pytest (three files) output (host path redacted)

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 80 items

tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py ...... [  7%]
tests\scripts\dev_tools\test_ruff_config_alignment.py ....               [ 12%]
tests\scripts\dev_tools\test_workflow_npm_token_guard.py ............... [ 31%]
.......................................................                  [100%]

============================= 80 passed in 0.35s ==============================
```
