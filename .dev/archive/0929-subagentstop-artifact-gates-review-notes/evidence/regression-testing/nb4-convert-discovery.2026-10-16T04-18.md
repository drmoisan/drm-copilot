# NB-4 Conversion: validate-discovery-artifact-gate.Tests.ps1 (P8-T8)

Timestamp: 2026-10-16T04-18

Conversion: the nine-line local `New-SubagentStopEnvelopeJson` block at lines 180-188 (Context `script entrypoint (stdin envelope, issue #905)` `BeforeAll`, `agent_type = 'general-purpose'`) was replaced with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation; the 8 call lines were renamed to `ConvertTo-SubagentStopEnvelopeJson` without `-AgentType` (the helper default is `general-purpose`). No other line changed (`git diff --numstat`: 9 added, 17 deleted).

Command: sh SCRATCH/929/P8-T8-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1'; 'NEW=' + @(Select-String -Path $f -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count; $h = @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'CONVERT=' + @(Select-String -Path $f -SimpleMatch -Pattern 'ConvertTo-SubagentStopEnvelopeJson').Count; 'DISCOVERY_BUILDER=' + @(Select-String -Path $f -SimpleMatch -Pattern 'ConvertTo-DiscoveryEnvelopeJson').Count`
EXIT_CODE: 0
Output:
```
NEW=0
HELPER=1 JOINPATH=1
CONVERT=8
DISCOVERY_BUILDER=11
```

Output Summary: `NEW=0`, `HELPER=1 JOINPATH=1`, `CONVERT=8` (P7-T5 count 9 minus the removed definition line), `DISCOVERY_BUILDER=11` (no line containing `ConvertTo-DiscoveryEnvelopeJson` was edited).
