# R4 Baseline Three-Folder PowerShell Test with Coverage (P0-T7, issue #935)

Timestamp: 2026-10-16T23-57
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); D-COV-FRESH (post); D-COV-ROOT
EXIT_CODE: 0

Output Summary:
- MCP call disposition: returned (`ok: true`).
- D-COV-FRESH pre: `stat -c %y artifacts/pester/powershell-coverage.xml` = `2026-10-16 16:47:54.958086200 -0400`; report stamp `report name="Pester (10/16/2026 20:47:22)"` (line 3).
- D-COV-FRESH post: `stat -c %y` = `2026-10-16 19:55:45.632752100 -0400`; report stamp `report name="Pester (10/16/2026 23:55:19)"` (line 3). Both values changed: the run rewrote the file.
- D-COV-ROOT (local three-folder population; not comparable with CI): counter count `1`; `covered=11910 missed=6527 total=18437 pct=64.60 floor85=NOT-MET`.
- The `floor85` value is recorded only; the 85% floor is evaluated on the repository-scope run (P0-T8, P5-T5), not on this scoped population.
