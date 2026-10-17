# P0-T18 Baseline PoshQC Format (tree observation)

Timestamp: 2026-10-09T22-58
Command: git status --porcelain -- .claude/hooks tests/scripts/claude-hooks; mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root, scan_folders [".claude/hooks", "tests/scripts/claude-hooks"]); git status --porcelain -- .claude/hooks tests/scripts/claude-hooks
EXIT_CODE: 0
Output Summary:
- OPS-1: the plan's `sh artifacts/orchestration/wip824-run/poshqc-format.sh` was replaced by the PoshQC MCP format tool, per operator substitution 4. MCP results carry no tool output, so the tree observation replaces the "Formatted:" / "Already formatted:" line check; no "Already formatted:" count is available.
- Status before: EXIT 0; empty
- Raw MCP result: {"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree root>","summary":"Ran bundled PoshQC format against '<worktree root>' with 2 selected scan folder(s)."} (absolute host path replaced by <worktree root>)
- Status after: EXIT 0; empty
- Both listings empty and identical: no file was rewritten (no pre-existing format drift; no hard-excluded hook rewritten)
- Result: PASS
