# Final QC — PowerShell Static ([P3-T1])

Timestamp: 2026-11-13T19-06
Command: sh SCRATCH/issue-1160-r4-static.sh (pwsh 7, per file: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file text, no rewrite; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: format 0 differences and lint 0 findings over the six files of [P0-T1]; type check not applicable to PowerShell; git status --porcelain digest identical before and after (no rewrite); no restart needed.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | Invoke-Formatter comparison, 6 files | 0 | 0 differences |
| Lint | Invoke-ScriptAnalyzer with repository settings, 6 files | 0 | 0 findings |
| Type check | not applicable (PowerShell) | n/a | n/a |

| File | Formatter difference | Analyzer findings | Logical lines |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 263 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 263 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 263 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 263 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` | 0 | 0 | 163 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | 0 | 0 | 361 |
