# p5t2-adapter-baseline-tests

Timestamp: 2026-10-20T05-44
Command: poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -o addopts= -v --cov=scripts.dev_tools.discovery.parity_report --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/baseline-coverage.json
EXIT_CODE: 0
Output Summary: tests, 1.869s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 7 items

tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries PASSED [ 14%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_render_parity_report_is_deterministic PASSED [ 28%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [ 42%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_parity_rows_handles_missing_entries_key PASSED [ 57%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_0_on_success PASSED [ 71%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_on_failure PASSED [ 85%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\parity_report.py      40      2      4      0    95%   129-133
------------------------------------------------------------------------------------------
TOTAL                                             40      2      4      0    95%
Coverage JSON written to file SCRATCH/baseline-coverage.json
============================== 7 passed in 0.18s ==============================
```
