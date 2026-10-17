# Baseline Line Counts

Timestamp: 2026-10-08T17-32
Command: foreach ($p in @('.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-feature-folder-order.ps1', '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1', 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T10.ps1
EXIT_CODE: 0
Output Summary: Ten LINES rows recorded (record-only). W05 = 480 and W06 = 477, matching research section 1.4.

```
LINES 381 .claude/hooks/enforce-epic-wave-barrier.ps1
LINES 331 .claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 444 .claude/hooks/enforce-parallel-drift-gate.ps1
LINES 480 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 477 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 197 .claude/hooks/enforce-feature-folder-order.ps1
LINES 332 .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
LINES 440 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
LINES 181 tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
LINES 497 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
