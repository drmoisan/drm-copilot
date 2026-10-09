# QC Pass 1: Analyze ([P10-T3])

Timestamp: 2026-10-08T22-48

Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = <WORKSPACE_ROOT>; scan_folders = .claude/hooks, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks)
MCP_CALL: returned
(MCP result `ok: true`; no count or finding is read from the result, rule 4)

Command: sh <SCRATCHPAD>/s-pssa.sh
EXIT_CODE: 0
Output Summary:
PSSA_FINDING_COUNT: 0
(Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, severities Error, Warning, Information, over every existing write-set `.ps1` file; no PSSA finding lines were printed.)
