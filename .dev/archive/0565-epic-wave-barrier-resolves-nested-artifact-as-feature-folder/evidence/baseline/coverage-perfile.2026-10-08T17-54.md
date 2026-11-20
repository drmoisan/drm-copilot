# Baseline Per-File Line Coverage (PS-EXISTING)

Timestamp: 2026-10-08T17-54
Command: [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @(<PS-EXISTING, seven paths>)) { ... 'COVERAGE ' + $p + ' Files=' + $s.Count + ' Covered=' + ... + ' Missed=' + ... }  (CRC template; full body in <scratchpad>/c2-565-P0-T21.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T21.ps1
EXIT_CODE: 0
Output Summary: Seven rows, each Files=1. Baseline line coverage: epic wave barrier 99.01%, cohort barrier 98.68%, drift gate 99.12%, Claude modes 98.51%, Codex modes 98.48%, feature-folder-order 91.11%, prd-feature helpers 96.61%. Source: artifacts/pester/powershell-coverage.xml written by P0-T19.

| Path | Files | Covered | Missed | Line coverage |
|---|---|---|---|---|
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 1 | 100 | 1 | 99.01% |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 1 | 75 | 1 | 98.68% |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 1 | 113 | 1 | 99.12% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 1 | 132 | 2 | 98.51% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 1 | 130 | 2 | 98.48% |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 1 | 41 | 4 | 91.11% |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 1 | 57 | 2 | 96.61% |

```
COVERAGE .claude/hooks/enforce-epic-wave-barrier.ps1 Files=1 Covered=100 Missed=1
COVERAGE .claude/hooks/enforce-parallel-cohort-barrier.ps1 Files=1 Covered=75 Missed=1
COVERAGE .claude/hooks/enforce-parallel-drift-gate.ps1 Files=1 Covered=113 Missed=1
COVERAGE .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=132 Missed=2
COVERAGE .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Files=1 Covered=130 Missed=2
COVERAGE .claude/hooks/enforce-feature-folder-order.ps1 Files=1 Covered=41 Missed=4
COVERAGE .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 Files=1 Covered=57 Missed=2
```
