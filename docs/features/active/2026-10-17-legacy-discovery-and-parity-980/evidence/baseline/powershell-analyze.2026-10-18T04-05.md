# powershell-analyze

Timestamp: 2026-10-18T04-05
Command: sh SCRATCH/issue-980-powershell-baseline.sh analyze
EXIT_CODE: 0
Output Summary: Direct Invoke-ScriptAnalyzer measured 838 files using repository settings; 0 findings.

Working directory: .
Started: 2026-10-18T04:04:10.669052+00:00
Duration seconds: 77.310
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text
PowerShell=7.6.7

Name             Version
----             -------
Pester           5.9.0
Pester           5.6.1
PSScriptAnalyzer 1.25.0
PSScriptAnalyzer 1.24.0
PSScriptAnalyzer 1.22.0
Pester           3.4.0

{
  "files": 838,
  "finding_count": 0,
  "findings": []
}
```
