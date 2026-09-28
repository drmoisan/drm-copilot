Timestamp: 2026-09-26T23-39

Command:
```
$Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
$Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
Import-Module PSScriptAnalyzer -ErrorAction Stop
$Original = Get-Content -Raw -Path $Target
$Formatted = Invoke-Formatter -ScriptDefinition $Original -Settings $Settings
if ($Formatted -eq $Original) { 'FORMAT_CHECK: no changes needed for ' + $Target } else { 'FORMAT_CHECK: formatting drift detected for ' + $Target }
```

EXIT_CODE: 0

Output Summary: FORMAT_CHECK: no changes needed for tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
