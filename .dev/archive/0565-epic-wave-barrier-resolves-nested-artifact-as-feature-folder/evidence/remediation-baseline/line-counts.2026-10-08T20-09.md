# Remediation Baseline: Line Counts (R-PROD and R-TESTS)

Timestamp: 2026-10-08T20-09
Command: foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T14.ps1
EXIT_CODE: 0
Output Summary: RW01 489, RW02 486, RW03 466, RW04 487 (all equal to the plan's derivation values); RW05 376, RW06 348, RW07 454; tests 202, 199, 244, 175, 185. Every value is at most 500.

```
LINES 489 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 486 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 466 .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
LINES 487 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
LINES 376 .claude/hooks/enforce-epic-wave-barrier.ps1
LINES 348 .claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 454 .claude/hooks/enforce-parallel-drift-gate.ps1
LINES 202 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 199 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 244 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
LINES 175 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
LINES 185 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
```
