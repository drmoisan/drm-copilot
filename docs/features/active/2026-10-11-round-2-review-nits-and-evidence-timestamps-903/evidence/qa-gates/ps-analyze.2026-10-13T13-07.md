# PowerShell Analyzer (P12-T13)

Timestamp: 2026-10-13T13-07
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", ".claude/lib/blast-radius", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414
Loop-Iteration: 1

EXIT_CODE is the MCP call disposition only (`"ok":true`). The result carries no analyzer output, so no finding count is asserted. CI (P12-T22 and P12-T23) governs analyzer results.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 8 selected scan folder(s)."}
```

Output Summary: Call disposition ok:true over the eight P0-T27 scan folders, matching the P0-T28 baseline disposition.
