# Baseline — PowerShell Analyze

Timestamp: 2026-10-16T23-26
Task: [P0-T7]
Command: mcp__drm-copilot__run_poshqc_analyze (scan_folders: .claude/hooks, tests/scripts/claude-hooks); then a direct run through a `sh` launcher under SCRATCH: Invoke-ScriptAnalyzer -Path <folder> -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information for each of .claude/hooks and tests/scripts/claude-hooks
EXIT_CODE: 0
Output Summary:
- MCP result `ok: true` (no counts carried by the MCP result).
- Direct run: `FINDINGS=0` across both folders. This count is taken from the direct run only.
