# Per-File Line Coverage (PS-PROD), Final QC Iteration 3

Timestamp: 2026-10-08T19-13
Command: [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @(<PS-PROD, nine paths>)) { ... 'COVERAGE ' + $p + ' Files=' + $s.Count + ' Covered=' + ... + ' Missed=' + ... }  (CRC template; full body in <scratchpad>/c2-565-P10-T10.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T10.ps1
EXIT_CODE: 0
Output Summary: Nine rows, each Files=1, each at least 85.00%. Each copy of feature-folder-resolution.ps1 is measured on its own row at 100.00%. Source: artifacts/pester/powershell-coverage.xml written by P10-T8 iteration 3.

| Path | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/feature-folder-resolution.ps1` | 111 | 0 | 100.00% |
| `.codex/hooks/feature-folder-resolution.ps1` | 111 | 0 | 100.00% |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 88 | 3 | 96.70% |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 74 | 3 | 96.10% |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 111 | 2 | 98.23% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 133 | 3 | 97.79% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 131 | 3 | 97.76% |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 55 | 5 | 91.67% |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 56 | 3 | 94.92% |

```
COVERAGE .claude/hooks/feature-folder-resolution.ps1 Files=1 Covered=111 Missed=0
COVERAGE .codex/hooks/feature-folder-resolution.ps1 Files=1 Covered=111 Missed=0
COVERAGE .claude/hooks/enforce-epic-wave-barrier.ps1 Files=1 Covered=88 Missed=3
COVERAGE .claude/hooks/enforce-parallel-cohort-barrier.ps1 Files=1 Covered=74 Missed=3
COVERAGE .claude/hooks/enforce-parallel-drift-gate.ps1 Files=1 Covered=111 Missed=2
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=133 Missed=3
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=131 Missed=3
COVERAGE .claude/hooks/enforce-feature-folder-order.ps1 Files=1 Covered=55 Missed=5
COVERAGE .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 Files=1 Covered=56 Missed=3
```
