# p3t4-pass1-reverse

Timestamp: 2026-10-18T16-15
Command: poetry run python SCRATCH/issue-980-p3t4-tests.py reverse1
EXIT_CODE: 0
Output Summary: 8.78s call     tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False]; 8.60s call     tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[one-missing]; ======================= 78 passed in 307.05s (0:05:07) ========================; {"started_at_utc": "2026-10-18T16:10:26.757676+00:00", "ended_at_utc": "2026-10-18T16:15:33.954776+00:00", "elapsed_seconds": 307.1970982000057, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_stable": true, "reverse": true}

Working directory: .
Started: 2026-10-18T16:10:25.873001+00:00
Duration seconds: 308.155
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 78 items

tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[True] PASSED [  1%]
tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False] PASSED [  2%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[True] PASSED [  3%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False] PASSED [  5%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-before] PASSED [  6%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-after] PASSED [  7%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-action] PASSED [  8%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-before] PASSED [ 10%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-after] PASSED [ 11%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-action] PASSED [ 12%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-before] PASSED [ 14%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-after] PASSED [ 15%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-action] PASSED [ 16%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-before] PASSED [ 17%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-after] PASSED [ 19%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-action] PASSED [ 20%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-before] PASSED [ 21%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-after] PASSED [ 23%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-action] PASSED [ 24%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[True] PASSED [ 25%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[False] PASSED [ 26%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[True] PASSED [ 28%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[False] PASSED [ 29%]
tests/discovery_runtime/test_draft_scenarios.py::test_supplied_known_expectation_needs_actual_source_support PASSED [ 30%]
tests/discovery_runtime/test_draft_scenarios.py::test_stale_selected_inputs_fail_shared_commit_without_publication PASSED [ 32%]
tests/discovery_runtime/test_draft_scenarios.py::test_planned_captures_do_not_accept_observed_state[pre_state_capture] PASSED [ 33%]
tests/discovery_runtime/test_draft_scenarios.py::test_planned_captures_do_not_accept_observed_state[post_state_capture] PASSED [ 34%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[question-collision] PASSED [ 35%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[one-missing] PASSED [ 37%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[missing-grant] PASSED [ 38%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[missing-feature] PASSED [ 39%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[existing-scenario] PASSED [ 41%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields3] PASSED [ 42%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields2] PASSED [ 43%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields1] PASSED [ 44%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields0] PASSED [ 46%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[unsafe-scenario] PASSED [ 47%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[unsafe-feature] PASSED [ 48%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[mutable-fields] PASSED [ 50%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[missing-input] PASSED [ 51%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[empty-features] PASSED [ 52%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[duplicate-features] PASSED [ 53%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[bad-links] PASSED [ 55%]
tests/discovery_runtime/test_draft_scenarios.py::test_feature_order_is_normalized_without_changing_selection PASSED [ 56%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[scenario_id-other] PASSED [ 57%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[runs-value1] PASSED [ 58%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[result_status-passed] PASSED [ 60%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[repeatability-repeatable] PASSED [ 61%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[feature_refs-value5] PASSED [ 62%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[evidence_refs-value3] PASSED [ 64%]
tests/discovery_runtime/test_draft_contracts.py::test_supplied_inference_and_unknown_transition_remain_explicit PASSED [ 65%]
tests/discovery_runtime/test_draft_contracts.py::test_shared_json_values_do_not_mint_native_authority PASSED [ 66%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unsafe-id] PASSED [ 67%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unresolved-links] PASSED [ 69%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unknown-dimension] PASSED [ 70%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[mutable-fields] PASSED [ 71%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[empty-name] PASSED [ 73%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[dimensions] PASSED [ 74%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields4] PASSED [ 75%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields3] PASSED [ 76%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields2] PASSED [ 78%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields1] PASSED [ 79%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields0] PASSED [ 80%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_existing_collection_preserves_typed_loader_findings PASSED [ 82%]
tests/discovery_runtime/test_draft_contracts.py::test_existing_question_records_and_extensions_are_preserved PASSED [ 83%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[wrong-kind] PASSED [ 84%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[wrong-id] PASSED [ 85%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[missing-grant] PASSED [ 87%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[existing-path] PASSED [ 88%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[duplicate-id] PASSED [ 89%]
tests/discovery_runtime/test_draft_contracts.py::test_draft_dimensions_cannot_upgrade_observation_states[verified] PASSED [ 91%]
tests/discovery_runtime/test_draft_contracts.py::test_draft_dimensions_cannot_upgrade_observation_states[intentionally-unspecified] PASSED [ 92%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[source_evidence_refs] PASSED [ 93%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[product_decision_status] PASSED [ 94%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[observation_state] PASSED [ 96%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[lifecycle] PASSED [ 97%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[id] PASSED [ 98%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[acceptance_criteria] PASSED [100%]

- generated xml file: SCRATCH\issue-980-p3t4-reverse1-tests.xml -
============================= slowest 8 durations =============================
42.66s call     tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False]
20.52s call     tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[True]
20.42s call     tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[False]
12.89s call     tests/discovery_runtime/test_draft_scenarios.py::test_stale_selected_inputs_fail_shared_commit_without_publication
10.17s call     tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[question-collision]
9.01s call     tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[True]
8.78s call     tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False]
8.60s call     tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[one-missing]
======================= 78 passed in 307.05s (0:05:07) ========================
{"started_at_utc": "2026-10-18T16:10:26.757676+00:00", "ended_at_utc": "2026-10-18T16:15:33.954776+00:00", "elapsed_seconds": 307.1970982000057, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_stable": true, "reverse": true}
```
