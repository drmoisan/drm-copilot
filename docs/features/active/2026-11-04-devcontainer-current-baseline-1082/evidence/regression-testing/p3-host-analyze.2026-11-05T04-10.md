Timestamp: 2026-11-05T04-10
Started: 2026-11-05T04:10:53.6526155Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-current-powershell.sh analyze
EXIT_CODE: 1
Output Summary:

```text
Invoke-ScriptAnalyzer: SCRATCH\issue-1082-current-powershell.ps1:11:37
Line |
  11 |  … ach-Object {Invoke-ScriptAnalyzer -Path $_ -Settings scripts/powershe …
     |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Object reference not set to an instance of an object.
```

Raw output: SCRATCH/issue-1082-p3-host-analyze.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
