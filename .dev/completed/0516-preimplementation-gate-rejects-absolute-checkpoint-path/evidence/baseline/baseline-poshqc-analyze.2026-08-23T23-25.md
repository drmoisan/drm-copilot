# Baseline — PoshQC Analyze / PSScriptAnalyzer (issue #516)

Timestamp: 2026-08-24T15-11
Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and no `scan_folders` argument (full configured scan set)
EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e'."}
```

## PSScriptAnalyzer Finding Count

**0 findings.**

Basis for the count, stated explicitly so the claim is auditable: the MCP tool result is the only reporting channel for this stage. `mcp__drm-copilot__run_poshqc_analyze` returns `ok: true` only when the analyzer stage completes with no reported diagnostic; a non-empty finding set surfaces as `ok: false` with the diagnostics enumerated in the result payload. The returned payload carries `ok: true` and no diagnostic list, so the reported finding count is zero. A search of `artifacts/` immediately after the run confirmed the analyze stage writes no separate report file in this configuration — the only file under `artifacts/` modified in the last ten minutes is `artifacts/orchestration/orchestrator-state.json`, which is the orchestration checkpoint and not an analyzer output.

Output Summary: Baseline PoshQC analyze completed successfully over the full configured scan set with `ok: true`, EXIT_CODE 0, and a PSScriptAnalyzer finding count of 0. The repository has no pre-existing PSScriptAnalyzer debt at this baseline, so the final analyze gate in [P4-T2] must also report zero findings for the pass to be clean.
