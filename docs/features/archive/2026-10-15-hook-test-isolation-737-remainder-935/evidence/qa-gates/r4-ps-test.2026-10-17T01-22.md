# R4 Final QA Loop Pass 1 — Three-Folder Test with Coverage (P5-T3, issue #935)

Timestamp: 2026-10-17T01-22
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); D-COV-FRESH (post); D-COV-ROOT
EXIT_CODE: 0

Output Summary:
- MCP call disposition: returned (`ok: true`).
- D-COV-FRESH pre: `stat -c %y artifacts/pester/powershell-coverage.xml` = `2026-10-16 21:09:12.215545600 -0400`; report stamp `report name="Pester (10/17/2026 01:08:51)"` (line 3).
- D-COV-FRESH post: `stat -c %y` = `2026-10-16 21:20:57.551050100 -0400`; report stamp `report name="Pester (10/17/2026 01:20:34)"` (line 3). Both values changed.
- D-COV-ROOT (local three-folder population; not comparable with CI): counter count `1`; `covered=11910 missed=6527 total=18437 pct=64.60 floor85=NOT-MET`. Equal to the P0-T7 baseline of the same population (11910/18437). The floor is evaluated on the repo-scope run (P5-T5), not on this scoped population.
