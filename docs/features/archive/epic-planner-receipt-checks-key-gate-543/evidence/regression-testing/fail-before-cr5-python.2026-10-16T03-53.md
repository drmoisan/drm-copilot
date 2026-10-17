# Fail-Before CR-5 Python Validator (P1-T2) [expect-fail]

Timestamp: 2026-10-16T03-53
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py -vv (output redirected to SCRATCH/rc1/py-fail-before.txt)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result: 7 failed, 1 passed in 0.17s (pre-fix production code at 259c93f7a)
- FAILED test_ready_gate_prefix_uses_original_index_after_non_object_entry[string]
- FAILED test_ready_gate_prefix_uses_original_index_after_non_object_entry[null]
- FAILED test_ready_gate_prefix_uses_original_index_after_non_object_entry[number]
- FAILED test_ready_gate_prefix_uses_original_index_after_non_object_entry[list]
- FAILED test_ready_gate_receipt_prefix_uses_original_index_under_codex_flag
- FAILED test_dependency_wave_prefixes_use_original_index_after_non_object_entry
- FAILED test_launch_binding_prefix_uses_original_index_under_codex_flag
- PASSED test_ready_gate_prefix_unchanged_without_non_object_entries (preservation)
- Assertion-diff lines (compacted indices):
  E         At index 1 diff: "Epic planner checkpoint features[1].preparation_status must be 'prepared'." != "Epic planner checkpoint features[2].preparation_status must be 'prepared'."
  E         At index 1 diff: "Epic planner checkpoint features[1].feature_folder must be unique: 'docs/features/active/feature-101'." != "Epic planner checkpoint features[2].feature_folder must be unique: 'docs/features/active/feature-101'."
- The Codex-flag receipt and launch-binding failures list features[1].model_routing_receipt / features[1] launch binding.branch_name (compacted) where features[2] is expected.
- Every failure is an AssertionError; no import, collection, or fixture error.
