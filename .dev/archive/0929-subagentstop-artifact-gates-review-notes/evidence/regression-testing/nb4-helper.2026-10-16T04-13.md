# NB-4 Shared Helper (P8-T1)

Timestamp: 2026-10-16T04-13

Command: sh SCRATCH/929/P8-T1-1.sh
Script: `$f = 'tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1'; 'SUPPRESS=' + @(Select-String -Path $f -SimpleMatch -Pattern 'SuppressMessageAttribute').Count; 'DEFINES=' + @(Select-String -Path $f -SimpleMatch -Pattern 'function ConvertTo-SubagentStopEnvelopeJson').Count; 'LINES=' + (Get-Content -LiteralPath $f).Count`
EXIT_CODE: 0
Output:
```
SUPPRESS=0
DEFINES=1
LINES=35
```

Output Summary: `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` was created with the content of Appendix F. `SUPPRESS=0` (no analyzer suppression), `DEFINES=1` (one `ConvertTo-SubagentStopEnvelopeJson` definition), `LINES=35` (AC-07).
