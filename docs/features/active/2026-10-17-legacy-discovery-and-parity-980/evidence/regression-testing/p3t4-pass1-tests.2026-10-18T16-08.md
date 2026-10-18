# p3t4-pass1-tests

Timestamp: 2026-10-18T16-08
Command: poetry run python SCRATCH/issue-980-p3t4-tests.py pass1
EXIT_CODE: 0
Output Summary: 20.36s call     tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields3]; 20.26s call     tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields1]; ======================= 78 passed in 715.59s (0:11:55) ========================; {"started_at_utc": "2026-10-18T15:56:41.231379+00:00", "ended_at_utc": "2026-10-18T16:08:37.066398+00:00", "elapsed_seconds": 715.835017999998, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_stable": true, "reverse": false}

Working directory: .
Started: 2026-10-18T15:56:40.367639+00:00
Duration seconds: 716.788
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

tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[acceptance_criteria] PASSED [  1%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[id] PASSED [  2%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[lifecycle] PASSED [  3%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[observation_state] PASSED [  5%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[product_decision_status] PASSED [  6%]
tests/discovery_runtime/test_draft_contracts.py::test_creation_rejects_supplied_identity_or_completed_claims[source_evidence_refs] PASSED [  7%]
tests/discovery_runtime/test_draft_contracts.py::test_draft_dimensions_cannot_upgrade_observation_states[intentionally-unspecified] PASSED [  8%]
tests/discovery_runtime/test_draft_contracts.py::test_draft_dimensions_cannot_upgrade_observation_states[verified] PASSED [ 10%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[duplicate-id] PASSED [ 11%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[existing-path] PASSED [ 12%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[missing-grant] PASSED [ 14%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[wrong-id] PASSED [ 15%]
tests/discovery_runtime/test_draft_contracts.py::test_exact_grants_and_existing_id_collisions_fail_before_effects[wrong-kind] PASSED [ 16%]
tests/discovery_runtime/test_draft_contracts.py::test_existing_question_records_and_extensions_are_preserved PASSED [ 17%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_existing_collection_preserves_typed_loader_findings PASSED [ 19%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields0] PASSED [ 20%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields1] PASSED [ 21%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields2] PASSED [ 23%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields3] PASSED [ 24%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_proposed_fields_reach_accepted_complete_graph_validation[fields4] PASSED [ 25%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[dimensions] PASSED [ 26%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[empty-name] PASSED [ 28%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[mutable-fields] PASSED [ 29%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unknown-dimension] PASSED [ 30%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unresolved-links] PASSED [ 32%]
tests/discovery_runtime/test_draft_contracts.py::test_invalid_request_boundaries_are_explicit[unsafe-id] PASSED [ 33%]
tests/discovery_runtime/test_draft_contracts.py::test_shared_json_values_do_not_mint_native_authority PASSED [ 34%]
tests/discovery_runtime/test_draft_contracts.py::test_supplied_inference_and_unknown_transition_remain_explicit PASSED [ 35%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[evidence_refs-value3] PASSED [ 37%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[feature_refs-value5] PASSED [ 38%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[repeatability-repeatable] PASSED [ 39%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[result_status-passed] PASSED [ 41%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[runs-value1] PASSED [ 42%]
tests/discovery_runtime/test_draft_scenarios.py::test_creation_rejects_execution_and_identity_overrides[scenario_id-other] PASSED [ 43%]
tests/discovery_runtime/test_draft_scenarios.py::test_feature_order_is_normalized_without_changing_selection PASSED [ 44%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[bad-links] PASSED [ 46%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[duplicate-features] PASSED [ 47%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[empty-features] PASSED [ 48%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[missing-input] PASSED [ 50%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[mutable-fields] PASSED [ 51%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[unsafe-feature] PASSED [ 52%]
tests/discovery_runtime/test_draft_scenarios.py::test_invalid_scenario_request_boundaries_are_explicit[unsafe-scenario] PASSED [ 53%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields0] PASSED [ 55%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields1] PASSED [ 56%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields2] PASSED [ 57%]
tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields3] PASSED [ 58%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[existing-scenario] PASSED [ 60%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[missing-feature] PASSED [ 61%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[missing-grant] PASSED [ 62%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[one-missing] PASSED [ 64%]
tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[question-collision] PASSED [ 65%]
tests/discovery_runtime/test_draft_scenarios.py::test_planned_captures_do_not_accept_observed_state[post_state_capture] PASSED [ 66%]
tests/discovery_runtime/test_draft_scenarios.py::test_planned_captures_do_not_accept_observed_state[pre_state_capture] PASSED [ 67%]
tests/discovery_runtime/test_draft_scenarios.py::test_stale_selected_inputs_fail_shared_commit_without_publication PASSED [ 69%]
tests/discovery_runtime/test_draft_scenarios.py::test_supplied_known_expectation_needs_actual_source_support PASSED [ 70%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[False] PASSED [ 71%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[True] PASSED [ 73%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[False] PASSED [ 74%]
tests/discovery_runtime/test_draft_contracts.py::test_contract_projects_truthful_graph_with_inherited_dimensions[True] PASSED [ 75%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-action] PASSED [ 76%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-after] PASSED [ 78%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[inferred-False-before] PASSED [ 79%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-action] PASSED [ 80%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-after] PASSED [ 82%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[intentionally-unspecified-False-before] PASSED [ 83%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-action] PASSED [ 84%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-after] PASSED [ 85%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-False-before] PASSED [ 87%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-action] PASSED [ 88%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-after] PASSED [ 89%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[unknown-True-before] PASSED [ 91%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-action] PASSED [ 92%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-after] PASSED [ 93%]
tests/discovery_runtime/test_draft_contracts.py::test_nested_transition_phases_keep_draft_claims_and_question_links[verified-False-before] PASSED [ 94%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False] PASSED [ 96%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[True] PASSED [ 97%]
tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False] PASSED [ 98%]
tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[True] PASSED [100%]

- generated xml file: SCRATCH\issue-980-p3t4-pass1-tests.xml -
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                      Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\draft_contracts.py     120      1     38      1    99%   145
packages\discovery-runtime\src\drm_copilot_discovery\draft_scenarios.py      50      0     14      0   100%
---------------------------------------------------------------------------------------------------------------------
TOTAL                                                                       170      1     52      1    99%
Coverage JSON written to file SCRATCH\issue-980-p3t4-pass1-coverage.json
============================= slowest 8 durations =============================
92.70s call     tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False]
48.60s call     tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[True]
47.20s call     tests/discovery_runtime/test_draft_contracts.py::test_contract_creation_uses_shared_writer_without_changing_unrelated_content[False]
31.65s call     tests/discovery_runtime/test_draft_scenarios.py::test_stale_selected_inputs_fail_shared_commit_without_publication
22.79s call     tests/discovery_runtime/test_draft_scenarios.py::test_missing_links_exact_grants_and_collisions_cannot_publish[question-collision]
20.98s call     tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[True]
20.36s call     tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields3]
20.26s call     tests/discovery_runtime/test_draft_scenarios.py::test_malformed_plans_are_rejected_by_the_existing_graph_validator[fields1]
======================= 78 passed in 715.59s (0:11:55) ========================
{"started_at_utc": "2026-10-18T15:56:41.231379+00:00", "ended_at_utc": "2026-10-18T16:08:37.066398+00:00", "elapsed_seconds": 715.835017999998, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1", "tests/discovery_runtime/test_draft_contracts.py": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296", "tests/discovery_runtime/test_draft_scenarios.py": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108", "tests/discovery_runtime/draft_test_support.py": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236"}, "source_stable": true, "reverse": false}
```
