# Phase 0 Lint Baseline — Issue #670

Timestamp: 2026-09-17T07-53
Task: [P0-T6]
Command: @(Invoke-ScriptAnalyzer -Path 'PATH' -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Count  (PATH = each of the two hooks below) ; mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree, scan_folders = .claude/hooks, .codex/hooks)
EXIT_CODE: 0

| Path | Diagnostic count | Is zero |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 0 | yes, `0` |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 0 | yes, `0` |

MCP route result (verbatim): `{"ok":true,"tool":"run_poshqc_analyze", ... "summary":"Ran bundled PoshQC analyze against '<worktree>' with 2 selected scan folder(s)."}`. Per execution amendment EA-4 the MCP summary is composed before the child process runs and carries no diagnostic count; the authoritative counts are the two direct `Invoke-ScriptAnalyzer` integers above.

Output Summary:
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 0 diagnostics (explicitly zero).
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 0 diagnostics (explicitly zero).
- These are the comparison values for [P8-T2]. MCP analyze returned `ok: true` with no count.
