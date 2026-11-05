Timestamp: 2026-11-05T05-29
Started: 2026-11-05T05:29:40.9524214Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-current-powershell.sh analyze
EXIT_CODE: 1
Output Summary:

```text
Analyzing extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
Analyzing extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1
Invoke-ScriptAnalyzer: SCRATCH\issue-1082-current-powershell.ps1:12:65
Line |
  12 |  … lyzing $_"; Invoke-ScriptAnalyzer -Path (Resolve-Path $_).Path -Setti …
     |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Object reference not set to an instance of an object.
```

Raw output: SCRATCH/issue-1082-powershell-captured-analyze.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
