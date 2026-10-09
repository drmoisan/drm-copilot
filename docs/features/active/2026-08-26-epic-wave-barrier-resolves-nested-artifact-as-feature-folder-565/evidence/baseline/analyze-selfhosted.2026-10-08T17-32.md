# Baseline Analyzer (self-hosted PSScriptAnalyzer)

Timestamp: 2026-10-08T17-32
Command: Import-Module PSScriptAnalyzer; $r = @(foreach ($f in @(<PS-EXISTING plus W29, W30, W31>)) { Invoke-ScriptAnalyzer -Path $f -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1' -Severity Error, Warning, Information }); 'Findings=' + $r.Count; $r | ForEach-Object { 'FINDING ' + $_.ScriptName + ':' + $_.Line + ' ' + $_.RuleName }; exit ([int]($r.Count -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T16.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Findings=0 (no FINDING lines).
