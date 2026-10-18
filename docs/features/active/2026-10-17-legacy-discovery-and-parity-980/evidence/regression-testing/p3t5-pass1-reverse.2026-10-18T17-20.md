# p3t5-pass1-reverse

Timestamp: 2026-10-18T17-20
Command: poetry run python SCRATCH\issue-980-p3t5-tests.py reverse1
EXIT_CODE: 0
Output Summary: 3.09s call     tests/discovery_runtime/test_evidence_payloads.py::test_uri_description_cannot_be_registered_as_locally_verified_evidence; 3.07s setup    tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan; ============================= 61 passed in 52.03s =============================; {"started_at_utc": "2026-10-18T17:19:55.491315+00:00", "ended_at_utc": "2026-10-18T17:20:47.676319+00:00", "elapsed_seconds": 52.18500189999759, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392", "tests/discovery_runtime/test_evidence_payloads.py": "c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392", "tests/discovery_runtime/test_evidence_payloads.py": "c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_stable": true, "reverse": true}

Working directory: .
Started: 2026-10-18T17:19:54.610298+00:00
Duration seconds: 53.142
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
{"label": "reverse1", "pytest_arguments": ["-o", "addopts=-ra", "tests/discovery_runtime/test_evidence_linking.py", "tests/discovery_runtime/test_evidence_payloads.py", "-v", "-x", "--durations=8", "--junitxml=EXTERNAL_PATH"]}
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 61 items

tests/discovery_runtime/test_evidence_payloads.py::test_working_bytes_cannot_replace_missing_pinned_source PASSED [  1%]
tests/discovery_runtime/test_evidence_payloads.py::test_uri_description_cannot_be_registered_as_locally_verified_evidence PASSED [  3%]
tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan PASSED [  4%]
tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[test] PASSED [  6%]
tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source] PASSED [  8%]
tests/discovery_runtime/test_evidence_payloads.py::test_planner_forwards_native_context_and_exact_grants_without_creation PASSED [  9%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[second-capture] PASSED [ 11%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[checksum] PASSED [ 13%]
tests/discovery_runtime/test_evidence_linking.py::test_wrapper_forwards_exact_context_grants_and_dry_run PASSED [ 14%]
tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[True] PASSED [ 16%]
tests/discovery_runtime/test_evidence_linking.py::test_shared_writer_commits_or_reports_explicit_partial_failure[False] PASSED [ 18%]
tests/discovery_runtime/test_evidence_linking.py::test_real_plan_validates_local_bytes_and_preserves_unknown_state PASSED [ 19%]
tests/discovery_runtime/test_evidence_payloads.py::test_unrelated_payload_cannot_be_added_to_an_evidence_operation PASSED [ 21%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root] PASSED [ 22%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[grant] PASSED [ 24%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[duplicate-payload] PASSED [ 26%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[digest] PASSED [ 27%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[collision] PASSED [ 29%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_detaches_caller_sequences PASSED [ 31%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes6] PASSED [ 32%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes5] PASSED [ 34%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes4] PASSED [ 36%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes3] PASSED [ 37%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes2] PASSED [ 39%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes1] PASSED [ 40%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes0] PASSED [ 42%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_requires_exact_immutable_bytes PASSED [ 44%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[evidence/../escape.txt] PASSED [ 45%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[EXTERNAL_PATH PASSED [ 47%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[/absolute.txt] PASSED [ 49%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[../escape.txt] PASSED [ 50%]
tests/discovery_runtime/test_evidence_payloads.py::test_custom_root_controls_record_and_supplied_payload_locations PASSED [ 52%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[missing] PASSED [ 54%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[imported] PASSED [ 55%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[duplicate] PASSED [ 57%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[test] PASSED [ 59%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[source] PASSED [ 60%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[runtime] PASSED [ 62%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[observation] PASSED [ 63%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[inventory] PASSED [ 65%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[documentation] PASSED [ 67%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[decision] PASSED [ 68%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path4] PASSED [ 70%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path3] PASSED [ 72%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path2] PASSED [ 73%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path1] PASSED [ 75%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path0] PASSED [ 77%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path1] PASSED [ 78%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path0] PASSED [ 80%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change3] PASSED [ 81%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change2] PASSED [ 83%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change1] PASSED [ 85%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change0] PASSED [ 86%]
tests/discovery_runtime/test_evidence_linking.py::test_invalid_captured_input_remains_an_explicit_prewrite_error PASSED [ 88%]
tests/discovery_runtime/test_evidence_linking.py::test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated[True] PASSED [ 90%]
tests/discovery_runtime/test_evidence_linking.py::test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated[False] PASSED [ 91%]
tests/discovery_runtime/test_evidence_linking.py::test_evidence_link_cannot_create_a_product_approval PASSED [ 93%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[id] PASSED [ 95%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[evidence_id] PASSED [ 96%]
tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[unspecified-behavior] PASSED [ 98%]
tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[product-decision] PASSED [100%]

- generated xml file: SCRATCH\issue-980-p3t5-reverse1-tests.xml -
============================= slowest 8 durations =============================
5.70s setup    tests/discovery_runtime/test_evidence_linking.py::test_wrapper_forwards_exact_context_grants_and_dry_run
3.46s call     tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[second-capture]
3.19s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[test]
3.18s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]
3.18s call     tests/discovery_runtime/test_evidence_payloads.py::test_working_bytes_cannot_replace_missing_pinned_source
3.15s call     tests/discovery_runtime/test_evidence_payloads.py::test_payload_integrity_uses_both_exact_declared_paths[checksum]
3.09s call     tests/discovery_runtime/test_evidence_payloads.py::test_uri_description_cannot_be_registered_as_locally_verified_evidence
3.07s setup    tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan
============================= 61 passed in 52.03s =============================
{"started_at_utc": "2026-10-18T17:19:55.491315+00:00", "ended_at_utc": "2026-10-18T17:20:47.676319+00:00", "elapsed_seconds": 52.18500189999759, "pytest_exit": 0, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392", "tests/discovery_runtime/test_evidence_payloads.py": "c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18", "tests/discovery_runtime/test_evidence_linking.py": "8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392", "tests/discovery_runtime/test_evidence_payloads.py": "c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14", "tests/discovery_runtime/evidence_test_support.py": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3"}, "source_stable": true, "reverse": true}
```
