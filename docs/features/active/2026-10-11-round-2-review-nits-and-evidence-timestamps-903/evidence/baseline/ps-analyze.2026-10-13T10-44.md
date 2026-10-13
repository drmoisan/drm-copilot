# PowerShell Analyzer Baseline (P0-T28)

Timestamp: 2026-10-13T10-44
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", ".claude/lib/blast-radius", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
BASE: 320cb5ddf

EXIT_CODE is the MCP call disposition only (`"ok":true`). The result carries no analyzer output, so no finding count is asserted.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 8 selected scan folder(s)."}
```

Output Summary: Call disposition ok:true for the analyzer over the eight P0-T27 scan folders. Analyzer findings are governed by CI (Phase 1 and P12-T22/P12-T23).
