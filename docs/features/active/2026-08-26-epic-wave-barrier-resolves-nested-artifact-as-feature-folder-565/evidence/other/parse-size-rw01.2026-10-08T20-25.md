# Parse and Size: RW01 after ED-1..ED-6

Timestamp: 2026-10-08T20-25
Command: (a) foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1')) { $t = $null; $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $p).Path, [ref]$t, [ref]$e); 'PARSE ' + $p + ' Errors=' + $e.Count }; (b) foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T3-a.ps1; sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T3-b.ps1
EXIT_CODE: 0
Output Summary: Errors=0 and LINES 496 (489 + 7, the contract value). Supporting check: git diff --numstat da2dc7d59a4ba9c4a12d8a25534d3f88177ae60a -- RW01 reports 13 added and 6 removed lines, which equals ED-1 (+3/-1), ED-2 (+1/-1), ED-3 (+1), ED-4 (+2), ED-5 (+4/-2), ED-6 (+2/-2).

```
PARSE .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Errors=0
LINES 496 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
13	6	.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
```
