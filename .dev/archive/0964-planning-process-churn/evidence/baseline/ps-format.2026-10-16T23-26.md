# Baseline — PowerShell Format

Timestamp: 2026-10-16T23-26
Task: [P0-T7]
Command: mcp__drm-copilot__run_poshqc_format (scan_folders: .claude/hooks, tests/scripts/claude-hooks); git status --porcelain
EXIT_CODE: 0
Output Summary:
- MCP result `ok: true` (the MCP summary string carries no counts; it is composed before the child runs).
- Tree observation: `git status --porcelain` after the run listed only this item's plan and evidence files, so the formatter rewrote no PowerShell file (no pre-existing format drift in the two folders).
