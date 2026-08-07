# Baseline — PowerShell Analyzer (PoshQC / PSScriptAnalyzer)

Timestamp: 2026-08-07T14-17

Task: [P0-T7]
Feature: 2026-08-07-parallel-blast-radius-447 (issue #447)
Branch: feature/parallel-blast-radius-447
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf`

Command: `mcp__drm-copilot__run_poshqc_analyze` invoked with `workspace_root` only (no `scan_folders`; repository analyzer settings resolve internally).

EXIT_CODE: 0

Output Summary: Clean baseline. The analyzer reported `ok: true` with no diagnostic payload, indicating 0 findings at every severity (0 Error, 0 Warning, 0 Information). The MCP surface returns a structured success object rather than a per-rule finding list; a non-zero finding count would surface as `ok: false` with diagnostics. No PSScriptAnalyzer debt exists prior to Phase 4.

## Finding Counts

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| Total | 0 |

## Raw Tool Result

```json
{
  "ok": true,
  "tool": "run_poshqc_analyze",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a2857bcb4458f15cf",
  "summary": "Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a2857bcb4458f15cf'."
}
```
