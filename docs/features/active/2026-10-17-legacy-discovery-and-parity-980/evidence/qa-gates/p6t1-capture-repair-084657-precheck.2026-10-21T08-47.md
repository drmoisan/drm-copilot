# P6-T1 publication repair precheck

Timestamp: 2026-10-21T08-47

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-084657-precheck-coverage.json tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short]`

EXIT_CODE: 0

Output Summary: PASS; 46.362 seconds; 9 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 9 items

tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports PASSED [ 11%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] PASSED [ 22%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] PASSED [ 33%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] PASSED [ 44%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] PASSED [ 55%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] PASSED [ 66%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] PASSED [ 77%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] PASSED [ 88%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py     120      9     44      9    89%   34, 39, 45, 76, 83, 119, 235, 267, 285
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py         214     43     96     26    73%   49-50, 75, 80, 107, 112, 118, 129, 132, 134, 151, 153, 156-158, 205-210, 266, 330, 362, 365-384, 410, 420, 423-425, 429, 440, 444, 469, 471, 478, 487
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         334     52    140     35    79%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-084657-precheck-coverage.json
============================= 9 passed in 45.12s ==============================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.service_bootstrap was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
```
