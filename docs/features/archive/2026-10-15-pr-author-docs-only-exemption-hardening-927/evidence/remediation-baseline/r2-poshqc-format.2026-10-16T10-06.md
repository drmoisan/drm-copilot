# R2 Baseline PoshQC Format (Issue #927)

Timestamp: 2026-10-16T10-06
Command: git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'
EXIT_CODE: 0
Output Summary: Porcelain status for PowerShell files was empty before and after the PoshQC MCP format call over SCAN_QC; the formatter rewrote no PowerShell file. MCP_CALL: returned.

## Commands

- Command 1 (before): `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`
  - EXIT_CODE_1: 0
  - Output: (empty)
- Command 2: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `<WORKSPACE_ROOT>` and `scan_folders` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (SCAN_QC)
  - EXIT_CODE_2: 0
  - MCP_CALL: returned
- Command 3 (after): `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`
  - EXIT_CODE_3: 0
  - Output: (empty)
