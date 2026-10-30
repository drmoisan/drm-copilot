# P6-T1 publication repair revision-precheck

Timestamp: 2026-10-21T09-33

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov=drm_copilot_discovery.migration_conversion -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-092509-revision-precheck-coverage.json tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] tests/discovery_runtime/test_migration_unknowns.py::test_every_original_field_remains_untrusted_metadata[coverage-ledger] tests/discovery_runtime/test_migration_unknowns.py::test_legacy_claims_do_not_become_verified_target_state[coverage-ledger-fields4] tests/discovery_runtime/test_coverage_scope.py::test_trusted_pin_mismatch_is_rejected_even_when_documents_agree[coverage-ledger]`

EXIT_CODE: 0

Output Summary: PASS; 495.998 seconds; 5 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 5 items

tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] PASSED [ 20%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] PASSED [ 40%]
tests/discovery_runtime/test_migration_unknowns.py::test_every_original_field_remains_untrusted_metadata[coverage-ledger] PASSED [ 60%]
tests/discovery_runtime/test_migration_unknowns.py::test_legacy_claims_do_not_become_verified_target_state[coverage-ledger-fields4] PASSED [ 80%]
tests/discovery_runtime/test_coverage_scope.py::test_trusted_pin_mismatch_is_rejected_even_when_documents_agree[coverage-ledger] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py        120     14     44     12    82%   34, 39, 45, 76, 83, 119, 141-145, 160, 164-165, 235, 267, 285
packages\discovery-runtime\src\drm_copilot_discovery\migration_conversion.py      76      6     26      6    88%   42, 52, 68, 104, 247, 295
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py            214     43     96     28    73%   49-50, 75, 80, 107, 112, 118, 129, 132, 134, 151, 153, 157-158, 205-210, 266, 330, 333->322, 337, 362, 365-384, 410, 420, 423-425, 429, 440, 444, 469, 471, 478, 487
packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py        111     42     28      7    60%   92, 112-160, 177-232, 265, 273, 326, 349, 351, 354
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            521    105    194     53    75%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-092509-revision-precheck-coverage.json
======================== 5 passed in 495.26s (0:08:15) ========================

```
