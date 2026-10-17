# Parse and Size: Barrier Hooks (RW05, RW06, RW07) after ED-8

Timestamp: 2026-10-08T20-32
Command: (a) foreach ($p in @('.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1')) { $t = $null; $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $p).Path, [ref]$t, [ref]$e); 'PARSE ' + $p + ' Errors=' + $e.Count }; (b) foreach ($p in @('.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T9-a.ps1; sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T9-b.ps1
EXIT_CODE: 0
Output Summary: Three Errors=0 lines. LINES 376, 348, 454, each equal to its P0-T14 value. Supporting check: git diff --numstat against the remediation base reports 2 added / 2 removed lines per file (the comment line and the deny-string line only).

```
PARSE .claude/hooks/enforce-epic-wave-barrier.ps1 Errors=0
PARSE .claude/hooks/enforce-parallel-cohort-barrier.ps1 Errors=0
PARSE .claude/hooks/enforce-parallel-drift-gate.ps1 Errors=0
LINES 376 .claude/hooks/enforce-epic-wave-barrier.ps1
LINES 348 .claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 454 .claude/hooks/enforce-parallel-drift-gate.ps1
2	2	.claude/hooks/enforce-epic-wave-barrier.ps1
2	2	.claude/hooks/enforce-parallel-cohort-barrier.ps1
2	2	.claude/hooks/enforce-parallel-drift-gate.ps1
```
