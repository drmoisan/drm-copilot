# P5-T2 graph tests

Timestamp: 2026-10-20T07-03

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.parity_report,drm_copilot_discovery.parity_metrics,drm_copilot_discovery.report_models -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_parity_axes.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs tests/discovery_runtime/test_parity_report.py::test_graph_preflight_reserves_input_before_projection tests/discovery_runtime/test_parity_report.py::test_public_builder_reuses_complete_projection_with_independent_root_mode tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind tests/discovery_runtime/test_parity_report.py::test_graph_work_rejects_before_retaining_entry_locations tests/discovery_runtime/test_parity_report.py::test_axis_output_budget_rejects_before_processing_remaining_rows`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 39.609 seconds.

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
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[8] FAILED [ 34%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[32] FAILED [ 36%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[64] FAILED [ 37%]
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

================================== FAILURES ===================================
_________ test_custom_mode_membership_has_prospective_linear_work[8] __________
tests\discovery_runtime\test_parity_axes.py:219: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == modes.comparisons == 0
E   AssertionError: assert 16 == 0
E    +  where 16 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007').visits
E    +  and   0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007').comparisons
_________ test_custom_mode_membership_has_prospective_linear_work[32] _________
tests\discovery_runtime\test_parity_axes.py:219: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == modes.comparisons == 0
E   AssertionError: assert 64 == 0
E    +  where 64 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031').visits
E    +  and   0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031').comparisons
_________ test_custom_mode_membership_has_prospective_linear_work[64] _________
tests\discovery_runtime\test_parity_axes.py:219: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == modes.comparisons == 0
E   AssertionError: assert 128 == 0
E    +  where 128 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031', 'custom-032', 'custom-033', 'custom-034', 'custom-035', 'custom-036', 'custom-037', 'custom-038', 'custom-039', 'custom-040', 'custom-041', 'custom-042', 'custom-043', 'custom-044', 'custom-045', 'custom-046', 'custom-047', 'custom-048', 'custom-049', 'custom-050', 'custom-051', 'custom-052', 'custom-053', 'custom-054', 'custom-055', 'custom-056', 'custom-057', 'custom-058', 'custom-059', 'custom-060', 'custom-061', 'custom-062', 'custom-063').visits
E    +  and   0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031', 'custom-032', 'custom-033', 'custom-034', 'custom-035', 'custom-036', 'custom-037', 'custom-038', 'custom-039', 'custom-040', 'custom-041', 'custom-042', 'custom-043', 'custom-044', 'custom-045', 'custom-046', 'custom-047', 'custom-048', 'custom-049', 'custom-050', 'custom-051', 'custom-052', 'custom-053', 'custom-054', 'custom-055', 'custom-056', 'custom-057', 'custom-058', 'custom-059', 'custom-060', 'custom-061', 'custom-062', 'custom-063').comparisons
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[8]
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[32]
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[64]
======================== 3 failed, 55 passed in 37.80s ========================
```
