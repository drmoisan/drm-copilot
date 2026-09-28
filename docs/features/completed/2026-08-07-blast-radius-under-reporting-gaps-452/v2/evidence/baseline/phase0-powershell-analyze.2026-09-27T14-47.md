# Phase 0 Baseline — PowerShell Analyze (P0-T26)

Timestamp: 2026-09-27T14-47

Command: MCP mcp__drm-copilot__run_poshqc_analyze, workspace_root `<worktree root>`, scan_folders ["tests/scripts/claude-lib/blast-radius"]
EXIT_CODE: 0
Output: {"ok":true,"tool":"run_poshqc_analyze","summary":"Ran bundled PoshQC analyze against '<worktree root>' with 1 selected scan folder(s)."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius
EXIT_CODE: 0
Output:

```
PSSA_FINDINGS=0
```

Output Summary: The MCP call returned (disposition EXIT_CODE 0). The direct PSScriptAnalyzer count with the repository settings reports PSSA_FINDINGS=0 and no FINDING lines. Baseline finding set for the folder: empty.
