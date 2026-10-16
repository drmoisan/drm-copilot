# R1 Repo-Scope Coverage Run (P5-T2)

Timestamp: 2026-10-16T06-56
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; `scan_folders` omitted, so the tool resolves the scan set from `config/poshqc-scan.json` `test.scanFolders`: `scripts`, `tests/powershell`, `tests/scripts`, as the CI job `poshqc / PowerShell QC` does)
EXIT_CODE: 0
Output Summary:
- Call disposition: returned without error (`ok: true`); the result summary names no selected scan folders, consistent with the omitted `scan_folders` argument.
- Run at HEAD `c40ee18db` with no uncommitted change under `tests/scripts`.
- No count, percentage or row result is read from the MCP result string (MCP observation rule). Coverage values are read from `artifacts/pester/powershell-coverage.xml` by P5-T3.
