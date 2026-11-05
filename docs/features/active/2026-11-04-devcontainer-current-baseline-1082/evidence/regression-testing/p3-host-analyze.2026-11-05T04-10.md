Timestamp: 2026-11-05T04-10
Started: 2026-11-05T04:10:53.6526155Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp\codex-container-baseline\issue-1082\issue-1082-current-powershell.sh analyze
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
