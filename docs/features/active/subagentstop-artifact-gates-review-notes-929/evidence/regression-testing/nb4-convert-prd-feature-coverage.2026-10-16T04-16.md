# NB-4 Conversion: validate-prd-feature-output.Coverage.Tests.ps1 (P8-T3)

Timestamp: 2026-10-16T04-16

Conversion: the nine-line local `New-SubagentStopEnvelopeJson` block at lines 24-32 (`agent_type = 'prd-feature'`) was replaced with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation; the 10 call lines were renamed to `ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature'`. No other line changed (`git diff --numstat`: 11 added, 19 deleted).

Command: sh SCRATCH/929/P8-T3-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1'; 'NEW=' + @(Select-String -Path $f -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count; $h = @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'CONVERT=' + @(Select-String -Path $f -SimpleMatch -Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature'").Count`
EXIT_CODE: 0
Output:
```
NEW=0
HELPER=1 JOINPATH=1
CONVERT=10
```

Output Summary: `NEW=0`, `HELPER=1 JOINPATH=1`, `CONVERT=10` (P7-T5 count 11 minus the removed definition line).
