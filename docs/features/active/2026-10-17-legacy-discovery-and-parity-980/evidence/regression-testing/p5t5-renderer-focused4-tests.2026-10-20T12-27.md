# P5-T5 renderer tests

Timestamp: 2026-10-20T12-26

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.gherkin -m pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_gherkin.py tests/discovery_runtime/test_acceptance_tags.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 29.072 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 62 items

tests/discovery_runtime/test_gherkin.py::test_public_captured_generation_renders_exact_trace_and_steps[False] PASSED [  1%]
tests/discovery_runtime/test_gherkin.py::test_public_captured_generation_renders_exact_trace_and_steps[True] PASSED [  3%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[plain] PASSED [  4%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[quote-slash] PASSED [  6%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[controls] PASSED [  8%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[del-separators] PASSED [  9%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[unicode] PASSED [ 11%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[pipe] PASSED [ 12%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[syntax] PASSED [ 14%]
tests/discovery_runtime/test_gherkin.py::test_authored_statements_stay_one_reversible_json_literal[html] PASSED [ 16%]
tests/discovery_runtime/test_gherkin.py::test_empty_given_has_no_synthetic_step PASSED [ 17%]
tests/discovery_runtime/test_gherkin.py::test_ready_pending_withheld_and_actions_remain_distinct PASSED [ 19%]
tests/discovery_runtime/test_gherkin.py::test_empty_and_blocked_generations_emit_markdown_only PASSED [ 20%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields0] PASSED [ 22%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields1] PASSED [ 24%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields2] PASSED [ 25%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields3] PASSED [ 27%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields4] PASSED [ 29%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields5] PASSED [ 30%]
tests/discovery_runtime/test_gherkin.py::test_malformed_structural_candidates_are_not_executable[fields6] PASSED [ 32%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[None] PASSED [ 33%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[value1] PASSED [ 35%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[value2] PASSED [ 37%]
tests/discovery_runtime/test_gherkin.py::test_only_exact_generation_carriers_are_accepted[ready] PASSED [ 38%]
tests/discovery_runtime/test_gherkin.py::test_public_carriers_are_immutable_sorted_and_encoding_checked PASSED [ 40%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths0] PASSED [ 41%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths1] PASSED [ 43%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths2] PASSED [ 45%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths3] PASSED [ 46%]
tests/discovery_runtime/test_gherkin.py::test_portable_output_collisions_are_rejected[paths4] PASSED [ 48%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[/abs] PASSED [ 50%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[../escape] PASSED [ 51%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a\\b] PASSED [ 53%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[CON] PASSED [ 54%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a.] PASSED [ 56%]
tests/discovery_runtime/test_gherkin.py::test_unsafe_file_paths_are_rejected[a\x00b] PASSED [ 58%]
tests/discovery_runtime/test_gherkin.py::test_exact_aggregate_bytes_include_paths_and_all_files PASSED [ 59%]
tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[bytes] FAILED [ 61%]
tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[work] PASSED [ 62%]
tests/discovery_runtime/test_gherkin.py::test_public_carrier_hard_limits_reject_before_large_copy PASSED [ 64%]
tests/discovery_runtime/test_gherkin.py::test_json_trace_preserves_scalar_types_and_nested_sequences PASSED [ 66%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[online-False] PASSED [ 67%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[offline-False] PASSED [ 69%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[mobile-False] PASSED [ 70%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[custom-True] PASSED [ 72%]
tests/discovery_runtime/test_acceptance_tags.py::test_exact_generated_tags_survive_without_name_inference[offline-True] PASSED [ 74%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[None] PASSED [ 75%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tag] PASSED [ 77%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags2] PASSED [ 79%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags3] PASSED [ 80%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags4] PASSED [ 82%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags5] PASSED [ 83%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags6] PASSED [ 85%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags7] PASSED [ 87%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags8] PASSED [ 88%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags9] PASSED [ 90%]
tests/discovery_runtime/test_acceptance_tags.py::test_unsafe_ambiguous_or_unsorted_tags_fail_closed[tags10] PASSED [ 91%]
tests/discovery_runtime/test_acceptance_tags.py::test_shared_tags_across_distinct_scenarios_are_not_collisions PASSED [ 93%]
tests/discovery_runtime/test_acceptance_tags.py::test_distinct_punctuation_is_preserved_in_tags_and_identity PASSED [ 95%]
tests/discovery_runtime/test_acceptance_tags.py::test_empty_tag_tuple_does_not_create_an_inferred_tag PASSED [ 96%]
tests/discovery_runtime/test_acceptance_tags.py::test_approved_target_trace_retains_original_decision_and_owner FAILED [ 98%]
tests/discovery_runtime/test_acceptance_tags.py::test_unknown_expected_behavior_remains_pending_markdown PASSED [100%]

================================== FAILURES ===================================
_____ test_escape_and_text_work_are_reserved_before_serialization[bytes] ______
tests\discovery_runtime\test_gherkin.py:347: in test_escape_and_text_work_are_reserved_before_serialization
    result = generation((item,), (item,), limits=limits)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_acceptance_properties.py:112: in generation
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\acceptance_models.py:385: in __post_init__
    content = _encoded(item.document, budget, 2)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\acceptance_models.py:307: in _encoded
    budget.check(value)
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:144: in check
    self.check(child, depth + 1)
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:156: in check
    self.check(child, depth + 1)
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:158: in check
    self.text(value)
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:103: in text
    self.spend(
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:79: in spend
    raise ReportLimitError()
E   drm_copilot_discovery.report_models.ReportLimitError: REPORT_LIMIT: report exceeds configured resource limits
_______ test_approved_target_trace_retains_original_decision_and_owner ________
tests\discovery_runtime\test_acceptance_tags.py:143: in test_approved_target_trace_retains_original_decision_and_owner
    assert as_object(trace["specification"])["product_decision_refs"]
E   assert []
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[bytes]
FAILED tests/discovery_runtime/test_acceptance_tags.py::test_approved_target_trace_retains_original_decision_and_owner
======================== 2 failed, 60 passed in 27.22s ========================

```
