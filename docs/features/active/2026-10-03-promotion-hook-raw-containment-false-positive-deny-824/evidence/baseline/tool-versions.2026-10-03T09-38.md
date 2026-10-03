# P0-T8 PowerShell tool versions

Timestamp: 2026-10-03T09-38
Command: pwsh -NoProfile -Command 'Get-Module -ListAvailable -Name Pester, PSScriptAnalyzer | Sort-Object Name, Version -Descending | ForEach-Object { "$($_.Name) $($_.Version)" }; $PSVersionTable.PSVersion.ToString()'; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- PSScriptAnalyzer 1.25.0, 1.24.0, 1.24.0, 1.22.0
- Pester 5.6.1, 3.4.0 (5.6.1 >= 5.0.0)
- PowerShell 7.6.6
- Result: PASS
