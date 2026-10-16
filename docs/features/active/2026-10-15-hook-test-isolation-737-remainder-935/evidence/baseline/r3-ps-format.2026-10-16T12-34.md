# R3 Baseline Format (P0-T6)

Timestamp: 2026-10-16T12-34
Command: git status --porcelain -- tests/scripts; mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root; scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); git status --porcelain -- tests/scripts
EXIT_CODE: 0
Output Summary:
- Call disposition: returned (EXIT_CODE 0 = call disposition success; the MCP result carries no per-file output).
- Before porcelain (`git status --porcelain -- tests/scripts`): empty
- After porcelain (`git status --porcelain -- tests/scripts`): empty
- Result: the formatter changed nothing. No PRE-EXISTING-FORMAT-DRIFT.
