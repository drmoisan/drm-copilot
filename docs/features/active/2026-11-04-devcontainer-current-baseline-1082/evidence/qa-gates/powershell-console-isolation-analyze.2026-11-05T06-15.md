Timestamp: 2026-11-05T06-15
Started: 2026-11-05T06:15:38.1975713Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-current-powershell.sh analyze
EXIT_CODE: 1
Output Summary:

```text
Analyzing extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
Analyzing extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1
Retrying transient analyzer NullReferenceException (1/3)
Retrying transient analyzer NullReferenceException (2/3)
Invoke-ScriptAnalyzer: SCRATCH\issue-1082-current-powershell.ps1:12:112
Line |
  12 |  … mpt++){try {Invoke-ScriptAnalyzer -Path (Resolve-Path $_).Path -Setti …
     |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Object reference not set to an instance of an object.
```

Raw output: SCRATCH/issue-1082-powershell-console-isolation-analyze.log
