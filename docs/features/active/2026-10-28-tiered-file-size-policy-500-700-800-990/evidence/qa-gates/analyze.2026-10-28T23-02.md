# Analyze gate on the two touched PowerShell files

Timestamp: 2026-10-28T23-02
Command: Invoke-ScriptAnalyzer -Path <each file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information (direct run, PSScriptAnalyzer 1.25.0, PowerShell 7 from a sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary: FILES=2, FINDINGS=0 (the finding count printed by the direct run).
