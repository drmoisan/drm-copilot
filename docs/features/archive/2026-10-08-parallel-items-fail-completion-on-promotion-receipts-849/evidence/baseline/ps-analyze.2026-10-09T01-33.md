# Baseline PowerShell Analyzer (Issue #849)

Timestamp: 2026-10-10T09-58
Task: P0-T17
Command: MCP tool mcp__drm-copilot__run_poshqc_analyze with workspace_root = worktree root (no scan_folders)
EXIT_CODE: 0
MCP-Status: success (result field `ok: true`)

## MCP result (worktree path replaced by "worktree root")

```text
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"worktree root","summary":"Ran bundled PoshQC analyze against 'worktree root'."}
```

The MCP result carries a status and a one-sentence summary only. No finding count is asserted from it; per-file analyzer counts are taken at handoff H0 from `analyzer-output.txt` (Source A) or the `AnalyzeStep:` line (Source B).

H0-Trigger-Completed: 2026-10-10T13:58:21Z

Command for the completion time: `date -u +%Y-%m-%dT%H:%M:%SZ`, run immediately after the MCP analyzer returned.

Output Summary: PoshQC analyze MCP status success (EXIT_CODE 0); no count asserted. H0-Trigger-Completed = 2026-10-10T13:58:21Z. Executor returns HANDOFF: POWERSHELL SOURCE A (H0).
