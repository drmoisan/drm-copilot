# P5-T5 renderer tests

Timestamp: 2026-10-20T12-50

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.gherkin,drm_copilot_discovery.acceptance_render_text -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_gherkin.py tests/discovery_runtime/test_acceptance_tags.py tests/discovery_runtime/test_acceptance_render_limits.py`

EXIT_CODE: 0

Output Summary: PASS; 29.675 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 77 items

tests/discovery_runtime/test_gherkin.py::test_public_captured_generation_renders_exact_trace_and_steps[False] PASSED [  1%]
tests/discovery_runtime/test_gherkin.py::test_public_captured_generation_renders_exact_trace_and_steps[True] PASSED [  2%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[plain] PASSED [  3%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[quote-slash] PASSED [  5%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[controls] PASSED [  6%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[del-separators] PASSED [  7%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[unicode] PASSED [  9%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[pipe] PASSED [ 10%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[syntax] PASSED [ 11%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[html] PASSED [ 12%]
tests/discovery_runtime/test_gherkin.py::test_empty_given_has_no_synthetic_step PASSED [ 14%]
tests/discovery_runtime/test_gherkin.py::test_ready_pending_withheld_and_actions_remain_distinct PASSED [ 15%]
tests/discovery_runtime/test_gherkin.py::test_empty_and_blocked_generations_emit_markdown_only PASSED [ 16%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields0] PASSED [ 18%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields1] PASSED [ 19%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields2] PASSED [ 20%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields3] PASSED [ 22%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields4] PASSED [ 23%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields5] PASSED [ 24%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields6] PASSED [ 25%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[None] PASSED [ 27%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[value1] PASSED [ 28%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[value2] PASSED [ 29%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[ready] PASSED [ 31%]
tests/discovery_runtime/test_gherkin.py::test_public_carriers_are_immutable_sorted_and_encoding_checked PASSED [ 32%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths0] PASSED [ 33%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths1] PASSED [ 35%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths2] PASSED [ 36%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths3] PASSED [ 37%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths4] PASSED [ 38%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[/abs] PASSED [ 40%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[../escape] PASSED [ 41%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a\\b] PASSED [ 42%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[CON] PASSED [ 44%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a.] PASSED [ 45%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a\x00b] PASSED [ 46%]
tests/discovery_runtime/test_gherkin.py::test_exact_aggregate_bytes_include_paths_and_all_files PASSED [ 48%]
tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[bytes] PASSED [ 49%]
tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[work] PASSED [ 50%]
tests/discovery_runtime/test_gherkin.py::test_public_carrier_hard_limits_reject_before_large_copy PASSED [ 51%]
tests/discovery_runtime/test_gherkin.py::test_json_trace_preserves_scalar_types_and_nested_sequences PASSED [ 53%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[online-False] PASSED [ 54%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[offline-False] PASSED [ 55%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[mobile-False] PASSED [ 57%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[custom-True] PASSED [ 58%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[offline-True] PASSED [ 59%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[None] PASSED [ 61%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tag] PASSED [ 62%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags2] PASSED [ 63%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags3] PASSED [ 64%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags4] PASSED [ 66%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags5] PASSED [ 67%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags6] PASSED [ 68%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags7] PASSED [ 70%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags8] PASSED [ 71%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags9] PASSED [ 72%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags10] PASSED [ 74%]
tests/discovery_runtime/test_acceptance_tags.py::test_shared_tags_across_distinct_scenarios_are_not_collisions PASSED [ 75%]
tests/discovery_runtime/test_acceptance_tags.py::test_distinct_punctuation_is_preserved_in_tags_and_identity PASSED [ 76%]
tests/discovery_runtime/test_acceptance_tags.py::test_empty_tag_tuple_does_not_create_an_inferred_tag PASSED [ 77%]
tests/discovery_runtime/test_acceptance_tags.py::test_approved_target_trace_retains_original_decision_and_owner PASSED [ 79%]
tests/discovery_runtime/test_acceptance_tags.py::test_unknown_expected_behavior_remains_pending_markdown PASSED [ 80%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[ascii] PASSED [ 81%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[two-byte] PASSED [ 83%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[wide] PASSED [ 84%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[ascii] PASSED [ 85%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[two-byte] PASSED [ 87%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[wide] PASSED [ 88%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_path_measurement_rejects_invalid_scalars_and_capacity_types PASSED [ 89%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[depth] PASSED [ 90%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[nodes] PASSED [ 92%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[records] PASSED [ 93%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[sequence] PASSED [ 94%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_unicode_scalar_guard_precedes_encoding PASSED [ 96%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_escaped_output_work_is_reserved_before_detachment_and_encoding[False] PASSED [ 97%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_escaped_output_work_is_reserved_before_detachment_and_encoding[True] PASSED [ 98%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_tag_prefix_and_existing_tag_are_reserved_before_joining PASSED [100%]

============================= 77 passed in 27.74s =============================

```
