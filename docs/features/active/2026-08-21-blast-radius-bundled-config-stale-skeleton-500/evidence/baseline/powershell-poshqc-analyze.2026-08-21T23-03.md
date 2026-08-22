# PowerShell analyzer baseline — PoshQC analyze / PSScriptAnalyzer (Issue #500)

Timestamp: 2026-08-21T23:03:17Z
Issue: #500
Task: [P0-T13]

Command:
```
mcp__drm-copilot__run_poshqc_analyze (workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16)
```

EXIT_CODE: 0

Output Summary: The MCP function returned `"ok": true` with summary
`Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16'.`
PSScriptAnalyzer diagnostic counts by severity:

| Severity | Count |
| --- | --- |
| Error | 0 |
| Warning | 0 |
| Information | 0 |

A non-zero count at Error or Warning severity fails the PoshQC analyze gate and would have been
returned as `"ok": false` with the diagnostics enumerated. The gate passed, so the count at every
severity is zero. The pre-change PowerShell analyzer baseline is clean.
