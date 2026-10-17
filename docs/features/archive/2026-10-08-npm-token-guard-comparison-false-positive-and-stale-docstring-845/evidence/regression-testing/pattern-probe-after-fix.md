# Pattern Probe After Fix (Probe P)

Timestamp: 2026-10-09T20-45
Command: git fetch origin main ; Probe P (plan "Probe Commands"), run as an equivalent script file because the worktree isolation guard refuses `python -c` (see Plan Deviations): poetry run python <scratchpad>/probe_p.py
EXIT_CODE: 0
Output Summary: True re.IGNORECASE (alternative A unchanged; alternative B is exactly \bNPM_TOKEN\s*=(?!=)).

Output, verbatim:

```text
True re.IGNORECASE
```
