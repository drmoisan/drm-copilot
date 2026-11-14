# Final QC — PowerShell Static (cycle 3, [P3-T1])

Timestamp: 2026-11-14T01-17
Command: sh SCRATCH/issue-1160-c3r3-static.sh (Invoke-Formatter comparison of the formatted text with the file, no rewrite, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, over the six files of [P0-T1] plus the new Modelled suite)
EXIT_CODE: 0
Output Summary: 7 files; format 0 differences; lint 0 findings; type check not applicable to PowerShell; git status --porcelain digest identical before and after (no rewrite), so the loop closed on its first pass.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | Invoke-Formatter comparison, 7 files | 0 | 0 |
| Lint | Invoke-ScriptAnalyzer with the repository settings, 7 files | 0 | 0 |
| Type check | not applicable (PowerShell) | n/a | n/a |

| File | Formatter differences | Analyzer findings | Logical lines |
|---|---|---|---|
| .claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 489 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 489 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 489 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1 | 0 | 0 | 489 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1 | 0 | 0 | 210 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1 | 0 | 0 | 361 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Modelled.Tests.ps1 | 0 | 0 | 97 |
