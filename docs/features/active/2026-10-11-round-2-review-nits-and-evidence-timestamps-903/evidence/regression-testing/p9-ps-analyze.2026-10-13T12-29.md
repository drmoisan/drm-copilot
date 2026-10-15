# P9-T8 PowerShell analyze (call disposition)

Timestamp: 2026-10-13T12-29
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks"]
EXIT_CODE: 0
Output Summary:
- Verbatim result: `{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 3 selected scan folder(s)."}`
- Recorded as call disposition only (`"ok":true` maps to EXIT_CODE 0). No finding count is read from this result; analyzer results are authoritative in CI.
