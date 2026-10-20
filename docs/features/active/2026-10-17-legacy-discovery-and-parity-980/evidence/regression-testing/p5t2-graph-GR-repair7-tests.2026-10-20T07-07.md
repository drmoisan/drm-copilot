# P5-T2 graph tests

Timestamp: 2026-10-20T07-07

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.parity_report,drm_copilot_discovery.parity_metrics,drm_copilot_discovery.report_models -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_parity_axes.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs tests/discovery_runtime/test_parity_report.py::test_graph_preflight_reserves_input_before_projection tests/discovery_runtime/test_parity_report.py::test_public_builder_reuses_complete_projection_with_independent_root_mode tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind tests/discovery_runtime/test_parity_report.py::test_graph_work_rejects_before_retaining_entry_locations tests/discovery_runtime/test_parity_report.py::test_axis_output_budget_rejects_before_processing_remaining_rows`

EXIT_CODE: 0

Output Summary: PASS; 39.481 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 58 items

tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[passed-online] PASSED [  1%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[passed-offline] PASSED [  3%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[passed-mobile] PASSED [  5%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[failed-online] PASSED [  6%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[failed-offline] PASSED [  8%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[failed-mobile] PASSED [ 10%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[blocked-online] PASSED [ 12%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[blocked-offline] PASSED [ 13%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[blocked-mobile] PASSED [ 15%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[not-run-online] PASSED [ 17%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[not-run-offline] PASSED [ 18%]
tests/discovery_runtime/test_parity_axes.py::test_consistent_authored_state_counts_once_without_verified_proof[not-run-mobile] PASSED [ 20%]
tests/discovery_runtime/test_parity_axes.py::test_client_aggregation_retains_authored_state_after_actual_assessment[passed] PASSED [ 22%]
tests/discovery_runtime/test_parity_axes.py::test_client_aggregation_retains_authored_state_after_actual_assessment[failed] PASSED [ 24%]
tests/discovery_runtime/test_parity_axes.py::test_client_aggregation_retains_authored_state_after_actual_assessment[blocked] PASSED [ 25%]
tests/discovery_runtime/test_parity_axes.py::test_client_aggregation_retains_authored_state_after_actual_assessment[not-run] PASSED [ 27%]
tests/discovery_runtime/test_parity_axes.py::test_conflicting_representations_never_select_an_authored_status[verification] PASSED [ 29%]
tests/discovery_runtime/test_parity_axes.py::test_conflicting_representations_never_select_an_authored_status[applicability] PASSED [ 31%]
tests/discovery_runtime/test_parity_axes.py::test_conflicting_representations_never_select_an_authored_status[retained] PASSED [ 32%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[8] PASSED [ 34%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[32] PASSED [ 36%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[64] PASSED [ 37%]
tests/discovery_runtime/test_parity_metrics.py::test_verified_full_parity_keeps_four_population_units PASSED [ 39%]
tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[offline] PASSED [ 41%]
tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[mobile] PASSED [ 43%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[unassessed] PASSED [ 44%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[partial] PASSED [ 46%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[missing] PASSED [ 48%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[conflicting] PASSED [ 50%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[intentionally-changed] PASSED [ 51%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[retired] PASSED [ 53%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[repository_id-wrong] PASSED [ 55%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000] PASSED [ 56%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[feature_id-absent] PASSED [ 58%]
tests/discovery_runtime/test_parity_metrics.py::test_duplicate_rows_are_all_invalid_and_count_one_missing_completion PASSED [ 60%]
tests/discovery_runtime/test_parity_metrics.py::test_multiple_clients_do_not_multiply_source_feature_identity PASSED [ 62%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[proposed-1] PASSED [ 63%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[blocked-1] PASSED [ 65%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[approved-1] PASSED [ 67%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[rejected-0] PASSED [ 68%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[superseded-0] PASSED [ 70%]
tests/discovery_runtime/test_parity_metrics.py::test_all_authored_blockers_preserve_row_location PASSED [ 72%]
tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[coverage-ledger] PASSED [ 74%]
tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[inventory-snapshot] PASSED [ 75%]
tests/discovery_runtime/test_parity_metrics.py::test_confirmed_empty_scope_has_real_zeros_and_null_percentages PASSED [ 77%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes0] PASSED [ 79%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes1] PASSED [ 81%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes2] PASSED [ 82%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[None] PASSED [ 84%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[value1] PASSED [ 86%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[1] PASSED [ 87%]
tests/discovery_runtime/test_parity_report.py::test_graph_preflight_reserves_input_before_projection PASSED [ 89%]
tests/discovery_runtime/test_parity_report.py::test_public_builder_reuses_complete_projection_with_independent_root_mode PASSED [ 91%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[parity-report-parity] PASSED [ 93%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[coverage-report-coverage] PASSED [ 94%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[authored\n# misleading-coverage] PASSED [ 96%]
tests/discovery_runtime/test_parity_report.py::test_graph_work_rejects_before_retaining_entry_locations PASSED [ 98%]
tests/discovery_runtime/test_parity_report.py::test_axis_output_budget_rejects_before_processing_remaining_rows PASSED [100%]

============================= 58 passed in 37.77s =============================
```
