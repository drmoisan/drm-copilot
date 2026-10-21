Timestamp: 2026-10-21T05-11
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short --cov=drm_copilot_discovery.gateway_local --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p6t1-gateway-ncf2-coverage.json tests/discovery_runtime/test_gateway_factory.py tests/discovery_runtime/test_gateway_local.py::test_installed_factory_wires_only_trusted_outer_host_values tests/discovery_runtime/test_activation_filesystem.py::test_local_factory_requires_canonical_external_host_locations`
EXIT_CODE: 0
Output Summary: ncf2-loop1-focused; 34 retained test IDs; elapsed 3.012 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 34 items

tests/discovery_runtime/test_gateway_factory.py::test_factory_preserves_partition_through_real_store[existing-canonical] PASSED [  2%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_preserves_partition_through_real_store[existing-alias] PASSED [  5%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_preserves_partition_through_real_store[missing-leaf-canonical] PASSED [  8%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_preserves_partition_through_real_store[missing-leaf-alias] PASSED [ 11%]
tests/discovery_runtime/test_gateway_factory.py::test_invalid_state_spelling_is_rejected_before_resolution[relative] PASSED [ 14%]
tests/discovery_runtime/test_gateway_factory.py::test_invalid_state_spelling_is_rejected_before_resolution[../state] PASSED [ 17%]
tests/discovery_runtime/test_gateway_factory.py::test_invalid_state_spelling_is_rejected_before_resolution[C:state] PASSED [ 20%]
tests/discovery_runtime/test_gateway_factory.py::test_invalid_state_spelling_is_rejected_before_resolution[\\state] PASSED [ 23%]
tests/discovery_runtime/test_gateway_factory.py::test_invalid_state_spelling_is_rejected_before_resolution[parent] PASSED [ 26%]
tests/discovery_runtime/test_gateway_factory.py::test_internal_state_cannot_become_trusted_storage[lexical] PASSED [ 29%]
tests/discovery_runtime/test_gateway_factory.py::test_internal_state_cannot_become_trusted_storage[resolved] PASSED [ 32%]
tests/discovery_runtime/test_gateway_factory.py::test_distinct_or_changing_derived_state_is_refused[layout] PASSED [ 35%]
tests/discovery_runtime/test_gateway_factory.py::test_distinct_or_changing_derived_state_is_refused[partition] PASSED [ 38%]
tests/discovery_runtime/test_gateway_factory.py::test_distinct_or_changing_derived_state_is_refused[store-race] PASSED [ 41%]
tests/discovery_runtime/test_gateway_factory.py::test_resolution_errors_propagate_without_fallback[workspace] PASSED [ 44%]
tests/discovery_runtime/test_gateway_factory.py::test_resolution_errors_propagate_without_fallback[base] PASSED [ 47%]
tests/discovery_runtime/test_gateway_factory.py::test_resolution_errors_propagate_without_fallback[state] PASSED [ 50%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_rejects_invalid_outer_authority[noncanonical-workspace] PASSED [ 52%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_rejects_invalid_outer_authority[missing-workspace] PASSED [ 55%]
tests/discovery_runtime/test_gateway_factory.py::test_factory_rejects_invalid_outer_authority[host] PASSED [ 58%]
tests/discovery_runtime/test_gateway_factory.py::test_composed_ports_reject_host_references[invocation] PASSED [ 61%]
tests/discovery_runtime/test_gateway_factory.py::test_composed_ports_reject_host_references[authorization] PASSED [ 64%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[one-component-existing] PASSED [ 67%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[one-component-missing-leaf] PASSED [ 70%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[three-components-existing] PASSED [ 73%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[three-components-missing-leaf] PASSED [ 76%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_resolution_rejects_invalid_identity[relative] PASSED [ 79%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_resolution_rejects_invalid_identity[outside-base] PASSED [ 82%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_resolution_rejects_invalid_identity[layout] PASSED [ 85%]
tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_resolution_rejects_invalid_identity[partition] PASSED [ 88%]
tests/discovery_runtime/test_gateway_local.py::test_installed_factory_wires_only_trusted_outer_host_values PASSED [ 91%]
tests/discovery_runtime/test_activation_filesystem.py::test_local_factory_requires_canonical_external_host_locations[canonical] PASSED [ 94%]
tests/discovery_runtime/test_activation_filesystem.py::test_local_factory_requires_canonical_external_host_locations[alias] PASSED [ 97%]
tests/discovery_runtime/test_activation_filesystem.py::test_local_factory_requires_canonical_external_host_locations[internal] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py     140     78     40      2    39%   65, 97, 105-110, 140-161, 178-185, 199-223, 238-254, 269-341
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     140     78     40      2    39%
Coverage JSON written to file SCRATCH\issue-980-p6t1-gateway-ncf2-coverage.json
============================= 34 passed in 2.46s ==============================

```
