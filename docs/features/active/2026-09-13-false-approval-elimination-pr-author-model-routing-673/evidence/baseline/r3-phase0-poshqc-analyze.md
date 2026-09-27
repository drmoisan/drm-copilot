# Phase 0 Analyzer Baseline (issue #673)

Timestamp: 2026-09-19T17-27

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-analyze.ps1` (route `a`), whose body is `$ErrorActionPreference = 'Stop'` / `$root = (Get-Location).Path` / `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` / `Invoke-PoshQCAnalyze -Root $root`.

EXIT_CODE: 0

Outcome recorded (exactly one of the two possible outcomes):

```
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
```

No `PSScriptAnalyzer reported <N> issue(s).` line was emitted and no findings table was printed, so there is no finding count to record and `N` is not applicable. The output does not contain `No PowerShell files found under`, so the analyzer did enumerate PowerShell files rather than silently scanning nothing.

Output Summary: The baseline tree carries zero PSScriptAnalyzer findings at Error, Warning, and Information severity, which is the severity set `Invoke-PoshQCAnalyze` runs. The single success line was emitted with the executing worktree root as its subject; that root is recorded here as `<WORKSPACE_ROOT>` under the host-data rule and its spelling is not written. This is the observation `[P11-T2]` must reproduce, so any finding there is attributable to this change set. The `PSUseDeclaredVarsMoreThanAssignments` risk `[P9-T7]` names — an assigned-and-never-read variable left behind by an edit — would surface here as an Information-severity finding and fail `[P11-T2]`, which is why that task deletes the unused assignment rather than leaving it.
