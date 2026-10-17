# R4 Baseline Repository-Scope PowerShell Test with Coverage (P0-T8, issue #935; COV-2 control)

Timestamp: 2026-10-17T00-12
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders omitted: repo-scope run); D-COV-FRESH (post); D-COV-ROOT
EXIT_CODE: 0
MCP-DISPOSITION: returned

Output Summary:
- D-COV-FRESH pre: `stat -c %y artifacts/pester/powershell-coverage.xml` = `2026-10-16 19:55:45.632752100 -0400`; report stamp `report name="Pester (10/16/2026 23:55:19)"` (line 3).
- D-COV-FRESH post: `stat -c %y` = `2026-10-16 20:10:33.508914700 -0400`; report stamp `report name="Pester (10/17/2026 00:10:07)"` (line 3). Both values changed: the run rewrote the file.
- D-COV-ROOT (local repo-scope population; not comparable with CI): counter count `1`; `covered=16532 missed=1905 total=18437 pct=89.67 floor85=MET`.
