# P6-T1 core service prechecks

Timestamp: 2026-10-20T16-07

Command: `poetry run pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success tests/discovery_runtime/test_service_boundaries.py::test_failed_freshness_preserves_observation_without_second_read tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[None] tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[True]`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 77.631 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 16 items

tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields0] PASSED [  6%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields1] PASSED [ 12%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields2] PASSED [ 18%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields3] PASSED [ 25%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields4] PASSED [ 31%]
tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context PASSED [ 37%]
tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success PASSED [ 43%]
tests/discovery_runtime/test_service_boundaries.py::test_failed_freshness_preserves_observation_without_second_read PASSED [ 50%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[False] PASSED [ 56%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[True] PASSED [ 62%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[False] PASSED [ 68%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[True] PASSED [ 75%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] FAILED [ 81%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] PASSED [ 87%]
tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[None] PASSED [ 93%]
tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[True] PASSED [100%]

================================== FAILURES ===================================
_____ test_source_page_preserves_authorized_bytes_and_line_identity[read] _____
tests\discovery_runtime\test_service.py:365: in test_source_page_preserves_authorized_bytes_and_line_identity
    result = invoke(service_io, "read-source", inputs)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_service.py:246: in invoke
    return execute(
packages\discovery-runtime\src\drm_copilot_discovery\service.py:261: in execute
    context = _context(
packages\discovery-runtime\src\drm_copilot_discovery\service.py:198: in _context
    baseline = capture_workspace(
packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:67: in capture_workspace
    snapshot = load_snapshot(
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:496: in load_snapshot
    return _Loader(io, profile, pinned, categories, repository).load()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:423: in load
    checkout, objects = self._git()
                        ^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:461: in _git
    item = self.repository.read_file(
tests\discovery_runtime\initialization_test_support.py:138: in read_file
    content = self.files[path]
              ^^^^^^^^^^^^^^^^
E   KeyError: 'application/a.cs'
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read]
=================== 1 failed, 15 passed in 76.05s (0:01:16) ===================

```
