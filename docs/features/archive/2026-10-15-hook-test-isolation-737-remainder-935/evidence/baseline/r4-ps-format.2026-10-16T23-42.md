# R4 Baseline PowerShell Format (P0-T5, issue #935)

Timestamp: 2026-10-16T23-42
Command: git status --porcelain -- tests/scripts; mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); git status --porcelain -- tests/scripts
EXIT_CODE: 0

Output Summary:
- Porcelain before the call: empty (exit 0).
- MCP call disposition: returned (`ok: true`; summary "Ran bundled PoshQC format ... with 3 selected scan folder(s).").
- Porcelain after the call: empty (exit 0). The formatter changed nothing; no PRE-EXISTING-FORMAT-DRIFT.
