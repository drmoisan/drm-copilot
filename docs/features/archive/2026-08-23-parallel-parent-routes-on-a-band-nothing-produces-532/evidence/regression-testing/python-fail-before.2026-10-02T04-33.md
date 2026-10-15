# Python Fail-Before Regression Run (P1-T6) [expect-fail]

Timestamp: 2026-10-02T04-33
Command: poetry run pytest "tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_item_without_band_assessment_or_receipt" -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed in 0.09s
FAILED tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_item_without_band_assessment_or_receipt
Assertion output (the validator returned no errors for the item):
>       assert BAND_ABSENT in errors, errors
E       AssertionError: []
E       assert 'Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.' in []
tests\scripts\dev_tools\test_validate_parallel_planner_state_routing.py:56 AssertionError
- git diff --stat 74e1d674 -- scripts/dev_tools/validate_parallel_planner_state.py exited 0
(no output: the validator is unmodified)
PLAN DEVIATION DEV-1 - the plan's diff anchor b7b4a2dc is replaced by the merge-base 74e1d674 (see evidence/baseline/git-baseline.2026-10-02T04-29.md). The orchestrator verified that main did not change the validator between b7b4a2dc and 74e1d674.
