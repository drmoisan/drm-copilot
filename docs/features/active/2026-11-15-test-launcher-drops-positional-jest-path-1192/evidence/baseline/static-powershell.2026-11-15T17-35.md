# Static baseline, PowerShell (P0-T1)

Timestamp: 2026-11-15T17-35
Command: format step: PSScriptAnalyzer `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` in compare-only mode (no write; PoshQC format has no check switch), then analyze step: `Invoke-ScriptAnalyzer -Severity Error,Warning,Information` with the same settings, over the three in-scope files, run by `sh SCRATCH/issue-1192-static.sh`.
EXIT_CODE: 0
Output Summary:
- Files: `.claude/hooks/test-execution-policy.ps1`, `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`, `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`.
- Format step: EXIT_CODE 0, drift files 0 (all three already formatted).
- Analyze step: EXIT_CODE 0, findings 0 for each file (total 0).
- `git status --porcelain` before: empty; after: empty (no tracked change).
