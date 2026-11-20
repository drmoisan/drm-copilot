# PowerShell MCP Test Route Compliance (P8-T4)

Timestamp: 2026-09-29T18-44
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = repository root, scan_folders = tests/scripts/claude-lib/parallel-drift)
EXIT_CODE: 0
Output Summary:
The call returned without raising. Summary string, quoted:
`{"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree>","summary":"Ran bundled PoshQC test against '<worktree>' with 1 selected scan folder(s)."}`

No count, coverage, or pass value is read from this call: the MCP tool reads the installed
extension's runsettings. P8-T5 overwrites its XML outputs with the self-hosted run.
