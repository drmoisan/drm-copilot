# P6-T1 publication repair tests

Timestamp: 2026-10-21T07-35

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-publication-repair-073526-tests-coverage.json tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest`

EXIT_CODE: 1

Output Summary: FAIL; 12.454 seconds; 8 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 15 items

tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] PASSED [  6%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] PASSED [ 13%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] PASSED [ 20%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] PASSED [ 26%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] PASSED [ 33%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] PASSED [ 40%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] PASSED [ 46%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] PASSED [ 53%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] FAILED [ 60%]

================================== FAILURES ===================================
_______ test_invalid_v1_schema_identity_never_publishes[body-mismatch] ________
tests\discovery_runtime\test_service_migration.py:103: in test_invalid_v1_schema_identity_never_publishes
    assert any(finding.code.startswith("SCHEMA_") for finding in result.findings)
E   assert False
E    +  where False = any(<generator object test_invalid_v1_schema_identity_never_publishes.<locals>.<genexpr> at 0x000001847B2079F0>)
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
======================== 1 failed, 8 passed in 11.77s =========================

```
