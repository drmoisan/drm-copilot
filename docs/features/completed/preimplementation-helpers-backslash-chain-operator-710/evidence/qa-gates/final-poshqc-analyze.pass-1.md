# Final QC: PowerShell Analyze (Issue #710)

Timestamp: 2026-09-27T02-19
Command: sh <SCRATCHPAD>/r-analyze.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-analyze.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: Pass 1. PSScriptAnalyzer reported no findings.

Pass: 1

## Output

```text
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
```
