# PowerShell Analyze (P12-T13)

Timestamp: 2026-10-13T13-50
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", ".claude/lib/blast-radius", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2

EXIT_CODE is the MCP call disposition only. No finding count is asserted from it; CI (P12-T22 and P12-T23) governs analyzer results.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 8 selected scan folder(s)."}
```

Output Summary: PASS. Call disposition `"ok":true`, matching the P0-T28 disposition.
