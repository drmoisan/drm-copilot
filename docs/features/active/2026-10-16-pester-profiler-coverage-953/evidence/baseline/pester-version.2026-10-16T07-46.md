# Local Pester Versions (issue #953, P0-T17)

Timestamp: 2026-10-16T07-46
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; pwsh -NoProfile -Command "Get-Module Pester -ListAvailable | Sort-Object Version -Descending | Select-Object Name, Version | Format-Table -AutoSize | Out-String -Width 220"; exit $LASTEXITCODE' (script SCRATCH/issue-953-p0-t17.sh, run with sh)
EXIT_CODE: 0
Output Summary: Installed Pester versions: 5.6.1, 3.4.0. Highest installed is 5.6.1, which is at or above 5.4.0 and below 6.0.0, so the local baseline and final FULL_RUN use the same major version.

PESTER_HIGHEST: 5.6.1
PESTER_HIGHEST_BELOW_6: 5.6.1

```text
Name   Version
----   -------
Pester 5.6.1
Pester 3.4.0
```
