# P6-T1 publication repair precheck

Timestamp: 2026-10-21T07-40

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-publication-repair-074040-precheck-coverage.json tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch]`

EXIT_CODE: 1

Output Summary: FAIL; 4.641 seconds; 0 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 1 item

tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] FAILED [100%]

================================== FAILURES ===================================
_______ test_invalid_v1_schema_identity_never_publishes[body-mismatch] ________
tests\discovery_runtime\test_service_migration.py:103: in test_invalid_v1_schema_identity_never_publishes
    assert any(
E   AssertionError: (Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = any(<generator object test_invalid_v1_schema_identity_never_publishes.<locals>.<genexpr> at 0x00000116D913F9F0>)
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
============================== 1 failed in 4.07s ==============================

```
