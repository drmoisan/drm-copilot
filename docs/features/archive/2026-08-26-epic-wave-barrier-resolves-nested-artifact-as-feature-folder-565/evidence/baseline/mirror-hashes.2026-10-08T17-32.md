# Baseline Mirror Parity (MIRROR-PAIRS-EXISTING)

Timestamp: 2026-10-08T17-32
Command: foreach ($pair in @(<seven MIRROR-PAIRS-EXISTING pairs>)) { ... Get-FileHash -Algorithm SHA256 ... 'MATCH ' / 'MISMATCH ' }  (full body in <scratchpad>/c2-565-P0-T12.ps1; pairs listed below)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T12.ps1
EXIT_CODE: 0
Output Summary: 7 MATCH, 0 MISMATCH.

```
MATCH .claude/hooks/enforce-epic-wave-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
MATCH .claude/hooks/enforce-parallel-cohort-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
MATCH .claude/hooks/enforce-parallel-drift-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .claude/hooks/enforce-feature-folder-order.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
MATCH .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
```
