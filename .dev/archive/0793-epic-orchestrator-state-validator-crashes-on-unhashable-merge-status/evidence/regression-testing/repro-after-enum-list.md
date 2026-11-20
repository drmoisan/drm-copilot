# P2-T4 Repro after fix: enum site, list value

Timestamp: 2026-10-09T20-18
Command: poetry run python -c "from scripts.dev_tools import validate_epic_orchestrator_state as v; print(v._validate_merge_status_enum([{'folder':'a','merge_status':['x']}]))"
EXIT_CODE: 0
Output Summary: No traceback. The enum site returns one error containing has invalid merge_status. The folder prints as <unknown> because the repro uses the key folder while the validator reads feature_folder.

```
["Epic checkpoint feature '<unknown>' has invalid merge_status: ['x']"]
```
