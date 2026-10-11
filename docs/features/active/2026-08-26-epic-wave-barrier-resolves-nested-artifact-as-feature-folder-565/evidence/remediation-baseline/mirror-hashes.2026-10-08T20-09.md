# Remediation Baseline: Mirror Parity (R-PAIRS)

Timestamp: 2026-10-08T20-09
Command: foreach ($pair in @(@('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'), @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'), @('.claude/hooks/enforce-epic-wave-barrier.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1'), @('.claude/hooks/enforce-parallel-cohort-barrier.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1'), @('.claude/hooks/enforce-parallel-drift-gate.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1'), @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'), @('.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'))) { $a = $pair[0]; $b = $pair[1]; if ((Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash) { 'MATCH ' + $a + ' == ' + $b } else { 'MISMATCH ' + $a + ' != ' + $b } }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T15.ps1
EXIT_CODE: 0
Output Summary: 7 MATCH, 0 MISMATCH.

```
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
MATCH .claude/hooks/enforce-epic-wave-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
MATCH .claude/hooks/enforce-parallel-cohort-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
MATCH .claude/hooks/enforce-parallel-drift-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
```
