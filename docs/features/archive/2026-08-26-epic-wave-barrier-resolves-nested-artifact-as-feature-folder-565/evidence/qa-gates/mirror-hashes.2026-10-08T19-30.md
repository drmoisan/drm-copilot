# Mirror Parity (MIRROR-PAIRS, ten pairs)

Timestamp: 2026-10-08T19-30
Command: foreach ($pair in @(<ten MIRROR-PAIRS listed below>)) { $a = $pair[0]; $b = $pair[1]; if ((Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash) { 'MATCH ' + $a + ' == ' + $b } else { 'MISMATCH ' + $a + ' != ' + $b } }  (full body in <scratchpad>/c2-565-P8-T4.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P8-T4.ps1
EXIT_CODE: 0
Output Summary: 10 MATCH, 0 MISMATCH. Every new or changed hook under .claude/hooks/ and .codex/hooks/ has an equal-SHA256 bundled mirror, and the Claude and Codex copies of feature-folder-resolution.ps1 are equal.

```
MATCH .claude/hooks/feature-folder-resolution.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-folder-resolution.ps1
MATCH .claude/hooks/enforce-epic-wave-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
MATCH .claude/hooks/enforce-parallel-cohort-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
MATCH .claude/hooks/enforce-parallel-drift-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .claude/hooks/enforce-feature-folder-order.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
MATCH .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
MATCH .codex/hooks/feature-folder-resolution.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-folder-resolution.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .claude/hooks/feature-folder-resolution.ps1 == .codex/hooks/feature-folder-resolution.ps1
```
