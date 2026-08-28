# PowerShell Test and Coverage Baseline (MCP tool) — [P0-T8]

Timestamp: 2026-08-28T12-46

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952`, using the repository Pester run settings

EXIT_CODE: 0

## Returned Result Payload

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952'."}
```

| Field | Value |
| --- | --- |
| `ok` | `true` |
| `tool` | `run_poshqc_test` |
| `summary` (verbatim) | `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.` |

Because `ok` is `true`, the `ExpectedExitCode:` clause of this task's acceptance — which applies only
when `ok` is `false` — does not apply and no `ExpectedExitCode:` field is written.

Output Summary: The tool returned `ok: true` and the verbatim `summary` string
`Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.`
No passed, failed, or skipped count and no coverage percentage is asserted from this tool, because
its result payload carries none of them: it returns an `ok` flag, a tool name, a workspace root, and
a fixed summary string only. Those observable values are captured separately by [P0-T11] from the
self-hosted PoshQC invocation and from the Pester coverage XML.
