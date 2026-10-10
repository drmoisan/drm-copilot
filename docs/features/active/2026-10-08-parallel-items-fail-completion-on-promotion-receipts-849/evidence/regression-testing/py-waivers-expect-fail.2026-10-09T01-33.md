# Python Waivers Fail-Before Evidence (P2-T2, Issue #849)

Timestamp: 2026-10-10T10-19
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
ExpectedExitCode: 1
EXIT_CODE: 1
State: before the validator change (Phase 3 not started).

## Summary line (verbatim)

```text
======================== 3 failed, 12 passed in 0.11s =========================
```

## Failed node IDs (verbatim)

```text
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_filed_before_orchestration_waives_bug_entry_tool_without_record
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_transferred_waives_feature_entry_tool_without_record
FAILED tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_filed_before_orchestration_waives_bug_entry_tool_on_preparation_route_without_record
```

These are exactly Python tests 1, 2, and 3 of "New Test Specifications". Tests 4 through 7 and the eight pre-existing tests pass.

## Failure messages (verbatim, in order)

```text
E       AssertionError: unexpected errors: ('Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.',)
E       AssertionError: unexpected errors: ('Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_entry.',)
E       AssertionError: unexpected errors: ('Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.',)
```

Output Summary: EXIT_CODE 1 equals ExpectedExitCode 1. 3 failed, 12 passed. The failures are exactly tests 1-3 (record-optional origins without a record), each rejected by the rule-9 potential_record error before the fix.
