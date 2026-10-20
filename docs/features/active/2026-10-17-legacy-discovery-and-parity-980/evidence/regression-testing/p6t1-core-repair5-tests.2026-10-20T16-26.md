# P6-T1 core service tests

Timestamp: 2026-10-20T16-11

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.service,drm_copilot_discovery.operations,drm_copilot_discovery.service_inspection,drm_copilot_discovery.service_reports,drm_copilot_discovery.service_mutations,drm_copilot_discovery.service_bootstrap -m pytest -v --tb=short --maxfail=8 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_boundaries.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 900.191 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 109 items

tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields0] PASSED [  0%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields1] PASSED [  1%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields2] PASSED [  2%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields3] PASSED [  3%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields4] PASSED [  4%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[host] PASSED [  5%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[invocation_ref] PASSED [  6%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[authorization_ref] PASSED [  7%]
tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success PASSED [  8%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[profile] PASSED [  9%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[validate-profile] PASSED [ 10%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[True] PASSED [ 11%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[False] PASSED [ 11%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[list] PASSED [ 12%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] PASSED [ 13%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[search] PASSED [ 14%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] PASSED [ 15%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger] PASSED [ 16%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario] PASSED [ 17%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix] PASSED [ 18%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior] PASSED [ 19%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-product-decision] PASSED [ 20%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-evidence-reference] PASSED [ 21%]
tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[None] PASSED [ 22%]
tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[selector1] PASSED [ 22%]
tests/discovery_runtime/test_service.py::test_source_without_independent_selection_is_unavailable PASSED [ 23%]
tests/discovery_runtime/test_service.py::test_doctor_uses_verified_runtime_without_claiming_native_capability PASSED [ 24%]
tests/discovery_runtime/test_service.py::test_decision_validation_preserves_complete_graph_result PASSED [ 25%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields0] PASSED [ 26%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields1] PASSED [ 27%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields2] PASSED [ 28%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields3] PASSED [ 29%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields4] PASSED [ 30%]
tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context PASSED [ 31%]
tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[True] PASSED [ 32%]
tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[False] PASSED [ 33%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[extra] PASSED [ 33%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[wrong-id] PASSED [ 34%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[wrong-path] PASSED [ 35%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[coverage-report] PASSED [ 36%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[parity-report]

```
