# Baseline PowerShell Format (P0-T8)

Timestamp: 2026-10-16T10-25
Command: git status --porcelain -- .claude/hooks .codex/hooks .claude/lib/ci-gate scripts/dev-tools tests/scripts/workflows tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-lib/ci-gate tests/scripts/dev-tools (before); mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE_ROOT scan_folders=[.claude/hooks, .codex/hooks, .claude/lib/ci-gate, scripts/dev-tools, tests/scripts/workflows, tests/scripts/claude-hooks, tests/scripts/codex-hooks, tests/scripts/claude-lib/ci-gate, tests/scripts/dev-tools]; the same git status --porcelain command (after)
EXIT_CODE: 0
Disposition: RETURNED
Output Summary: before-output empty; format call returned; after-output empty; PRE-EXISTING-FORMAT-DRIFT=NONE

Before-output: (empty, EXIT_CODE 0)
After-output: (empty, EXIT_CODE 0)
MCP summary string (verbatim): Ran bundled PoshQC format against 'WORKTREE_ROOT' with 9 selected scan folder(s).
