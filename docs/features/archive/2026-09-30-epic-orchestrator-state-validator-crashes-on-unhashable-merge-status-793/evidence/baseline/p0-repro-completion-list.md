# P0-T7 Repro: completion site, list value

Timestamp: 2026-10-09T20-02
Command: poetry run python -c "from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_completion([{'feature_folder':'a','merge_status':['x']}], {}))"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The completion site raises TypeError: unhashable type: 'list' at the membership test.

```
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_completion([{'feature_folder':'a','merge_status':['x']}], {}))
                                                                               ~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<WORKSPACE_ROOT>\scripts\dev_tools\validate_epic_orchestrator_state.py", line 321, in _validate_completion
    if feature.get("merge_status") not in MERGED_STATUSES:
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TypeError: unhashable type: 'list'
```
