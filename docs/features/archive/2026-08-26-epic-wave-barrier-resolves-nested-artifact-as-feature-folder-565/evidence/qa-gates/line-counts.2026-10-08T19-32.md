# Size Cap: 29 PowerShell Write-Set Paths

Timestamp: 2026-10-08T19-32
Command: foreach ($p in @(<the 29 .ps1 paths in W01-W18 and W21-W31>)) { 'LINES ' + @(Get-Content -LiteralPath $p).Count + ' ' + $p }  (full body in <scratchpad>/c2-565-P8-T6.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P8-T6.ps1
EXIT_CODE: 0
Output Summary: 29 LINES rows, each at most 500. Largest: legacy-codex-hook-contracts.Tests.ps1 497 (unchanged count; line 30 edited in place), Claude modes 489, Codex modes 486, drift gate 454.

```
LINES 373 .claude/hooks/feature-folder-resolution.ps1
LINES 376 .claude/hooks/enforce-epic-wave-barrier.ps1
LINES 348 .claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 454 .claude/hooks/enforce-parallel-drift-gate.ps1
LINES 489 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 486 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 281 .claude/hooks/enforce-feature-folder-order.ps1
LINES 343 .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
LINES 373 .codex/hooks/feature-folder-resolution.ps1
LINES 373 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-folder-resolution.ps1
LINES 376 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
LINES 348 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
LINES 454 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
LINES 489 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 281 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
LINES 343 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
LINES 373 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-folder-resolution.ps1
LINES 486 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
LINES 274 tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
LINES 274 tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
LINES 244 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
LINES 175 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
LINES 185 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
LINES 202 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 199 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
LINES 97 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
LINES 441 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
LINES 367 tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
LINES 497 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
