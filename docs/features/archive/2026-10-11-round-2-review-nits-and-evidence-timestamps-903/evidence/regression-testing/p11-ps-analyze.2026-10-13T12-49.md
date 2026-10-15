# P11-T15 PowerShell analyze (call disposition)

Timestamp: 2026-10-13T12-49
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
Output Summary:
- Verbatim result: `{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 5 selected scan folder(s)."}`
- Recorded as call disposition only (`"ok":true` maps to EXIT_CODE 0). No finding count is read from this result; analyzer results are authoritative in CI.
