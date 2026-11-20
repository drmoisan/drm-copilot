# PowerShell Static-Analysis Baseline — [P0-T7]

Timestamp: 2026-08-28T12-46

Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952`

EXIT_CODE: 0

## Returned Result Payload

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952'."}
```

| Field | Value |
| --- | --- |
| `ok` | `true` |
| `tool` | `run_poshqc_analyze` |
| `summary` (verbatim) | `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.` |

The non-writing analyze tool is used for this baseline rather than the formatter, so the baseline is
not taken after a repair. No file was rewritten by this invocation.

Output Summary: The tool returned `ok: true`, so `EXIT_CODE: 0` is recorded. Its verbatim `summary`
string is `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.`
No numeric diagnostic count and no severity breakdown is asserted from this tool, because its result
payload carries an `ok` flag, a tool name, a workspace root, and a fixed summary string only. It
returns no exit code, no diagnostic count, no severity breakdown, no test counts, and no coverage
value.
