# Remediation Baseline: Per-File Line Coverage (R-PROD)

Timestamp: 2026-10-08T20-19
Command: [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1')) { $d = $p.Substring(0, $p.LastIndexOf('/')); $n = $p.Substring($p.LastIndexOf('/') + 1); $s = @($x.SelectNodes('//package') | Where-Object { ($_.GetAttribute('name') -replace '\\', '/').EndsWith('/' + $d) } | ForEach-Object { @($_.SelectNodes('sourcefile')) } | Where-Object { $nm = $_.GetAttribute('name') -replace '\\', '/'; $nm -eq $n -or $nm.EndsWith('/' + $n) }); $c = @($s | ForEach-Object { $_.SelectSingleNode("counter[@type='LINE']") }); 'COVERAGE ' + $p + ' Files=' + $s.Count + ' Covered=' + ($c | ForEach-Object { [int]$_.GetAttribute('covered') } | Measure-Object -Sum).Sum + ' Missed=' + ($c | ForEach-Object { [int]$_.GetAttribute('missed') } | Measure-Object -Sum).Sum }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T25.ps1
EXIT_CODE: 0
Output Summary: Seven rows, each Files=1, with numeric Covered and Missed values. Source: artifacts/pester/powershell-coverage.xml written by P0-T23 (20:17:15). Percent = Covered / (Covered + Missed).

| ID | Path | Covered | Missed | Line coverage |
|---|---|---|---|---|
| RW01 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 133 | 3 | 97.79% |
| RW02 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 131 | 3 | 97.76% |
| RW03 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 148 | 5 | 96.73% |
| RW04 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 164 | 0 | 100.00% |
| RW05 | `.claude/hooks/enforce-epic-wave-barrier.ps1` | 88 | 3 | 96.70% |
| RW06 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 74 | 3 | 96.10% |
| RW07 | `.claude/hooks/enforce-parallel-drift-gate.ps1` | 111 | 2 | 98.23% |

```
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=133 Missed=3
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=131 Missed=3
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 Files=1 Covered=148 Missed=5
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 Files=1 Covered=164 Missed=0
COVERAGE .claude/hooks/enforce-epic-wave-barrier.ps1 Files=1 Covered=88 Missed=3
COVERAGE .claude/hooks/enforce-parallel-cohort-barrier.ps1 Files=1 Covered=74 Missed=3
COVERAGE .claude/hooks/enforce-parallel-drift-gate.ps1 Files=1 Covered=111 Missed=2
```
