# Python Waivers Pass-After Evidence (P5-T2, Issue #849)

Timestamp: 2026-10-10T14-30
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
EXIT_CODE: 0
State: after the Phase 3 validator change.

## Summary line (verbatim)

```text
============================= 15 passed in 0.08s ==============================
```

Python tests 1-3 of "New Test Specifications" (`test_filed_before_orchestration_waives_bug_entry_tool_without_record`, `test_transferred_waives_feature_entry_tool_without_record`, `test_filed_before_orchestration_preparation_route_waives_without_record`), which failed in P2-T2/P2-T5, now pass. Tests 4-7 (epic_decomposition without record, filed_before_orchestration with null record, transferred with invalid record, invalid origin without record) and the eight pre-existing tests continue to pass.

Output Summary: EXIT_CODE 0. 15 passed, 0 failed (AC-1, and the Python legs of AC-4 and AC-5).
