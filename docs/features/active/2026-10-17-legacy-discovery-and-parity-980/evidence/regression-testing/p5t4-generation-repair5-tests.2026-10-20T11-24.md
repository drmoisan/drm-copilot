# P5-T4 generation tests

Timestamp: 2026-10-20T11-19

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.acceptance_generation,drm_copilot_discovery.acceptance_generation_context -m pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py tests/discovery_runtime/test_acceptance_generation_limits.py`

EXIT_CODE: 0

Output Summary: PASS; 305.832 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 49 items

tests/discovery_runtime/test_acceptance_generation.py::test_generation_retains_exact_identity_refs_and_rule_authority[False] PASSED [  2%]
tests/discovery_runtime/test_acceptance_generation.py::test_generation_retains_exact_identity_refs_and_rule_authority[True] PASSED [  4%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[statement] PASSED [  6%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[expected] PASSED [  8%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[revision] PASSED [ 10%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[whitespace] PASSED [ 12%]
tests/discovery_runtime/test_acceptance_generation.py::test_pending_criteria_preserve_questions_and_never_invent_then[The observed result is unknown.] PASSED [ 14%]
tests/discovery_runtime/test_acceptance_generation.py::test_pending_criteria_preserve_questions_and_never_invent_then[Unicode \u7d50\u679c remains unverified.] PASSED [ 16%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[feature_ids-selection0] PASSED [ 18%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[client_ids-selection1] PASSED [ 20%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[mode_ids-selection2] PASSED [ 22%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[malformed] PASSED [ 24%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[missing-profile] PASSED [ 26%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[pins] PASSED [ 28%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[draft] PASSED [ 30%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[duplicate] PASSED [ 32%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[approved] PASSED [ 34%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[proposed] PASSED [ 36%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[rejected] PASSED [ 38%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[superseded] PASSED [ 40%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[scope] PASSED [ 42%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[conflict] PASSED [ 44%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[invalid-ref] PASSED [ 46%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[identity-conflict] PASSED [ 48%]
tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations PASSED [ 51%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[applicable] PASSED [ 53%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[unspecified] PASSED [ 55%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[not-applicable] PASSED [ 57%]
tests/discovery_runtime/test_acceptance_decisions.py::test_imported_source_retains_original_provenance_and_distinct_target_owner PASSED [ 59%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[32-16] PASSED [ 61%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[4096-16] PASSED [ 63%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[4096-32] PASSED [ 65%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-criteria] PASSED [ 67%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-modes] PASSED [ 69%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-platforms] PASSED [ 71%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_two_complete_rule_passes_are_independent_of_candidate_count PASSED [ 73%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_invalid_selectors_fail_without_coercion[None] PASSED [ 75%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_invalid_selectors_fail_without_coercion[value1] PASSED [ 77%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_invalid_selectors_fail_without_coercion[value2] PASSED [ 79%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_invalid_selectors_fail_without_coercion[value3] PASSED [ 81%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_invalid_selectors_fail_without_coercion[value4] PASSED [ 83%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_capacity_exhaustion_precedes_public_assessment[source_files] PASSED [ 85%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_capacity_exhaustion_precedes_public_assessment[document_bytes] PASSED [ 87%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_capacity_exhaustion_precedes_public_assessment[artifact_records] PASSED [ 89%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_batch_pass_limit_and_output_capacity_fail_without_partial_result PASSED [ 91%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_unsupported_kinds_cannot_select_an_implicit_generation_mode[None] PASSED [ 93%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_unsupported_kinds_cannot_select_an_implicit_generation_mode[True] PASSED [ 95%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_unsupported_kinds_cannot_select_an_implicit_generation_mode[other] PASSED [ 97%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_legacy_client_selector_is_an_explicit_failure PASSED [100%]

======================= 49 passed in 304.02s (0:05:04) ========================

```
