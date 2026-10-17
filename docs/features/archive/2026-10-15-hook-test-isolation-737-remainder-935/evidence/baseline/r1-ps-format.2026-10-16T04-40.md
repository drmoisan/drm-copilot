# R1 Baseline Format (P0-T7)

Timestamp: 2026-10-16T04-40
Command: git status --porcelain -- tests/scripts; mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); git status --porcelain -- tests/scripts
EXIT_CODE: 0
Output Summary:
- Call disposition: returned without error (EXIT_CODE 0 records call disposition only, per the MCP observation rule).
- `git status --porcelain -- tests/scripts` before: empty
- `git status --porcelain -- tests/scripts` after: empty
- Result: the formatter changed nothing; no `PRE-EXISTING-FORMAT-DRIFT`.
