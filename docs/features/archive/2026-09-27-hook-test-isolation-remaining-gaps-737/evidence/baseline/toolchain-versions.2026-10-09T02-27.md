# P0-T6 Toolchain versions

Timestamp: 2026-10-09T02-27
Command: Route C (scratchpad .ps1 run through pwsh -NoProfile -File): Get-Module -ListAvailable Pester, PSScriptAnalyzer | Sort-Object Name, Version -Descending | Select-Object Name, Version; $PSVersionTable.PSVersion
EXIT_CODE: 0
Output Summary:
PSScriptAnalyzer 1.25.0
PSScriptAnalyzer 1.24.0
PSScriptAnalyzer 1.22.0
Pester 5.6.1
Pester 3.4.0
PSVERSION: 7.6.6
Highest Pester version: 5.6.1 (5.x). PowerShell: 7.6.6 (7.x).
Route note: the PowerShell tool is not available to this agent; CR routes use Route C (the plan's third route) for every command.
