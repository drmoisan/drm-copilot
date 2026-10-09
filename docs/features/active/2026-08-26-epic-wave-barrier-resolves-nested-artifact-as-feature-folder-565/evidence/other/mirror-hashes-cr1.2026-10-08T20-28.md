# Mirror Parity: CR-1 Pairs

Timestamp: 2026-10-08T20-28
Command: foreach ($pair in @(@('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'), @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'), @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'), @('.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'))) { $a = $pair[0]; $b = $pair[1]; if ((Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash) { 'MATCH ' + $a + ' == ' + $b } else { 'MISMATCH ' + $a + ' != ' + $b } }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T11.ps1
EXIT_CODE: 0
Output Summary: 4 MATCH, 0 MISMATCH after the P2-T10 Copy-Item step (RW01->RW08, RW03->RW09, RW02->RW13, RW04->RW14).

```
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
MATCH .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 == extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
```
