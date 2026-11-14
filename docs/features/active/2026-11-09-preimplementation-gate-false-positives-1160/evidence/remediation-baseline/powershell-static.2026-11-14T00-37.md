# Remediation Baseline — PowerShell Static (cycle 3, [P0-T1])

Timestamp: 2026-11-14T00-37
Command: sh SCRATCH/issue-1160-r4-static.sh (Invoke-Formatter comparison of the formatted text with the file, no rewrite, and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, over six files)
EXIT_CODE: 0
Output Summary: 6 files; 0 formatter differences; 0 analyzer findings; git status --porcelain digest identical before and after (no rewrite). Logical line counts: four commands-sibling copies 263 each, Cases file 163, existing commands suite 361.

| File | Formatter differences | Analyzer findings | Logical lines |
|---|---|---|---|
| .claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 263 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 263 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 263 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 263 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1 | 0 | 0 | 163 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1 | 0 | 0 | 361 |
