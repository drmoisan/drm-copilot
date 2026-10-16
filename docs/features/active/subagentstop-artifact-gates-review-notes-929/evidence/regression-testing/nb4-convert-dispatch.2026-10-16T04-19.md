# NB-4 Conversion: validate-discovery-artifact-gate.Dispatch.Tests.ps1 (P8-T9)

Timestamp: 2026-10-16T04-19

Conversion: the single line beginning `        $script:DispatchEnvelope = [ordered]@{` (line 28) was replaced with the two lines of Appendix C2 (helper dot-source and `ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:DispatchMessage`). `git diff --numstat`: 2 added, 1 deleted.

Command: sh SCRATCH/929/P8-T9-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1'; 'LINES=' + (Get-Content -LiteralPath $f).Count; 'HELPER=' + @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1').Count`
EXIT_CODE: 0
Output:
```
LINES=67
HELPER=1
```

Output Summary: `LINES=67` (66 plus one) and `HELPER=1`.
