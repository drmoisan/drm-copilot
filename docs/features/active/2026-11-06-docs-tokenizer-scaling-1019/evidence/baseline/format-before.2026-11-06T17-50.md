# Format Baseline - Issue 1019

Timestamp: 2026-11-06T17-50
Command: sh SCRATCH/issue-1019-p0-t4.sh (SCRATCH/issue-1019-p0-observe.ps1 -Step T4: Invoke-Formatter -ScriptDefinition with scripts/powershell/PoshQC/settings/pssa.settings.psd1, compared by case-sensitive equality with the file text; no file was written)
EXIT_CODE: 0
Output Summary: Formatter text equal for both files. git status --porcelain was empty for MODULE and SUITE before and after the observation.

| File | Formatter text | Source characters | Formatted characters |
| --- | --- | --- | --- |
| `.claude/lib/docs/DocsPythonTokens.psm1` | equal | 12771 | 12771 |
| `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | equal | 12006 | 12006 |
