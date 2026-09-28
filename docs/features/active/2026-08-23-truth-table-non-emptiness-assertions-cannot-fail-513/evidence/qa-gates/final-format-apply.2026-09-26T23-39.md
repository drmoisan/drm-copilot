Timestamp: 2026-09-26T23-39

Command:
```
$Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
$Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
Import-Module PSScriptAnalyzer -ErrorAction Stop
$Original = Get-Content -Raw -Path $Target
$Formatted = Invoke-Formatter -ScriptDefinition $Original -Settings $Settings
if ($Formatted -ne $Original) { Set-Content -Path $Target -Value $Formatted -Encoding UTF8 -NoNewline; 'FORMAT_APPLY: rewrote ' + $Target } else { 'FORMAT_APPLY: no changes needed for ' + $Target }
```

EXIT_CODE: 0

Output Summary: FORMAT_APPLY: no changes needed for tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1. The loop is clean on the first pass; no restart from P6-T1 is required.
