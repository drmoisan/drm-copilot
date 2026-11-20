# PSScriptAnalyzer

Timestamp: 2026-10-29T13-11
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information (direct run from a sh-launched PowerShell 7 script under SCRATCH) over the five changed production files and the five changed test files
EXIT_CODE: 0
Output Summary: PSSA_TOTAL_FINDINGS=0 over 10 files, no analyzer retry needed. Count read from the direct analyzer run, not from the MCP result.
