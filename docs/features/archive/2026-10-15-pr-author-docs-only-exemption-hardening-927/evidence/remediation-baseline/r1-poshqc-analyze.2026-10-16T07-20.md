# R1 Baseline PoshQC Analyze (Issue #927)

Timestamp: 2026-10-16T07-20
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<WORKSPACE_ROOT> scan_folders=[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
EXIT_CODE: 0
MCP_CALL: returned
Output Summary: The PoshQC MCP analyze call returned (ok=true). The MCP result carries no finding count, so no count is claimed here; the CI Analyze PowerShell step is the finding source ([P8-T2]). The PowerShell porcelain status after the call was empty.

Command 2: git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'
EXIT_CODE_2: 0
STATUS_AFTER: (empty)
