# Moved Names References (Issue #464)

Timestamp: 2026-09-30T08-47
Command: git grep -n --untracked -E "EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT|PREFLIGHT_CLEARED_STATUS|REMEDIATION_CYCLES_KEY" -- "*.py"
EXIT_CODE: 0
Output Summary:
Six match lines, all in `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (lines 35, 36, 41, 57, 64, 88); no match in `scripts/dev_tools/validate_orchestrator_state.py` or any other file. The six occurrences equal the six the validator held before the move.

```
scripts/dev_tools/_orchestrator_state_remediation_loop.py:35:REMEDIATION_CYCLES_KEY = "cycles"
scripts/dev_tools/_orchestrator_state_remediation_loop.py:36:EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = {
scripts/dev_tools/_orchestrator_state_remediation_loop.py:41:PREFLIGHT_CLEARED_STATUS = "clear"
scripts/dev_tools/_orchestrator_state_remediation_loop.py:57:    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:
scripts/dev_tools/_orchestrator_state_remediation_loop.py:64:        if preflight_status != PREFLIGHT_CLEARED_STATUS:
scripts/dev_tools/_orchestrator_state_remediation_loop.py:88:    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
```
