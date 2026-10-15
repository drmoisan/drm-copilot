# P0-T6 Repro: enum site, dict value

Timestamp: 2026-10-09T20-02
Command: poetry run python -c "from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_merge_status_enum([{'folder':'a','merge_status':{'x': 1}}]))"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The enum site raises TypeError: unhashable type: 'dict' at the membership test.

```
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_merge_status_enum([{'folder':'a','merge_status':{'x': 1}}]))
                                                                               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<WORKSPACE_ROOT>\scripts\dev_tools\validate_epic_orchestrator_state.py", line 238, in _validate_merge_status_enum
    if merge_status is not None and merge_status not in VALID_MERGE_STATUS:
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TypeError: unhashable type: 'dict'
```
