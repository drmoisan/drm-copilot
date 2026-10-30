Timestamp: 2026-10-20T18-06
Command: `.venv/Scripts/python.exe -m pytest -o addopts= -vv tests/discovery_runtime/test_gateway_local.py::test_local_ports_share_exact_readers_and_guard tests/discovery_runtime/test_gateway_local.py::test_missing_identity_never_fabricates_runtime tests/discovery_runtime/test_gateway_local.py::test_host_principal_is_never_converted_to_local_user tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority tests/discovery_runtime/test_gateway_local.py::test_cross_workspace_baseline_and_writer_are_rejected tests/discovery_runtime/test_gateway_local.py::test_writer_recaptures_real_memory_state_and_invalidates tests/discovery_runtime/test_gateway_local.py::test_read_selection_is_exact_and_profile_scoped tests/discovery_runtime/test_gateway_local.py::test_inventory_writer_preserves_exact_pinned_selection tests/discovery_runtime/test_gateway_local.py::test_extra_pins_require_the_bound_repository_reader tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host --cov=drm_copilot_discovery.path_policy --cov=drm_copilot_discovery.gateway_local --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p6t1-gateway-nio1-retained-coverage.json`
EXIT_CODE: 0
Output Summary: nio1-loop2-retained; 32 retained test IDs; elapsed 33.290 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 32 items

tests/discovery_runtime/test_gateway_local.py::test_local_ports_share_exact_readers_and_guard PASSED [  3%]
tests/discovery_runtime/test_gateway_local.py::test_missing_identity_never_fabricates_runtime PASSED [  6%]
tests/discovery_runtime/test_gateway_local.py::test_host_principal_is_never_converted_to_local_user PASSED [  9%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[invocation] PASSED [ 12%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[authorization] PASSED [ 15%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[mode] PASSED [ 18%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[workspace] PASSED [ 21%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[prepare] PASSED [ 25%]
tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[finalize] PASSED [ 28%]
tests/discovery_runtime/test_gateway_local.py::test_cross_workspace_baseline_and_writer_are_rejected PASSED [ 31%]
tests/discovery_runtime/test_gateway_local.py::test_writer_recaptures_real_memory_state_and_invalidates PASSED [ 34%]
tests/discovery_runtime/test_gateway_local.py::test_read_selection_is_exact_and_profile_scoped PASSED [ 37%]
tests/discovery_runtime/test_gateway_local.py::test_inventory_writer_preserves_exact_pinned_selection[False] PASSED [ 40%]
tests/discovery_runtime/test_gateway_local.py::test_inventory_writer_preserves_exact_pinned_selection[True] PASSED [ 43%]
tests/discovery_runtime/test_gateway_local.py::test_extra_pins_require_the_bound_repository_reader PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[relative] PASSED [ 50%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[C:relative] PASSED [ 53%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\root] PASSED [ 56%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[../root] PASSED [ 59%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[/a/../root] PASSED [ 62%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[/a/./root] PASSED [ 65%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\\\?\\C:\\root] PASSED [ 68%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\\\.\\pipe\\root] PASSED [ 71%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[neighbor/file.cs] PASSED [ 75%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[src-other/file.cs] PASSED [ 78%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[Src/file.cs] PASSED [ 81%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[config/other.json] PASSED [ 84%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[Sample.sln/child] PASSED [ 87%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[/workspace] PASSED [ 90%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[C:/Workspace] PASSED [ 93%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[C:\\Workspace] PASSED [ 96%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[\\\\server\\share\\Workspace] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py     131     48     38      1    60%   109-110, 145, 269-341, 375-398
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py       161     28     86     26    78%   124, 178, 229, 235, 247, 257-258, 264, 268, 274, 281, 288, 302, 321, 336, 343, 350, 366, 392, 400, 409, 441, 451, 458, 467, 474, 487, 492
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     292     76    124     27    71%
Coverage JSON written to file SCRATCH/issue-980-p6t1-gateway-nio1-retained-coverage.json
============================= 32 passed in 32.68s =============================

```
