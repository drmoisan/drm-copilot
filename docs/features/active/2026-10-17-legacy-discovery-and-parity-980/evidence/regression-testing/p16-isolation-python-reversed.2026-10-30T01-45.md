# P16-T5 Reversed-order single-process run of the Phase 15 Python test modules

Timestamp: 2026-10-30T01-45
Task: [P16-T5] Run the isolation checks on the remediated tree.
Command: poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-p16t5-python-modules.txt (pytest.main in one process with -q -p no:cacheprovider --no-cov -p no:randomly over the listed modules in reverse sorted path order)
EXIT_CODE: 0
Output Summary: 292 passed, 0 failed, 0 skipped in one process (22.35 s). No module depends on a module that normally runs before it.

## Module set

The 12 `test_*.py` modules Phase 15 added or changed, from `git diff --name-only --diff-filter=AM <P14-T16 handoff commit> HEAD -- 'tests/*.py'` (test support and conftest excluded): tests/discovery_runtime/test_catalog.py, test_gateway_host.py, test_gateway_host_main.py, test_gateway_host_read_refusals.py, test_gateway_host_reads.py, test_gateway_host_refusals.py, test_protected_records.py, test_public_host_workflow.py, test_schema_validation.py; tests/schemas/discovery/test_v2_grant_schemas.py; tests/scripts/dev_tools/test_discovery_documentation_contracts.py and test_discovery_publication_contracts.py.

Executed order (reverse sorted path order): tests/scripts/dev_tools/test_discovery_publication_contracts.py; tests/scripts/dev_tools/test_discovery_documentation_contracts.py; tests/schemas/discovery/test_v2_grant_schemas.py; tests/discovery_runtime/test_schema_validation.py; tests/discovery_runtime/test_public_host_workflow.py; tests/discovery_runtime/test_protected_records.py; tests/discovery_runtime/test_gateway_host_refusals.py; tests/discovery_runtime/test_gateway_host_reads.py; tests/discovery_runtime/test_gateway_host_read_refusals.py; tests/discovery_runtime/test_gateway_host_main.py; tests/discovery_runtime/test_gateway_host.py; tests/discovery_runtime/test_catalog.py.

`tests/discovery_runtime/test_catalog.py` runs last, after `test_schema_validation.py`, `test_public_host_workflow.py` and the gateway host modules have each loaded the catalog, so the content-keyed registry cache is populated before `test_missing_required_dependency_fails_without_reduced_validation` runs; the test passes because `_require_schema_libraries()` precedes every cache hit (P15-T18).

Result: PASS
