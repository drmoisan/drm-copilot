# Python Edit Sites Before Change (P0-T4)

Timestamp: 2026-09-30T14-15
Command: git grep -n -F "VALID_BLOCKED_REASONS" -- scripts/dev_tools/validate_orchestrator_state.py
EXIT_CODE: 0
Output Summary: Exactly two match lines; set literal at line 87, membership check at line 348 (post-#464 layout).

```
scripts/dev_tools/validate_orchestrator_state.py:87:VALID_BLOCKED_REASONS = {
scripts/dev_tools/validate_orchestrator_state.py:348:    if blocked_reason is not None and blocked_reason not in VALID_BLOCKED_REASONS:
```

- `VALID_BLOCKED_REASONS = {` : line 87
- `blocked_reason not in VALID_BLOCKED_REASONS` : line 348
