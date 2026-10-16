# NB-4 Conversion: validate-task-researcher-output.Tests.ps1 (P8-T4)

Timestamp: 2026-10-16T04-16

Conversion: the nine-line local `New-SubagentStopEnvelopeJson` block at lines 41-49 (file-level `BeforeAll`, `agent_type = 'task-researcher'`) was replaced with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation; the 12 call lines were renamed to `ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher'`. No other line changed (`git diff --numstat`: 13 added, 21 deleted).

Command: sh SCRATCH/929/P8-T4-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1'; 'NEW=' + @(Select-String -Path $f -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count; $h = @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'CONVERT=' + @(Select-String -Path $f -SimpleMatch -Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher'").Count`
EXIT_CODE: 0
Output:
```
NEW=0
HELPER=1 JOINPATH=1
CONVERT=12
```

Output Summary: `NEW=0`, `HELPER=1 JOINPATH=1`, `CONVERT=12` (P7-T5 count 13 minus the removed definition line).
