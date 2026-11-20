# p3t5-focused-corrected9

Timestamp: 2026-10-18T17-03
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py -k not wrapper and not shared_writer and not actual_captured and not missing_pinned and not payload_integrity and not uri_description and not forwards_native and not injected_plan -x -v
EXIT_CODE: 0
Output Summary: tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[duplicate-payload] PASSED [ 97%]; tests/discovery_runtime/test_evidence_payloads.py::test_custom_root_controls_record_and_supplied_payload_locations PASSED [100%]; ; ===================== 47 passed, 11 deselected in 23.17s ======================

Working directory: .
Started: 2026-10-18T17:03:01.386030+00:00
Duration seconds: 24.228
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 58 items / 11 deselected / 47 selected

tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[source] PASSED [  2%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[test] PASSED [  4%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[runtime] PASSED [  6%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[observation] PASSED [  8%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[decision] PASSED [ 10%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[documentation] PASSED [ 12%]
tests/discovery_runtime/test_evidence_linking.py::test_registration_projects_exact_provenance_and_preserves_every_other_field[inventory] PASSED [ 14%]
tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[unspecified-behavior] PASSED [ 17%]
tests/discovery_runtime/test_evidence_linking.py::test_collection_member_update_preserves_siblings_and_approval[product-decision] PASSED [ 19%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path0] PASSED [ 21%]
tests/discovery_runtime/test_evidence_linking.py::test_nested_evidence_is_linked_without_promoting_observation[path1] PASSED [ 23%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path0] PASSED [ 25%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path1] PASSED [ 27%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path2] PASSED [ 29%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path3] PASSED [ 31%]
tests/discovery_runtime/test_evidence_linking.py::test_only_core_existing_evidence_arrays_are_eligible[path4] PASSED [ 34%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[missing] PASSED [ 36%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[duplicate] PASSED [ 38%]
tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[imported] PASSED [ 40%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[id] PASSED [ 42%]
tests/discovery_runtime/test_evidence_linking.py::test_duplicate_evidence_identity_is_rejected_before_proposing_writes[evidence_id] PASSED [ 44%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change0] PASSED [ 46%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change1] PASSED [ 48%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change2] PASSED [ 51%]
tests/discovery_runtime/test_evidence_linking.py::test_malformed_evidence_is_rejected_by_the_accepted_schema[change3] PASSED [ 53%]
tests/discovery_runtime/test_evidence_linking.py::test_invalid_captured_input_remains_an_explicit_prewrite_error PASSED [ 55%]
tests/discovery_runtime/test_evidence_linking.py::test_real_plan_validates_local_bytes_and_preserves_unknown_state PASSED [ 57%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[../escape.txt] PASSED [ 59%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[EXTERNAL_PATH PASSED [ 61%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[/absolute.txt] PASSED [ 63%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_paths_reject_escape_without_filesystem_access[evidence/../escape.txt] PASSED [ 65%]
tests/discovery_runtime/test_evidence_payloads.py::test_payload_requires_exact_immutable_bytes PASSED [ 68%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes0] PASSED [ 70%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes1] PASSED [ 72%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes2] PASSED [ 74%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes3] PASSED [ 76%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes4] PASSED [ 78%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes5] PASSED [ 80%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_contract_rejects_invalid_identity_digest_and_mutable_values[changes6] PASSED [ 82%]
tests/discovery_runtime/test_evidence_payloads.py::test_request_detaches_caller_sequences PASSED [ 85%]
tests/discovery_runtime/test_evidence_payloads.py::test_unrelated_payload_cannot_be_added_to_an_evidence_operation PASSED [ 87%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[grant] PASSED [ 89%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[digest] PASSED [ 91%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[collision] PASSED [ 93%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[outside-root] PASSED [ 95%]
tests/discovery_runtime/test_evidence_payloads.py::test_shared_planner_rejects_ungranted_stale_or_colliding_writes[duplicate-payload] PASSED [ 97%]
tests/discovery_runtime/test_evidence_payloads.py::test_custom_root_controls_record_and_supplied_payload_locations PASSED [100%]

===================== 47 passed, 11 deselected in 23.17s ======================
```
