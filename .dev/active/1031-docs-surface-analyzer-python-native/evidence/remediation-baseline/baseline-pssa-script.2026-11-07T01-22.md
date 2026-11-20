# [P0-T3] PowerShell static baseline

Timestamp: 2026-11-07T01-22
Command: direct Invoke-ScriptAnalyzer and Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-c2-pssa.ps1`)
EXIT_CODE: 0
Output Summary: three files: 0 analyzer findings and 0 formatter differences in total.

## Per-file results

| File | Findings | Formatter differences |
|---|---|---|
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 0 | 0 |
