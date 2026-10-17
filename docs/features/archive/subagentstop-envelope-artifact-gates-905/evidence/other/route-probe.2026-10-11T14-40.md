# R-ROUTE probe (issue #905)

Timestamp: 2026-10-11T14-40
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/route-probe.ps1
EXIT_CODE: 0
Output Summary: Option (a) (PowerShell tool) is not available in this execution session (no PowerShell tool is exposed to the executor), so it printed nothing. Option (b) printed ROUTE-PROBE-OK and PowerShell major version 7.

- `<SCRATCHPAD>/route.sh` content: `pwsh -NoProfile -File "$@"` (exit code propagates as the last command's status)
- Option (a): not available in this session (no PowerShell tool); no output.
- Option (b) output:
  - `ROUTE-PROBE-OK`
  - `7`
  - `<WORKSPACE_ROOT>`

ROUTE: b
PS-MAJOR: 7
