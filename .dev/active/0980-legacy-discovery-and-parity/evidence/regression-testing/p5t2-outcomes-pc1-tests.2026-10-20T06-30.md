# P5-T2 outcomes-pc1-tests

Timestamp: 2026-10-20T06-30

Command: poetry run pytest -v -o addopts= tests/discovery_runtime/test_parity_models.py tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py --cov=drm_copilot_discovery.parity_models --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_entry_rules --cov=drm_copilot_discovery.parity_target_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/outcomes-pc1-coverage.json

EXIT_CODE: 0

Output Summary: Exact scoped stage completed in 13.966s; raw bytes are retained in the JSON receipt.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 91 items

tests/discovery_runtime/test_parity_models.py::test_existing_findings_constructor_and_reexport_preserve_identity PASSED [  1%]
tests/discovery_runtime/test_parity_models.py::test_completed_outcome_keeps_authored_state_and_actual_proof_distinct PASSED [  2%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[missing] PASSED [  3%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[unassessed] PASSED [  4%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[partial] PASSED [  5%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[conflicting] PASSED [  6%]
tests/discovery_runtime/test_parity_models.py::test_every_duplicate_row_is_excluded_from_validated_completion PASSED [  7%]
tests/discovery_runtime/test_parity_models.py::test_invalid_source_preserves_an_invalid_authored_row PASSED [  8%]
tests/discovery_runtime/test_parity_models.py::test_upstream_findings_truncation_cannot_certify_complete_parity PASSED [  9%]
tests/discovery_runtime/test_parity_models.py::test_missing_target_proof_is_retained_even_when_authored_state_is_full PASSED [ 10%]
tests/discovery_runtime/test_parity_models.py::test_own_diagnostic_truncation_invalidates_an_otherwise_completed_row PASSED [ 12%]
tests/discovery_runtime/test_parity_models.py::test_retained_input_budget_rejects_before_target_proof_construction[artifact_records] PASSED [ 13%]
tests/discovery_runtime/test_parity_models.py::test_retained_input_budget_rejects_before_target_proof_construction[document_bytes] PASSED [ 14%]
tests/discovery_runtime/test_parity_models.py::test_aggregate_entry_work_is_reserved_before_source_resolution PASSED [ 15%]
tests/discovery_runtime/test_parity_rules.py::test_full_parity_uses_target_proof_and_preserves_snapshot PASSED [ 16%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000] PASSED [ 17%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[revision-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb] PASSED [ 18%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[feature_id-absent] PASSED [ 19%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[repository_id-foreign] PASSED [ 20%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[artifact_path-missing.json] PASSED [ 21%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[unassessed] PASSED [ 23%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[partial] PASSED [ 24%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[missing] PASSED [ 25%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[conflicting] PASSED [ 26%]
tests/discovery_runtime/test_parity_rules.py::test_entry_requires_configured_target_identity[target_repository-value0] PASSED [ 27%]
tests/discovery_runtime/test_parity_rules.py::test_entry_requires_configured_target_identity[client_id-absent] PASSED [ 28%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[checksum-value0] PASSED [ 29%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[path-None] PASSED [ 30%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[revision-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb] PASSED [ 31%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[repository-foreign] PASSED [ 32%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[environment-value4] PASSED [ 34%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[source] PASSED [ 35%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[documentation] PASSED [ 36%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[inventory] PASSED [ 37%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[decision] PASSED [ 38%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[client_id-absent] PASSED [ 39%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[target_repository-None] PASSED [ 40%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[implementation_paths-value2] PASSED [ 41%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[feature_refs-value3] PASSED [ 42%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[verification_state-failed] PASSED [ 43%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[test_references-value5] PASSED [ 45%]
tests/discovery_runtime/test_parity_rules.py::test_passing_component_cannot_mask_another_linked_incomplete_component[failed] PASSED [ 46%]
tests/discovery_runtime/test_parity_rules.py::test_passing_component_cannot_mask_another_linked_incomplete_component[not-run] PASSED [ 47%]
tests/discovery_runtime/test_parity_rules.py::test_full_result_cannot_hide_explicit_blockers[blockers-value0] PASSED [ 48%]
tests/discovery_runtime/test_parity_rules.py::test_full_result_cannot_hide_explicit_blockers[validation_status-fail] PASSED [ 49%]
tests/discovery_runtime/test_parity_rules.py::test_duplicate_entries_and_missing_required_entries_are_not_complete PASSED [ 50%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[None-blocked] PASSED [ 51%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[None-not-applicable] PASSED [ 52%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[Unavailable in the captured environment.-blocked] PASSED [ 53%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[Unavailable in the captured environment.-not-applicable] PASSED [ 54%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[None] PASSED [ 56%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[test_source1] PASSED [ 57%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[test_source2] PASSED [ 58%]
tests/discovery_runtime/test_parity_rules.py::test_one_passing_test_cannot_hide_an_explicit_failed_test PASSED [ 59%]
tests/discovery_runtime/test_parity_rules.py::test_capture_context_must_match_the_required_coordinate[other-online] PASSED [ 60%]
tests/discovery_runtime/test_parity_rules.py::test_capture_context_must_match_the_required_coordinate[browser-offline] PASSED [ 61%]
tests/discovery_runtime/test_parity_rules.py::test_wrong_target_revision_and_malformed_dimension_fail_without_exceptions PASSED [ 62%]
tests/discovery_runtime/test_parity_rules.py::test_non_evidence_source_links_do_not_disqualify_independent_target_capture PASSED [ 63%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[partial] PASSED [ 64%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[missing] PASSED [ 65%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[conflicting] PASSED [ 67%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[unassessed] PASSED [ 68%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-online] PASSED [ 69%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-offline] PASSED [ 70%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-mobile] PASSED [ 71%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-online] PASSED [ 72%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-offline] PASSED [ 73%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-mobile] PASSED [ 74%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-online] PASSED [ 75%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-offline] PASSED [ 76%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-mobile] PASSED [ 78%]
tests/discovery_runtime/test_parity_clients.py::test_matching_duplicate_online_classifications_are_valid PASSED [ 79%]
tests/discovery_runtime/test_parity_clients.py::test_required_dimension_cannot_be_absent_or_unverified[True] PASSED [ 80%]
tests/discovery_runtime/test_parity_clients.py::test_required_dimension_cannot_be_absent_or_unverified[False] PASSED [ 81%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[True-intentionally-changed] PASSED [ 82%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[True-retired] PASSED [ 83%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[False-intentionally-changed] PASSED [ 84%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[False-retired] PASSED [ 85%]
tests/discovery_runtime/test_parity_clients.py::test_retirement_does_not_hide_present_false_mode_claims[conflict] PASSED [ 86%]
tests/discovery_runtime/test_parity_clients.py::test_retirement_does_not_hide_present_false_mode_claims[proof] PASSED [ 87%]
tests/discovery_runtime/test_parity_clients.py::test_required_nonapplicability_needs_explicit_scoped_waiver[True] PASSED [ 89%]
tests/discovery_runtime/test_parity_clients.py::test_required_nonapplicability_needs_explicit_scoped_waiver[False] PASSED [ 90%]
tests/discovery_runtime/test_parity_clients.py::test_mobile_dimension_uses_configured_portable_platform PASSED [ 91%]
tests/discovery_runtime/test_parity_clients.py::test_passing_tests_cannot_cover_an_unrelated_coordinate[modes-value0] PASSED [ 92%]
tests/discovery_runtime/test_parity_clients.py::test_passing_tests_cannot_cover_an_unrelated_coordinate[platforms-value1] PASSED [ 93%]
tests/discovery_runtime/test_parity_clients.py::test_each_configured_client_has_an_independent_required_row PASSED [ 94%]
tests/discovery_runtime/test_parity_clients.py::test_combined_repository_source_test_proof_is_not_target_execution[False] PASSED [ 95%]
tests/discovery_runtime/test_parity_clients.py::test_combined_repository_source_test_proof_is_not_target_execution[True] PASSED [ 96%]
tests/discovery_runtime/test_parity_clients.py::test_imported_historical_source_is_resolved_at_its_own_pin PASSED [ 97%]
tests/discovery_runtime/test_parity_clients.py::test_reused_assessments_and_artifact_order_have_identical_findings PASSED [ 98%]
tests/discovery_runtime/test_parity_clients.py::test_target_proof_helpers_reject_invalid_direct_context PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py      139      2     56      3    97%   220->193, 268, 321
packages\discovery-runtime\src\drm_copilot_discovery\parity_models.py            35      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            104      0     38      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99      0     50      2    99%   101->98, 157->164
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           377      2    144      5    99%
Coverage JSON written to file SCRATCH/outcomes-pc1-coverage.json
============================= 91 passed in 11.94s =============================
```
