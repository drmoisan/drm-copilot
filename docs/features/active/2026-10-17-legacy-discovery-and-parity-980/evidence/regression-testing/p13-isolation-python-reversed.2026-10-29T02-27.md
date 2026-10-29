# P13-T5 Reversed-order run of the Phase 12 Python test modules

Timestamp: 2026-10-29T02-27
Task: [P13-T5] Repeat isolation runs for the Phase 12 suites.
Command: poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-p13t5-python-modules.txt (pytest.main in one process with -q -p no:cacheprovider --no-cov over the listed modules in reverse sorted path order)
EXIT_CODE: 0
Output Summary: 578 passed, 0 failed, 0 skipped in one process (1308.50s, measured while the full P13-T1 coverage run shared the machine). No module depends on a module that normally runs before it.

## Module set

The module set is the 22 `test_*.py` modules added or modified since the Phase 12 plan revision commit (`git diff --name-only --diff-filter=AMR` from the revision commit `69e7d04d1` to HEAD). Executed order: tests/scripts/dev_tools/test_discovery_documentation_contracts.py; tests/scripts/dev_tools/test_agentic_sync_branches.py; tests/scripts/dev_tools/test_agentic_sync_artifacts.py; tests/scripts/dev_tools/test_agentic_sync.py; tests/schemas/discovery/test_v2_control_schemas.py; tests/discovery_runtime/test_service_preparation.py; tests/discovery_runtime/test_service_host_admission.py; tests/discovery_runtime/test_service_finalization.py; tests/discovery_runtime/test_service_boundaries.py; tests/discovery_runtime/test_public_host_workflow.py; tests/discovery_runtime/test_protected_records.py; tests/discovery_runtime/test_profile_v2.py; tests/discovery_runtime/test_operation_grants.py; tests/discovery_runtime/test_gateway_local.py; tests/discovery_runtime/test_gateway_host_refusals.py; tests/discovery_runtime/test_gateway_host_main.py; tests/discovery_runtime/test_gateway_host_baseline.py; tests/discovery_runtime/test_gateway_host.py; tests/discovery_runtime/test_gateway.py; tests/discovery_runtime/test_extension_inputs.py; tests/discovery_runtime/test_catalog.py; tests/discovery_runtime/test_agent_output_manifest.py.
