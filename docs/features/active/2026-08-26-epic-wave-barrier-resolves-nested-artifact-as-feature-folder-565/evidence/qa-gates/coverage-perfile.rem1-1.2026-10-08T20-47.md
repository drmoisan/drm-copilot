# Final QC (Remediation Cycle 1, Iteration 1): Per-File Line Coverage (R-PROD)

Timestamp: 2026-10-08T20-47
Command: [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1')) { (CRC template body; identical to the P0-T25 body) }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T25.ps1
EXIT_CODE: 0
Output Summary: Seven rows, each Files=1, each at least 85.00% (minimum 96.10%), including both -modes.ps1 rows (97.81% and 97.78%). Each row's Missed= is at most its P0-T25 value. Source: artifacts/pester/powershell-coverage.xml written by P5-T9 (20:44:39).

| ID | Path | Covered | Missed | Line coverage | P0-T25 Missed |
|---|---|---|---|---|---|
| RW01 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 134 | 3 | 97.81% | 3 |
| RW02 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 132 | 3 | 97.78% | 3 |
| RW03 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 149 | 5 | 96.75% | 5 |
| RW04 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 165 | 0 | 100.00% | 0 |
| RW05 | `.claude/hooks/enforce-epic-wave-barrier.ps1` | 88 | 3 | 96.70% | 3 |
| RW06 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 74 | 3 | 96.10% | 3 |
| RW07 | `.claude/hooks/enforce-parallel-drift-gate.ps1` | 111 | 2 | 98.23% | 2 |

```
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=134 Missed=3
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=132 Missed=3
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 Files=1 Covered=149 Missed=5
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 Files=1 Covered=165 Missed=0
COVERAGE .claude/hooks/enforce-epic-wave-barrier.ps1 Files=1 Covered=88 Missed=3
COVERAGE .claude/hooks/enforce-parallel-cohort-barrier.ps1 Files=1 Covered=74 Missed=3
COVERAGE .claude/hooks/enforce-parallel-drift-gate.ps1 Files=1 Covered=111 Missed=2
```
