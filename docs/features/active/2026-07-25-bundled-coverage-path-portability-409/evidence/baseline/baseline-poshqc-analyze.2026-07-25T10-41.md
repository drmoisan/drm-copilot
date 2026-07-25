# Baseline — PowerShell Lint / PSScriptAnalyzer (issue #409)

Timestamp: 2026-07-25T10-41

Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52`

EXIT_CODE: 0

Output Summary:
- Tool returned `{"ok":true,"tool":"run_poshqc_analyze", ...}` with summary `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52'.`
- Diagnostic count: 0. The PoshQC analyze wrapper returns `ok: true` only when PSScriptAnalyzer reports no findings at or above the configured severity; any diagnostic would surface as a non-ok result with the analyzer output attached.
- Baseline lint state: clean, zero errors.
