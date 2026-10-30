Timestamp: 2026-10-21T07-41
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short --maxfail=1 tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest`
EXIT_CODE: 0
Output Summary: boundary-loop2-interruption; 1 retained test IDs; elapsed 16.260 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest PASSED [100%]

============================= 1 passed in 15.86s ==============================

```
