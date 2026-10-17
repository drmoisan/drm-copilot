# R2 Baseline PoshQC Analyze (Issue #927)

Timestamp: 2026-10-16T10-07
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root <WORKSPACE_ROOT>; scan_folders SCAN_QC)
EXIT_CODE: 0
Output Summary: MCP_CALL: returned. The MCP result carries no finding detail (rule R2-3). Porcelain status for PowerShell files was empty after the call. Analyzer finding counts are read from the CI Analyze PowerShell step at [P5-T2].

## Commands

- Command 1: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = `<WORKSPACE_ROOT>` and `scan_folders` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (SCAN_QC)
  - MCP_CALL: returned
- Command 2: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`
  - EXIT_CODE_2: 0
  - Output: (empty)
