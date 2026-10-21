# P6-T1 publication repair precheck

Timestamp: 2026-10-21T08-22

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-081749-precheck-coverage.json tests/discovery_runtime/test_service_migration.py::test_migration_capture_empty_selection_preserves_original_io tests/discovery_runtime/test_service_migration.py::test_migration_capture_retains_exact_files_and_trusted_ports tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[duplicate] tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[traversal] tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[link] tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_changed_originals[changed] tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_changed_originals[missing] tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_conflicting_observations tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[file-count] tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[work] tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[bytes] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest`

EXIT_CODE: 1

Output Summary: FAIL; 282.387 seconds; 12 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 13 items

tests/discovery_runtime/test_service_migration.py::test_migration_capture_empty_selection_preserves_original_io PASSED [  7%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_retains_exact_files_and_trusted_ports FAILED [ 15%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[duplicate] PASSED [ 23%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[traversal] PASSED [ 30%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_invalid_selection[link] PASSED [ 38%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_changed_originals[changed] PASSED [ 46%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_changed_originals[missing] PASSED [ 53%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_rejects_conflicting_observations PASSED [ 61%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[file-count] PASSED [ 69%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[work] PASSED [ 76%]
tests/discovery_runtime/test_service_migration.py::test_migration_capture_reserves_before_reads[bytes] PASSED [ 84%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] PASSED [ 92%]
tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest PASSED [100%]

================================== FAILURES ===================================
________ test_migration_capture_retains_exact_files_and_trusted_ports _________
tests\discovery_runtime\test_service_migration.py:260: in test_migration_capture_retains_exact_files_and_trusted_ports
    assert (
E   AssertionError: assert InputManifest...aaaaaaaaa'),)) == InputManifest...aaaaaaaaa'),))
E
E     Omitting 3 identical items, use -vv to show
E     Differing attributes:
E     ['missing_paths']
E
E     Drill down into differing attribute missing_paths:
E       missing_paths: ('application', 'config/discovery.json', 'proposals', 'verification') != ('config/discovery.json', 'proposals', 'verification')...
E
E     ...Full output truncated (10 lines hidden), use '-vv' to show
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py     120      8     44      7    90%   45, 76, 83, 119, 141-145, 160, 165
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py         212     38     96     24    76%   75, 80, 107, 118, 151, 153, 157-158, 205-210, 266, 330, 335, 340, 362, 365-384, 410, 420, 423-425, 429, 440, 444, 469, 471, 478, 487
packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py     111     71     28      5    34%   34, 83-98, 112-160, 177-232, 265, 273, 289-327, 349, 351, 354
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         443    117    168     36    70%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-081749-precheck-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_migration.py::test_migration_capture_retains_exact_files_and_trusted_ports
================== 1 failed, 12 passed in 281.69s (0:04:41) ===================

```
