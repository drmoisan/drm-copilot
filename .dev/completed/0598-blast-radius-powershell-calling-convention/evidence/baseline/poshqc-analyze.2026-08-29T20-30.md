# PoshQC analyzer baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T6]

Command:
1. `mcp__drm-copilot__run_poshqc_analyze` against the workspace root
   `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path"`

Every recorded literal and exit code below comes from command 2. Command 1 returned
`{"ok":true,"tool":"run_poshqc_analyze", ...}` and carries no finding output and no exit code, so it
is not the observation source.

EXIT_CODE: 0

AnalyzerClean: true

Output Summary: command 2's output contains the line beginning
`PSScriptAnalyzer passed: no findings under`. Because that line is present, the analyzer reported no
findings and no `PSScriptAnalyzer reported` throw message was emitted; there is no finding table to
record.

Verbatim output of command 2:

```
Transient ScriptAnalyzer engine error (NullReferenceException) on C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7\extensions\drm-copilot\resources\powershell\PoshQC\PoshQC.psm1; retrying (1/5). PSScriptAnalyzer=1.25.0 PS=7.6.5
Transient ScriptAnalyzer engine error (NullReferenceException) on C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7\extensions\drm-copilot\resources\powershell\PoshQC\PoshQC.psm1; retrying (2/5). PSScriptAnalyzer=1.25.0 PS=7.6.5
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7
```

## Note on the two retry lines

`Invoke-PoshQCAnalyze` retried a PSScriptAnalyzer engine `NullReferenceException` twice on
`extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` and then succeeded within its
five-attempt budget. The retry is the analyzer wrapper's own transient-error handling; the run
completed with the clean-pass line and exit code 0. The file involved is outside this feature's
change surface and no finding was reported against it.
