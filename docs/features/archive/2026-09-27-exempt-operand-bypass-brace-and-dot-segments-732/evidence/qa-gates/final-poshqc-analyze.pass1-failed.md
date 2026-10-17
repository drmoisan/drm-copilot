# PoshQC Analyze (issue #732)

Timestamp: 2026-10-09T04-23
Task: [P7-T3]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p7-t3.sh (R-ANALYZE)
EXIT_CODE: 1
Pass: 1
MCP_CALL: error PSScriptAnalyzer reported 4 issue(s). (mcp__drm-copilot__run_poshqc_analyze, no scan_folders)

## Output

```text
ANALYZE_RESULT: failed PSScriptAnalyzer reported 4 issue(s).
ANALYZE_ISSUE_COUNT: 4
WRITE_SET_FINDING: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:97 PSUseShouldProcessForStateChangingFunctions
WRITE_SET_FINDING: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:97 PSUseShouldProcessForStateChangingFunctions
WRITE_SET_FINDING: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:97 PSUseShouldProcessForStateChangingFunctions
WRITE_SET_FINDING: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:97 PSUseShouldProcessForStateChangingFunctions
WRITE_SET_FILES_ANALYZED: 28
WRITE_SET_FINDING_COUNT: 4
```

