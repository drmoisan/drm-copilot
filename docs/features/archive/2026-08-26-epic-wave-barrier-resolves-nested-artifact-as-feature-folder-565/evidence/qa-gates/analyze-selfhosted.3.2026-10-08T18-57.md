# Analyzer (self-hosted PSScriptAnalyzer), Final QC Iteration 3

Timestamp: 2026-10-08T18-57
Command: Import-Module PSScriptAnalyzer; $r = @(foreach ($f in @(<PS-PROD plus PS-TESTS, 20 paths>)) { Invoke-ScriptAnalyzer -Path $f -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1' -Severity Error, Warning, Information }); 'Findings=' + $r.Count; $r | ForEach-Object { 'FINDING ' + $_.ScriptName + ':' + $_.Line + ' ' + $_.RuleName }; exit ([int]($r.Count -gt 0))  (full body in <scratchpad>/c2-565-P10-T5.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T5.ps1
EXIT_CODE: 0
Output Summary: Findings=0 over all 20 paths.

```
Findings=0
```
