# P6-T1 mutation guards tests

Timestamp: 2026-10-21T12-17

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_mutations --cov-branch -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-mutation-guards-120632-tests-coverage.json tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG1] tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG7] tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG8] tests/discovery_runtime/test_service_mutation_guards.py::test_explicit_identity_and_cas_are_independent_preconditions tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG3] tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG4] tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG5] tests/discovery_runtime/test_service_mutation_guards.py::test_matching_approval_preserves_exact_bounded_proposal tests/discovery_runtime/test_service_mutation_guards.py::test_export_identity_must_resolve_exactly_once[MG9] tests/discovery_runtime/test_service_mutation_guards.py::test_export_identity_must_resolve_exactly_once[MG10] tests/discovery_runtime/test_service_mutation_guards.py::test_captured_snapshot_import_uses_real_planner_and_guarded_writer tests/discovery_runtime/test_service_mutation_guards.py::test_extension_preview_retains_normalized_bytes_and_blockers[MG12] tests/discovery_runtime/test_service_mutation_guards.py::test_extension_preview_retains_normalized_bytes_and_blockers[MG13] tests/discovery_runtime/test_service_mutation_guards.py::test_extension_write_publishes_real_normalized_inventory tests/discovery_runtime/test_service_mutation_guards.py::test_mutation_dispatch_refuses_another_valid_operation_family`

EXIT_CODE: 0

Output Summary: PASS; 664.698 seconds; 15 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 15 items

tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG1] PASSED [  6%]
tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG7] PASSED [ 13%]
tests/discovery_runtime/test_service_mutation_guards.py::test_missing_capture_cannot_authorize_mutation[MG8] PASSED [ 20%]
tests/discovery_runtime/test_service_mutation_guards.py::test_explicit_identity_and_cas_are_independent_preconditions PASSED [ 26%]
tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG3] PASSED [ 33%]
tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG4] PASSED [ 40%]
tests/discovery_runtime/test_service_mutation_guards.py::test_approval_requires_actual_status_owner_and_evidence[MG5] PASSED [ 46%]
tests/discovery_runtime/test_service_mutation_guards.py::test_matching_approval_preserves_exact_bounded_proposal PASSED [ 53%]
tests/discovery_runtime/test_service_mutation_guards.py::test_export_identity_must_resolve_exactly_once[MG9] PASSED [ 60%]
tests/discovery_runtime/test_service_mutation_guards.py::test_export_identity_must_resolve_exactly_once[MG10] PASSED [ 66%]
tests/discovery_runtime/test_service_mutation_guards.py::test_captured_snapshot_import_uses_real_planner_and_guarded_writer PASSED [ 73%]
tests/discovery_runtime/test_service_mutation_guards.py::test_extension_preview_retains_normalized_bytes_and_blockers[MG12] PASSED [ 80%]
tests/discovery_runtime/test_service_mutation_guards.py::test_extension_preview_retains_normalized_bytes_and_blockers[MG13] PASSED [ 86%]
tests/discovery_runtime/test_service_mutation_guards.py::test_extension_write_publishes_real_normalized_inventory PASSED [ 93%]
tests/discovery_runtime/test_service_mutation_guards.py::test_mutation_dispatch_refuses_another_valid_operation_family PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\service_mutations.py      96     11     40      7    87%   53, 125-126, 144-145, 172-174, 180-185, 195, 206
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          96     11     40      7    87%
Coverage JSON written to file SCRATCH\p6t1-mutation-guards-120632-tests-coverage.json
======================= 15 passed in 663.96s (0:11:03) ========================

```
