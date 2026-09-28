Timestamp: 2026-09-26T23-39

Command:
```
$Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
$Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
Import-Module PSScriptAnalyzer -ErrorAction Stop
$Findings = Invoke-ScriptAnalyzer -Path $Target -Settings $Settings -Severity Error, Warning, Information
if ($Findings.Count -gt 0) { $Findings | Format-Table -AutoSize; 'ANALYZE_CHECK: ' + $Findings.Count + ' finding(s) for ' + $Target } else { 'ANALYZE_CHECK: no findings for ' + $Target }
```

EXIT_CODE: 0

Output Summary: ANALYZE_CHECK: no findings for tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 (0 findings)
