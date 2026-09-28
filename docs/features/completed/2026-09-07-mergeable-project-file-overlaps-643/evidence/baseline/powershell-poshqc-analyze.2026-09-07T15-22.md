# Baseline — PowerShell analyzer (issue #643, task [P0-T13])

- Timestamp: 2026-09-07T15:22Z
- Command: MCP function `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`
- EXIT_CODE: 0

## MCP payload (verbatim fields)

- `ok`: `true`
- `tool`: `run_poshqc_analyze`
- `workspace_root`: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`
- `summary`: `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09'.`

## Output Summary

The analyzer reports `ok` as `true`, and the summary string begins `Ran bundled PoshQC analyze
against`. No diagnostic count is asserted: the MCP payload carries only `ok`, `tool`,
`workspace_root`, and `summary`, so no count exists to read.
