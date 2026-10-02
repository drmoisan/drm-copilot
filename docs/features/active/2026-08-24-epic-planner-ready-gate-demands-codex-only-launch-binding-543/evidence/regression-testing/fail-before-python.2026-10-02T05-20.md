# Fail-before: Python regression test (issue #543)

Timestamp: 2026-10-02T05-20
Task: P1-T2 [expect-fail]
Command: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_skips_launch_binding_for_feature_without_launch_paths" -vv`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Result line: `1 failed in 0.18s` (0 passed) for the node, on pre-fix production code.
- The failure is the behavioural assertion `assert offending == []` (no import or fixture error).
- Single-line assertion output (contains both tokens `features[0] launch binding` and `must identify a launch artifact`):
  `AssertionError: assert ['Epic planner checkpoint features[0] launch binding.branch_name must be a non-empty unique string.', 'Epic planner checkpoint features[0] launch binding.worktree_path must be a non-empty canonical absolute path.', 'Epic planner checkpoint features[0] launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.', 'Epic planner checkpoint features[0] launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.', 'Epic planner checkpoint features[0] launch binding.delegation_receipt must be an object.', 'Epic planner checkpoint features[0] launch receipt path must identify a launch artifact in this repository.', 'Epic planner checkpoint features[0] launch status path must identify a launch artifact in this repository.'] == []`
- Both error families are present: five `launch binding` errors (call site 1, `validate_epic_planner_child_launch_bindings`) and two `must identify a launch artifact` errors (call site 2, `validate_epic_planner_launch_evidence` through readiness integrity).
- Note: canonical folder `evidence/regression-testing/` is used in place of the spec's `evidence/regression/` (EVIDENCE_LOCATION_OVERRIDE_REJECTED recorded in the plan header).
