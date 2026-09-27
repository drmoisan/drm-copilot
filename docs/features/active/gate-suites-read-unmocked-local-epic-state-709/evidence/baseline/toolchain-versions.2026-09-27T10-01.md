# P0-T5 Toolchain Versions

Timestamp: 2026-09-27T10-01
Command: Route C (scratchpad p0t5.ps1 run by `pwsh -NoProfile -File` via `sh`): Get-Module -ListAvailable Pester, PSScriptAnalyzer | Sort-Object Name, Version -Descending | Select-Object Name, Version; $PSVersionTable.PSVersion; exit 0
EXIT_CODE: 0
Output Summary:
- Pester: 5.6.1 (highest), 3.4.0 (inbox, not used)
- PSScriptAnalyzer: 1.25.0 (highest), 1.24.0, 1.24.0, 1.22.0
- PowerShell: 7.6.6
- Result: highest Pester is 5.x and PowerShell is 7.x.
