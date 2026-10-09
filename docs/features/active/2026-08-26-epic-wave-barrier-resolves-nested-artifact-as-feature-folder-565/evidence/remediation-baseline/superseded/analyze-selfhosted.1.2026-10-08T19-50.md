# Analyzer (self-hosted PSScriptAnalyzer), Final QC Iteration 1

Timestamp: 2026-10-08T19-50
Command: Import-Module PSScriptAnalyzer; $r = @(foreach ($f in @(<PS-PROD plus PS-TESTS, 20 paths>)) { Invoke-ScriptAnalyzer -Path $f -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1' -Severity Error, Warning, Information }); 'Findings=' + $r.Count; $r | ForEach-Object { 'FINDING ' + $_.ScriptName + ':' + $_.Line + ' ' + $_.RuleName }; exit ([int]($r.Count -gt 0))  (full body in <scratchpad>/c2-565-P10-T5.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T5.ps1
EXIT_CODE: 1
Output Summary: Findings=5 (FAIL for this iteration). Each finding is PSUseOutputTypeCorrectly on the `return @(Find-FeatureFolderCandidate -Text $Prompt)` line of a prompt-finder delegate: the array subexpression is inferred as System.Object[], while the function declares [OutputType([string[]])]. The two modes findings are the Claude and Codex copies, which share a file name. Remediation: cast the returned array to [string[]] in W02, W03, W04, W05, W06, re-run the mirror copy tasks, and restart the loop at P10-T1 (iteration 2).
Superseded: evidence/qa-gates/analyze-selfhosted.3.2026-10-08T18-57.md (Findings=0). Relocated from evidence/qa-gates/ by remediation cycle 1 (PA-3) so the PR context does not render this iteration-1 result as a failing gate.

```
Findings=5
FINDING enforce-epic-wave-barrier.ps1:133 PSUseOutputTypeCorrectly
FINDING enforce-parallel-cohort-barrier.ps1:191 PSUseOutputTypeCorrectly
FINDING enforce-parallel-drift-gate.ps1:236 PSUseOutputTypeCorrectly
FINDING enforce-orchestration-preimplementation-gate-modes.ps1:243 PSUseOutputTypeCorrectly
FINDING enforce-orchestration-preimplementation-gate-modes.ps1:243 PSUseOutputTypeCorrectly
```
