# Mirror Parity: CR-4 Pairs

Timestamp: 2026-10-08T20-33
Command: foreach ($pair in @(@('.claude/hooks/enforce-epic-wave-barrier.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1'), @('.claude/hooks/enforce-parallel-cohort-barrier.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1'), @('.claude/hooks/enforce-parallel-drift-gate.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1'))) { $a = $pair[0]; $b = $pair[1]; if ((Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash) { 'MATCH ' + $a + ' == ' + $b } else { 'MISMATCH ' + $a + ' != ' + $b } }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P3-T11.ps1
EXIT_CODE: 0
Output Summary: 3 MATCH, 0 MISMATCH after the P3-T10 Copy-Item step (RW05->RW10, RW06->RW11, RW07->RW12).

```
MATCH .claude/hooks/enforce-epic-wave-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
MATCH .claude/hooks/enforce-parallel-cohort-barrier.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
MATCH .claude/hooks/enforce-parallel-drift-gate.ps1 == extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
```
