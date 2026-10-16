# R1 Baseline Test (P0-T9)

Timestamp: 2026-10-16T05-11
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"])
EXIT_CODE: 0
Output Summary:
- Call disposition: returned without error (`ok: true`); the runtime raises when the Pester child exits non-zero, so the baseline is green.
- This run rewrites `artifacts/pester/powershell-coverage.xml` with a three-folder population. That is why P0-T6 read the file before this call, and why Phase 5 runs last.
- No count, percentage or row result is read from the MCP result string (MCP observation rule).
