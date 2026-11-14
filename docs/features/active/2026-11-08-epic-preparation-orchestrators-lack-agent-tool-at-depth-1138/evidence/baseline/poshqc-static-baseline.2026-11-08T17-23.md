# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-08T17-23
Command: sh SCRATCH/issue-1138-p0t1.sh (pwsh 7.6.9: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text, no file written; then Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- Files: .claude/hooks/enforce-epic-invocation-origin.ps1, tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
- Step 1 format check (check-only): exit 0, files needing change 0
- Step 2 Invoke-ScriptAnalyzer: exit 0, findings 0
- git status --porcelain after the run: empty (no tracked file changed by the format check)
