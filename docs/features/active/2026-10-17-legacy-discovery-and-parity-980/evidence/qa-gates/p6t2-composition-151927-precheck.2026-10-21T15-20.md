# P6-T2 CLI composition precheck

Timestamp: 2026-10-21T15-20

Command: `C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.cli --cov-branch -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t2-composition-151927-precheck-coverage.json tests/discovery_runtime/test_cli_dry_run.py::test_help_and_unsupported_authority_never_call_providers[argv1-2] tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[canonical] tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded tests/discovery_runtime/test_cli_dry_run.py::test_validate_all_default_pair_uses_real_planner[True]`

EXIT_CODE: 0

Output Summary: PASS; 74.979 seconds; 4 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.3, pluggy-1.6.0 -- C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.1.0
collecting ... collected 4 items

tests/discovery_runtime/test_cli_dry_run.py::test_help_and_unsupported_authority_never_call_providers[argv1-2] PASSED [ 25%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[canonical] PASSED [ 50%]
tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded PASSED [ 75%]
tests/discovery_runtime/test_cli_dry_run.py::test_validate_all_default_pair_uses_real_planner[True] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                          Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\cli.py     143     53     10      2    63%   114, 153-154, 180-185, 198-205, 214-217, 226, 238, 243, 261-263, 303, 308, 313, 318, 323, 328, 333, 338, 343, 348, 353, 358, 363, 368, 373, 378, 383, 388, 393, 398, 403, 408, 413, 418, 423, 428, 433, 438, 443, 448
---------------------------------------------------------------------------------------------------------
TOTAL                                                           143     53     10      2    63%
Coverage JSON written to file SCRATCH\p6t2-composition-151927-precheck-coverage.json
======================== 4 passed in 74.18s (0:01:14) =========================

```
