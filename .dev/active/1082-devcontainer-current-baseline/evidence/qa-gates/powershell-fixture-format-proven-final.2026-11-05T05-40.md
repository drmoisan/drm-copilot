Timestamp: 2026-11-05T05-40
Started: 2026-11-05T05:40:04.1222997Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-current-powershell.sh format
EXIT_CODE: 1
Output Summary:

```text
warning: in the working copy of 'tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1', CRLF will be replaced by LF the next time Git touches it
Invoke-Formatter: SCRATCH\issue-1082-current-powershell.ps1:7:63
Line |
   7 |  … $_ -Raw; $f=Invoke-Formatter -ScriptDefinition $s -Settings scripts/p …
     |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Cannot determine line endings as the text probably contain mixed line endings. (Parameter 'text')
```

Raw output: SCRATCH/issue-1082-powershell-fixture-format-proven-final.log
