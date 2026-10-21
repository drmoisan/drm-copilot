Timestamp: 2026-10-21T06-33
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[selection] tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[encoding] tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[capacity] tests/discovery_runtime/test_service_boundaries.py::test_source_first_page_exposes_exact_truncation`
EXIT_CODE: 0
Output Summary: source-range-loop1-related; 4 retained test IDs; elapsed 27.941 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 4 items

tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[selection] PASSED [ 25%]
tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[encoding] PASSED [ 50%]
tests/discovery_runtime/test_service_boundaries.py::test_source_failures_do_not_return_partial_rows[capacity] PASSED [ 75%]
tests/discovery_runtime/test_service_boundaries.py::test_source_first_page_exposes_exact_truncation PASSED [100%]

============================= 4 passed in 27.54s ==============================

```
