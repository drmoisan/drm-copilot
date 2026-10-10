# Python Waivers Fail-Before Evidence (P2-T2, re-run under P2-T5, Issue #849)

Timestamp: 2026-10-10T14-26
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
ExpectedExitCode: 1
EXIT_CODE: 1
State: before the validator change (Phase 3 not started), after the P2-T5 rename of Python test 3 to `test_filed_before_orchestration_preparation_route_waives_without_record`.

## Summary line (verbatim)

```text
======================== 3 failed, 12 passed in 0.11s =========================
```

## Failed node IDs (verbatim)

```text
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_filed_before_orchestration_waives_bug_entry_tool_without_record
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_transferred_waives_feature_entry_tool_without_record
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_filed_before_orchestration_preparation_route_waives_without_record
```

These are exactly Python tests 1, 2, and 3 of "New Test Specifications" under their current names. Tests 4 through 7 and the eight pre-existing tests pass.

## Failure message for test 3 (verbatim)

```text
E       AssertionError: unexpected errors: ('Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.',)
```

Output Summary: EXIT_CODE 1 equals ExpectedExitCode 1. 3 failed, 12 passed. The failures are exactly tests 1-3 (record-optional origins without a record), each rejected by the rule-9 potential_record error before the fix.

## Ruff check after the rename (P2-T5)

Ruff command: poetry run ruff check tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
Ruff exit status: 0

```text
All checks passed!
```

The rename collapses the previously wrapped three-line `def` statement into the single line "def test_filed_before_orchestration_preparation_route_waives_without_record() -> None:"; it is the only change to the test file.
