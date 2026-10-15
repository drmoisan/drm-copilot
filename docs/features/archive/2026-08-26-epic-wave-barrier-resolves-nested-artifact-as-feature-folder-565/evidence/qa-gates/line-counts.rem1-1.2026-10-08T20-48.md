# Final QC (Remediation Cycle 1, Iteration 1): Line Counts (R-PROD and R-TESTS)

Timestamp: 2026-10-08T20-48
Command: foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1')) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T14.ps1 (same LC body as the baseline)
EXIT_CODE: 0
Output Summary: LINES 496 (RW01), 493 (RW02), 468 (RW03), 489 (RW04); RW05-RW07 376, 348, 454, equal to their P0-T14 values. Tests 273, 271, 245, 176, 186. Every value is at most 500.

```
LINES 496 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 493 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 468 .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
LINES 489 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
LINES 376 .claude/hooks/enforce-epic-wave-barrier.ps1
LINES 348 .claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 454 .claude/hooks/enforce-parallel-drift-gate.ps1
LINES 273 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 271 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 245 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
LINES 176 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
LINES 186 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
```
