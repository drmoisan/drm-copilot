# Fail-Before: Python Regression (P1-T2) [expect-fail]

Timestamp: 2026-10-16T00-41
Command: poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result: 1 failed in 0.25s (0 passed) for test_ready_gate_skips_feature_receipts_when_keys_absent, on pre-fix production code.
- Failure reason: AssertionError on the behavioural assertion (no import, collection, or fixture error).
- Assertion received list (verbatim from pytest):
  - 'Epic planner checkpoint features[0].model_routing_receipt must be an object.'
  - 'Epic planner checkpoint features[0].topology_receipt must be an object.'
  - 'Epic planner checkpoint features[1].model_routing_receipt must be an object.'
  - 'Epic planner checkpoint features[1].topology_receipt must be an object.'
  - 'Execution-ready planner validation requires repository context.'
- Expected: ['Execution-ready planner validation requires repository context.']
- Diff lines quoted:
  - `At index 0 diff: 'Epic planner checkpoint features[0].model_routing_receipt must be an object.' != 'Execution-ready planner validation requires repository context.'`
  - `Left contains 4 more items, first extra item: 'Epic planner checkpoint features[0].topology_receipt must be an object.'`
