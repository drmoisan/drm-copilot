# Parse and Size: RW03 after ED-7

Timestamp: 2026-10-08T20-26
Command: (a) foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1')) { $t = $null; $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $p).Path, [ref]$t, [ref]$e); 'PARSE ' + $p + ' Errors=' + $e.Count }; (b) foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T5-a.ps1; sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T5-b.ps1
EXIT_CODE: 0
Output Summary: Errors=0 and LINES 468 (466 + 2, the contract value). Supporting check: git diff --numstat against the remediation base reports 5 added and 3 removed lines; the six original lines were replaced by the eight ED-7 lines, three of which (the if/else/closing-brace lines) are textually unchanged, so git records them as context.

```
PARSE .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 Errors=0
LINES 468 .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
5	3	.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
```
