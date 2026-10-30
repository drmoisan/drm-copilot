Timestamp: 2026-10-21T07-42
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short --maxfail=1 tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest`
EXIT_CODE: 0
Output Summary: boundary-loop2-focused; 7 retained test IDs; elapsed 22.816 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 7 items

tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[snapshot] PASSED [ 14%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[plan] PASSED [ 28%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[read] PASSED [ 42%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[document] PASSED [ 57%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[text] PASSED [ 71%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[strings] PASSED [ 85%]
tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest PASSED [100%]

============================= 7 passed in 22.42s ==============================

```
