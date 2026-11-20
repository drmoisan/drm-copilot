# PoshQC Analyze (issue #732)

Timestamp: 2026-10-09T04-33
Task: [P7-T3]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p7-t3.sh (R-ANALYZE)
EXIT_CODE: 0
Pass: 3
MCP_CALL: returned (mcp__drm-copilot__run_poshqc_analyze, no scan_folders)

## Output

```text
Transient ScriptAnalyzer engine error (NullReferenceException) on <WORKSPACE_ROOT>\extensions\drm-copilot\resources\powershell\PoshQC\PoshQC.psm1; retrying (1/5). PSScriptAnalyzer=1.25.0 PS=7.6.6
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
ANALYZE_RESULT: passed
ANALYZE_ISSUE_COUNT: 0
WRITE_SET_FILES_ANALYZED: 29
WRITE_SET_FINDING_COUNT: 0
```

PASS_HISTORY: pass 1 failed (ANALYZE_ISSUE_COUNT 4, WRITE_SET_FINDING_COUNT 4: PSUseShouldProcessForStateChangingFunctions on New-OrchestrationTargetResult in the four targets copies; preserved as final-poshqc-analyze.pass1-failed.md); fixed by renaming the internal builder to Get-OrchestrationTargetResult in the canonical targets file and re-running R-MIRROR. Pass 2 passed (0 and 0 over 28 files). Pass 3 adds the C1bCoverage suite (29 files).

Output Summary: PASS (pass 3). ANALYZE_RESULT: passed; ANALYZE_ISSUE_COUNT: 0 (B_ANALYZE_COUNT 0); WRITE_SET_FINDING_COUNT: 0 over 29 write-set .ps1 files.
