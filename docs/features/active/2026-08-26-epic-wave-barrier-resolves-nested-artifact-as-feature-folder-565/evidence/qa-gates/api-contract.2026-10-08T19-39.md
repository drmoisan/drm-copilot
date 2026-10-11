# Shared Resolver Public API Contract

Timestamp: 2026-10-08T19-39
Command: . ./.claude/hooks/feature-folder-resolution.ps1; $common = [System.Management.Automation.PSCmdlet]::CommonParameters; foreach ($n in @('Find-FeatureFolderCandidate', 'ConvertTo-FeatureFolderBasename', 'Find-FeatureFolderRecord', 'Select-FeatureFolderTarget', 'Resolve-FeatureFolderWorkMode', 'Get-FeatureFolderPlanPrerequisite')) { 'FUNCTION ' + $n + ' PARAMS ' + ((@((Get-Command -Name $n -CommandType Function).Parameters.Keys) | Where-Object { $_ -notin $common } | Sort-Object) -join ',') }
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P8-T12.ps1
EXIT_CODE: 0
Output Summary: Exactly the six expected lines; every function name and parameter set matches the spec.md Functions table.

```
FUNCTION Find-FeatureFolderCandidate PARAMS Text
FUNCTION ConvertTo-FeatureFolderBasename PARAMS Value
FUNCTION Find-FeatureFolderRecord PARAMS Records,Reference
FUNCTION Select-FeatureFolderTarget PARAMS Candidate,DeclaredIssueNumber,DependencyAware,FallbackIssueNumber,Records
FUNCTION Resolve-FeatureFolderWorkMode PARAMS IssueContent,UnresolvedMode
FUNCTION Get-FeatureFolderPlanPrerequisite PARAMS WorkMode
```
