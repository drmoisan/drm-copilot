# p5t2-projection-fixture-pass3-tests

Timestamp: 2026-10-20T06-49
Command: poetry run pytest tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] -o addopts= -v --cov=drm_copilot_discovery.validation --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/projection-precheck-coverage.json
EXIT_CODE: 0
Output Summary: tests, 38.671s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 2 items

tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] PASSED [ 50%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                 Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py     162     26     56     16    80%   195, 199, 211->256, 269-278, 307-337, 355, 357, 382, 390-397, 414, 416-420, 423, 431, 464, 467, 497
----------------------------------------------------------------------------------------------------------------
TOTAL                                                                  162     26     56     16    80%
Coverage JSON written to file SCRATCH/projection-precheck-coverage.json
============================= 2 passed in 36.83s ==============================
```
