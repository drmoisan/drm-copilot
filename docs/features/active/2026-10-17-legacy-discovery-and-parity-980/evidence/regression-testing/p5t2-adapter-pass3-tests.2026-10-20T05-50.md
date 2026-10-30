# p5t2-adapter-pass3-tests

Timestamp: 2026-10-20T05-50
Command: poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -o addopts= -v --cov=scripts.dev_tools.discovery.parity_report --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/adapter-coverage.json
EXIT_CODE: 0
Output Summary: tests, 1.983s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 24 items

tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries PASSED [  4%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_render_parity_report_is_deterministic PASSED [  8%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [ 12%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_parity_rows_handles_missing_entries_key PASSED [ 16%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_0_on_success PASSED [ 20%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_on_failure PASSED [ 25%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.0.0] PASSED [ 33%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.12.34] PASSED [ 37%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{] PASSED [ 41%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[[]] PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":null}] PASSED [ 50%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[null]}] PASSED [ 54%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[],"entries":[]}] PASSED [ 58%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[{"score":NaN}]}] PASSED [ 62%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"2.0.0","entries":[]}] PASSED [ 66%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"1.bad","rows":[]}] PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_default_validator_uses_existing_lazy_upstream_seam PASSED [ 75%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[read] PASSED [ 79%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[write] PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[validator] PASSED [ 87%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_missing_input_is_an_argument_error PASSED [ 91%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[build] PASSED [ 95%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[render] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\parity_report.py      38      0      4      0   100%
------------------------------------------------------------------------------------------
TOTAL                                             38      0      4      0   100%
Coverage JSON written to file SCRATCH/adapter-coverage.json
============================= 24 passed in 0.25s ==============================
```
