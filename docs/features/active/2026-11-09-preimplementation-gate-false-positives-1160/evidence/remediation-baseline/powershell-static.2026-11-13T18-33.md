# Remediation Baseline — PowerShell Static (cycle 2, [P0-T1])

Timestamp: 2026-11-13T18-33
Command: sh SCRATCH/issue-1160-r4-static.sh (pwsh 7: per file, Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file text, no rewrite; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; @(Get-Content -LiteralPath <file>).Count)
EXIT_CODE: 0
Output Summary: 6 files, 0 formatter differences, 0 analyzer findings; git status --porcelain digest identical before and after (no rewrite).

| File | Formatter difference | Analyzer findings | Logical lines |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 196 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 196 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 196 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 196 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` | 0 | 0 | 154 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | 0 | 0 | 256 |
