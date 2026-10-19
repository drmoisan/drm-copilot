# P4-T9 Shared Inputs focused9 tests-fixture-precheck

Timestamp: 2026-10-19T13-33
Command: `poetry run python -m pytest -v -o addopts= tests/discovery_runtime/test_extension_input_limits.py::test_projected_mappings_reserve_records_before_row_construction`
EXIT_CODE: 0
Output Summary: Isolated development gate; exact input and raw-output bindings are in the paired JSON.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/discovery_runtime/test_extension_input_limits.py::test_projected_mappings_reserve_records_before_row_construction PASSED [100%]

============================== 1 passed in 1.01s ==============================

```
