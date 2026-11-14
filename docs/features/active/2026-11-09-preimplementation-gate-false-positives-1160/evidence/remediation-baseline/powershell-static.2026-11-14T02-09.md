# PowerShell Static Baseline (cycle 4, [P0-T1])

Timestamp: 2026-11-14T02-09
Command: sh SCRATCH/issue-1160-r4-static.sh (Invoke-Formatter on each file's text compared ordinally with the file, no rewrite; Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; line count from Get-Content)
EXIT_CODE: 0
Output Summary: 6 files, 0 formatter differences, 0 analyzer findings; each sibling copy 489 lines. `git status --porcelain` digest equal before and after (no rewrite).

| File | Formatter difference | Analyzer findings | Lines |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 489 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 489 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 489 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 0 | 0 | 489 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` | 0 | 0 | 210 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | 0 | 0 | 361 |
