# PSScriptAnalyzer Baseline

Timestamp: 2026-10-28T21-15
Command: Invoke-ScriptAnalyzer -Path <each .ps1/.psm1 under .claude/hooks, .claude/lib, .codex/hooks, scripts/ci, tests/scripts> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information (PSScriptAnalyzer 1.25.0, PowerShell 7.6, sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Files analyzed: 597
- Findings: 0 (Error: 0, Warning: 0, Information: 0; no rule groups)
