# NB-4 Conversion: validate-prd-feature-output.Tests.ps1 (P8-T2)

Timestamp: 2026-10-16T04-14

Conversion: the nine-line local `New-SubagentStopEnvelopeJson` block at lines 32-40 (file-level `BeforeAll`, `agent_type = 'prd-feature'`) was replaced with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation; the 7 call lines were renamed to `ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature'`. No other line changed (`git diff --stat`: 8 insertions, 16 deletions).

Command: sh SCRATCH/929/P8-T2-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1'; 'NEW=' + @(Select-String -Path $f -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count; $h = @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'CONVERT=' + @(Select-String -Path $f -SimpleMatch -Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature'").Count`
EXIT_CODE: 0
Output:
```
NEW=0
HELPER=1 JOINPATH=1
CONVERT=7
```

Output Summary: `NEW=0`, `HELPER=1 JOINPATH=1`, `CONVERT=7` (P7-T5 count 8 minus the removed definition line).
