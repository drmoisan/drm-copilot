Timestamp: 2026-10-21T06-32
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short tests/discovery_runtime/test_service_boundaries.py::test_reversed_source_line_range_is_rejected_before_inspection`
EXIT_CODE: 0
Output Summary: source-range-loop1-corrected; 1 retained test IDs; elapsed 7.186 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/discovery_runtime/test_service_boundaries.py::test_reversed_source_line_range_is_rejected_before_inspection PASSED [100%]

============================== 1 passed in 6.77s ==============================

```
