# P5-T1 models7-pytest

Timestamp: 2026-10-19T15-06
Command: poetry run pytest tests/discovery_runtime/test_report_models.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py -vv --cov=drm_copilot_discovery.report_models --cov=scripts.dev_tools.discovery.coverage_report --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/models7-coverage.json
EXIT_CODE: 0

Duration seconds: 2.202

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 114 items

tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[False-value0] PASSED [  0%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[False-value1] PASSED [  1%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[False-value2] PASSED [  2%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[False-value3] PASSED [  3%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[False-value4] PASSED [  4%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[True-value0] PASSED [  5%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[True-value1] PASSED [  6%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[True-value2] PASSED [  7%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[True-value3] PASSED [  7%]
tests/discovery_runtime/test_report_models.py::test_encoded_budget_matches_exact_serializer_cost[True-value4] PASSED [  8%]
tests/discovery_runtime/test_report_models.py::test_detached_report_views_preserve_exact_fields_and_order PASSED [  9%]
tests/discovery_runtime/test_report_models.py::test_markdown_has_independent_prospective_render_budget PASSED [ 10%]
tests/discovery_runtime/test_report_models.py::test_report_requires_an_object_root[value0] PASSED [ 11%]
tests/discovery_runtime/test_report_models.py::test_report_requires_an_object_root[value1] PASSED [ 12%]
tests/discovery_runtime/test_report_models.py::test_report_requires_an_object_root[text] PASSED [ 13%]
tests/discovery_runtime/test_report_models.py::test_report_requires_an_object_root[None] PASSED [ 14%]
tests/discovery_runtime/test_report_models.py::test_report_requires_an_object_root[1] PASSED [ 14%]
tests/discovery_runtime/test_report_models.py::test_malformed_values_fail_with_fixed_diagnostics[value0-keys must be strings] PASSED [ 15%]
tests/discovery_runtime/test_report_models.py::test_malformed_values_fail_with_fixed_diagnostics[value1-JSON-compatible] PASSED [ 16%]
tests/discovery_runtime/test_report_models.py::test_malformed_values_fail_with_fixed_diagnostics[value2-finite] PASSED [ 17%]
tests/discovery_runtime/test_report_models.py::test_malformed_values_fail_with_fixed_diagnostics[value3-finite] PASSED [ 18%]
tests/discovery_runtime/test_report_models.py::test_malformed_values_fail_with_fixed_diagnostics[value4-invalid Unicode] PASSED [ 19%]
tests/discovery_runtime/test_report_models.py::test_oversized_integer_is_rejected_before_decimal_render[9223372036854775808] PASSED [ 20%]
tests/discovery_runtime/test_report_models.py::test_oversized_integer_is_rejected_before_decimal_render[-9223372036854775808] PASSED [ 21%]
tests/discovery_runtime/test_report_models.py::test_oversized_integer_is_rejected_before_decimal_render[10715086071862673209484250490600018105614048117055336074437503883703510511249361224931983788156958581275946729175531468251871452856923140435984577574698574803934567774824230985421074605062371141877954182153046474983581941267398767559165543946077062914571196477686542167660429831652624386837205668069376] PASSED [ 21%]
tests/discovery_runtime/test_report_models.py::test_budget_checks_records_nodes_depth_and_cycles PASSED [ 22%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[work-True] PASSED [ 23%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[work-False] PASSED [ 24%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[work-1.5] PASSED [ 25%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[work--1] PASSED [ 26%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[work-65] PASSED [ 27%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[spend-True] PASSED [ 28%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[spend-False] PASSED [ 28%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[spend-1.5] PASSED [ 29%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[spend--1] PASSED [ 30%]
tests/discovery_runtime/test_report_models.py::test_reservations_require_exact_bounded_integers[spend-65] PASSED [ 31%]
tests/discovery_runtime/test_report_models.py::test_work_capacity_is_independent_and_reserved_before_execution PASSED [ 32%]
tests/discovery_runtime/test_report_models.py::test_depth_guard_rejects_ambiguous_or_excessive_values[True] PASSED [ 33%]
tests/discovery_runtime/test_report_models.py::test_depth_guard_rejects_ambiguous_or_excessive_values[0] PASSED [ 34%]
tests/discovery_runtime/test_report_models.py::test_depth_guard_rejects_ambiguous_or_excessive_values[-1] PASSED [ 35%]
tests/discovery_runtime/test_report_models.py::test_depth_guard_rejects_ambiguous_or_excessive_values[129] PASSED [ 35%]
tests/discovery_runtime/test_report_models.py::test_depth_guard_rejects_ambiguous_or_excessive_values[1.5] PASSED [ 36%]
tests/discovery_runtime/test_report_models.py::test_exact_node_exhaustion_rejects_the_next_scalar PASSED [ 37%]
tests/discovery_runtime/test_report_models.py::test_constructor_rejects_ambiguous_policy[None-False] PASSED [ 38%]
tests/discovery_runtime/test_report_models.py::test_constructor_rejects_ambiguous_policy[limits1-1] PASSED [ 39%]
tests/discovery_runtime/test_report_models.py::test_ratio_keeps_count_units_and_null_empty_denominators[0-0] PASSED [ 40%]
tests/discovery_runtime/test_report_models.py::test_ratio_keeps_count_units_and_null_empty_denominators[0-1] PASSED [ 41%]
tests/discovery_runtime/test_report_models.py::test_ratio_keeps_count_units_and_null_empty_denominators[1-3] PASSED [ 42%]
tests/discovery_runtime/test_report_models.py::test_ratio_keeps_count_units_and_null_empty_denominators[3-3] PASSED [ 42%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[True-1-x] PASSED [ 43%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[1-False-x] PASSED [ 44%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[-1-1-x] PASSED [ 45%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[2-1-x] PASSED [ 46%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[0-9223372036854775808-x] PASSED [ 47%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[0-0-] PASSED [ 48%]
tests/discovery_runtime/test_report_models.py::test_ratio_rejects_unsupported_or_misleading_counts[0-0-None] PASSED [ 49%]
tests/discovery_runtime/test_report_models.py::test_legacy_helpers_preserve_true_v1_rows_without_completion[None] PASSED [ 50%]
tests/discovery_runtime/test_report_models.py::test_legacy_helpers_preserve_true_v1_rows_without_completion[1.0.0] PASSED [ 50%]
tests/discovery_runtime/test_report_models.py::test_legacy_helpers_preserve_true_v1_rows_without_completion[1.2.3] PASSED [ 51%]
tests/discovery_runtime/test_report_models.py::test_explicit_non_v1_version_cannot_enter_compatibility_projection[2.0.0] PASSED [ 52%]
tests/discovery_runtime/test_report_models.py::test_explicit_non_v1_version_cannot_enter_compatibility_projection[1_0] PASSED [ 53%]
tests/discovery_runtime/test_report_models.py::test_explicit_non_v1_version_cannot_enter_compatibility_projection[1.0.0suffix] PASSED [ 54%]
tests/discovery_runtime/test_report_models.py::test_explicit_non_v1_version_cannot_enter_compatibility_projection[1_1] PASSED [ 55%]
tests/discovery_runtime/test_report_models.py::test_explicit_non_v1_version_cannot_enter_compatibility_projection[True] PASSED [ 56%]
tests/discovery_runtime/test_report_models.py::test_legacy_parser_rejects_malformed_duplicate_or_nonfinite_text[{} {}] PASSED [ 57%]
tests/discovery_runtime/test_report_models.py::test_legacy_parser_rejects_malformed_duplicate_or_nonfinite_text[[]] PASSED [ 57%]
tests/discovery_runtime/test_report_models.py::test_legacy_parser_rejects_malformed_duplicate_or_nonfinite_text[{"a":1,"a":2}] PASSED [ 58%]
tests/discovery_runtime/test_report_models.py::test_legacy_parser_rejects_malformed_duplicate_or_nonfinite_text[{"a":NaN}] PASSED [ 59%]
tests/discovery_runtime/test_report_models.py::test_legacy_rows_reject_invalid_entry_shapes[None] PASSED [ 60%]
tests/discovery_runtime/test_report_models.py::test_legacy_rows_reject_invalid_entry_shapes[entries1] PASSED [ 61%]
tests/discovery_runtime/test_report_models.py::test_legacy_rows_reject_invalid_entry_shapes[entries2] PASSED [ 62%]
tests/discovery_runtime/test_report_models.py::test_legacy_rows_reject_invalid_entry_shapes[entries3] PASSED [ 63%]
tests/discovery_runtime/test_report_models.py::test_legacy_missing_entries_remains_an_empty_per_artifact_result PASSED [ 64%]
tests/discovery_runtime/test_report_models.py::test_oversized_input_fails_before_detached_copy PASSED [ 64%]
tests/discovery_runtime/test_report_models.py::test_immutable_budget_and_copy_traverse_members_without_key_search[1] PASSED [ 65%]
tests/discovery_runtime/test_report_models.py::test_immutable_budget_and_copy_traverse_members_without_key_search[16] PASSED [ 66%]
tests/discovery_runtime/test_report_models.py::test_immutable_budget_and_copy_traverse_members_without_key_search[64] PASSED [ 67%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries PASSED [ 68%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_render_coverage_report_is_deterministic PASSED [ 69%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_coverage_rows_handles_missing_entries_key PASSED [ 71%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_0_on_success PASSED [ 71%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_on_failure PASSED [ 72%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 73%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.0.0] PASSED [ 74%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.2.3] PASSED [ 75%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[secret malformed text] PASSED [ 76%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[null] PASSED [ 77%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[[]] PASSED [ 78%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": null}] PASSED [ 78%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": {}}] PASSED [ 79%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": ["secret"]}] PASSED [ 80%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [], "entries": []}] PASSED [ 81%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [{"secret": NaN}]}] PASSED [ 82%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.0.0", "entries": []}] PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.99.0", "entries": []}] PASSED [ 84%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "unknown", "entries": []}] PASSED [ 85%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[parse_coverage_ledger] PASSED [ 85%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[build_coverage_rows] PASSED [ 86%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[render_coverage_report] PASSED [ 87%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_path_and_validator_seams_preserve_call_order PASSED [ 88%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_default_validator_and_sys_argv_remain_injectable PASSED [ 89%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments0] PASSED [ 90%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments1] PASSED [ 91%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments2] PASSED [ 92%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[read_artifact_text] PASSED [ 92%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[write_report] PASSED [ 93%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_sorts_ascending_by_id_field PASSED [ 94%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_falls_back_to_joined_field_sort_when_id_absent PASSED [ 95%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_falls_back_when_id_field_partially_present PASSED [ 96%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_render_pretty_json_exact_literal_output PASSED [ 97%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_render_pretty_json_is_deterministic PASSED [ 98%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_coverage_adapter_retains_pretty_json_escaping_and_single_lf PASSED [ 99%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_explicit_v1_unit_sort_preserves_rows_and_original_order PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py     141      0     64      0   100%
scripts\dev_tools\discovery\coverage_report.py                             38      0      4      0   100%
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     179      0     68      0   100%
Coverage JSON written to file SCRATCH/models7-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
============================= 114 passed in 0.43s =============================

```
