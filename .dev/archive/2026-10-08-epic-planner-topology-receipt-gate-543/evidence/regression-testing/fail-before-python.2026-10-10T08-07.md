# Fail-Before: Python Regression Test (Issue #543)

Timestamp: 2026-10-10T08-07
Task: [P1-T3] [expect-fail]
Command: poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent" -vv
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Production code state: pre-fix (`scripts/dev_tools/validate_epic_planner_state.py` unchanged from merge base 7bbd0b9b990737642b4eeded01a27b7c5c8348b3).
- Result: `1 failed in 0.21s`; 0 passed for the node.
- Assertion-output line: `E       AssertionError: assert ['Epic planner topology_receipt must be an object.'] == []`
- Failure location: `tests\scripts\dev_tools\test_validate_epic_planner_state.py:265: AssertionError` (behavioural assertion failure; no import, collection, or fixture error).
- Paired pass-after artifact: produced by P2-T2 under `evidence/regression-testing/pass-after-python.<ts>.md`.
