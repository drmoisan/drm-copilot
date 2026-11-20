# P14-T11 Reversed-order run of the Phase 12 and Phase 14 Python test modules

Timestamp: 2026-10-29T12-23
Task: [P14-T11] Repeat the isolation runs on the final tree, discharging [P13-T5].
Command: poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-p14t11-python-modules.txt (pytest.main in one process with -q -p no:cacheprovider --no-cov -p no:randomly over the listed modules in reverse sorted path order)
EXIT_CODE: 0
Output Summary: 664 passed, 0 failed, 0 skipped in one process (106.59 s). No module depends on a module that normally runs before it. P13-T5 ran 578 tests over 22 modules in 1308.50 s before the catalog correction.

## Module set

The 25 `test_*.py` modules added or modified from the Phase 12 plan revision commit (resolved by its subject "add Phases 12 and 13 for the host-principal completion path") to HEAD, from `git diff --name-only --diff-filter=AMR <revision> HEAD -- 'tests/**/test_*.py'`. The set contains every Phase 12 module, the P13-T4 additions (`test_agentic_sync_filesystem.py`, `test_gateway_host_main.py`, `test_service_host_admission.py`) and the three modules the plan names for Phase 14: `tests/discovery_runtime/test_catalog.py`, `tests/discovery_runtime/test_schema_validation.py` and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.

Executed order: tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; tests/scripts/dev_tools/test_discovery_documentation_contracts.py; tests/scripts/dev_tools/test_agentic_sync_filesystem.py; tests/scripts/dev_tools/test_agentic_sync_branches.py; tests/scripts/dev_tools/test_agentic_sync_artifacts.py; tests/scripts/dev_tools/test_agentic_sync.py; tests/schemas/discovery/test_v2_control_schemas.py; tests/discovery_runtime/test_service_preparation.py; tests/discovery_runtime/test_service_host_admission.py; tests/discovery_runtime/test_service_finalization.py; tests/discovery_runtime/test_service_boundaries.py; tests/discovery_runtime/test_schema_validation.py; tests/discovery_runtime/test_public_host_workflow.py; tests/discovery_runtime/test_protected_records.py; tests/discovery_runtime/test_profile_v2.py; tests/discovery_runtime/test_operation_grants.py; tests/discovery_runtime/test_gateway_local.py; tests/discovery_runtime/test_gateway_host_refusals.py; tests/discovery_runtime/test_gateway_host_main.py; tests/discovery_runtime/test_gateway_host_baseline.py; tests/discovery_runtime/test_gateway_host.py; tests/discovery_runtime/test_gateway.py; tests/discovery_runtime/test_extension_inputs.py; tests/discovery_runtime/test_catalog.py; tests/discovery_runtime/test_agent_output_manifest.py.

Result: PASS
