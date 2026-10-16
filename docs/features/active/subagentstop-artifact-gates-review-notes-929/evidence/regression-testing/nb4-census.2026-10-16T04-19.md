# NB-4 Builder Census (P8-T11)

Timestamp: 2026-10-16T04-19

Command: sh SCRATCH/929/P8-T11-1.sh
Script: `foreach ($p in @('New-SubagentStopEnvelopeJson','Builds and returns envelope JSON text only')) { $m = @(Get-ChildItem -Path tests -Recurse -Include *.ps1 | Select-String -SimpleMatch -Pattern $p); 'CENSUS_TOTAL | ' + $p + ' | ' + $m.Count; $m | Group-Object Path | ForEach-Object { 'CENSUS_PATH | ' + (Resolve-Path -Relative -LiteralPath $_.Name) + ' | ' + $_.Count } }`
EXIT_CODE: 0
Output:
```
CENSUS_TOTAL | New-SubagentStopEnvelopeJson | 0
CENSUS_TOTAL | Builds and returns envelope JSON text only | 0
```

Output Summary: Both `CENSUS_TOTAL` lines read `0` and no `CENSUS_PATH |` line is printed. No `.ps1` file under `tests/` (tracked or untracked) still defines or calls `New-SubagentStopEnvelopeJson` or carries the per-suite justification text.
