# NB-4 Conversion: validate-task-researcher-output.Coverage.Tests.ps1 (P8-T5)

Timestamp: 2026-10-16T04-17

Conversion: the nine-line local `New-SubagentStopEnvelopeJson` block at lines 24-32 (first Describe `BeforeAll`, `agent_type = 'task-researcher'`) was replaced with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` at the same indentation; the 10 call lines were renamed to `ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher'`. No other line changed (`git diff --numstat`: 11 added, 19 deleted). Every changed hunk is at original line 206 or earlier (`git diff -U0 HEAD` hunk headers `-24,9`, `-60`, `-73`, `-86`, `-102`, `-133`, `-143`, `-155`, `-167`, `-194`, `-206`), so the Appendix D Describe `Invoke-TaskResearcherOutputValidation dependency decision in process (issue #929)` at the end of the file is unchanged.

Command: sh SCRATCH/929/P8-T5-1.sh
Script: `$f = 'tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1'; 'NEW=' + @(Select-String -Path $f -SimpleMatch -Pattern 'New-SubagentStopEnvelopeJson').Count; $h = @(Select-String -Path $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'CONVERT=' + @(Select-String -Path $f -SimpleMatch -Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher'").Count`
EXIT_CODE: 0
Output:
```
NEW=0
HELPER=1 JOINPATH=1
CONVERT=10
```

Output Summary: `NEW=0`, `HELPER=1 JOINPATH=1`, `CONVERT=10` (P7-T5 count 11 minus the removed definition line); the Appendix D Describe is unchanged.
