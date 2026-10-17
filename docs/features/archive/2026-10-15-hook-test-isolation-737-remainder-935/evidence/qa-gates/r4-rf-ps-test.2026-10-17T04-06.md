# R4 Phase 6 three-folder test with coverage (P6-T22, loop pass 1)

Timestamp: 2026-10-17T04-06
Command: D-COV-FRESH (stat -c %y artifacts/pester/powershell-coverage.xml; grep -n -F -e 'report name="Pester (' artifacts/pester/powershell-coverage.xml); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); D-COV-FRESH; D-COV-ROOT (grep -c -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml and the D-COV-ROOT awk line)
EXIT_CODE: 0
Output Summary:
- MCP disposition: returned (ok true)
- D-COV-FRESH last-write time: pre 2026-10-16 23:52:55.069031100 -0400; post 2026-10-17 00:05:02.445728500 -0400 (changed)
- D-COV-FRESH report stamp: pre `3:<report name="Pester (10/17/2026 03:52:31)">`; post `3:<report name="Pester (10/17/2026 04:04:38)">` (changed)
- local three-folder population, packaged MCP runner; not comparable with CI:
  - D-COV-ROOT counter count: 1
  - D-COV-ROOT: covered=12002 missed=6988 total=18990 pct=63.20 floor85=NOT-MET (three-folder population over the repository coverage roots; not a gate here, P6-T24 evaluates the repo-scope population)
