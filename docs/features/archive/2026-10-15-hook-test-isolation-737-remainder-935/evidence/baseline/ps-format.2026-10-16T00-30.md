# Baseline PowerShell Format (P0-T6)

Timestamp: 2026-10-16T00-30
Command: git status --porcelain -- tests/scripts; mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); git status --porcelain -- tests/scripts
EXIT_CODE: 0

Output Summary:
- EXIT_CODE records call disposition: the MCP call returned (`ok: true`).
- Porcelain before the call: EMPTY
- Porcelain after the call: EMPTY
- No PRE-EXISTING-FORMAT-DRIFT; no restore was needed. Final `git status --porcelain -- tests/scripts`: EMPTY.
