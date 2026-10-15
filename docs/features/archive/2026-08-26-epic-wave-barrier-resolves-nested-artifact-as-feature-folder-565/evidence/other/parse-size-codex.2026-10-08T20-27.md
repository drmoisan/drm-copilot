# Parse and Size: Codex Files (RW02, RW04) after ED-1..ED-7

Timestamp: 2026-10-08T20-27
Command: (a) foreach ($p in @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')) { $t = $null; $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $p).Path, [ref]$t, [ref]$e); 'PARSE ' + $p + ' Errors=' + $e.Count }; (b) foreach ($p in @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T9-a.ps1; sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T9-b.ps1
EXIT_CODE: 0
Output Summary: Two Errors=0 lines; LINES 493 for RW02 (486 + 7) and LINES 489 for RW04 (487 + 2), both equal to the contract values. RW02 numstat against the remediation base is 13 added / 6 removed, identical to RW01.

```
PARSE .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Errors=0
PARSE .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 Errors=0
LINES 493 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 489 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
```
