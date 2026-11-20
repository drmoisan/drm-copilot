# Stage E Static PowerShell Baseline

Timestamp: 2026-11-07T11-19
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-static.ps1 (Invoke-PoshQCFormat check-only with a no-op -WriteFile, then a direct Invoke-ScriptAnalyzer run with scripts/powershell/PoshQC/settings/pssa.settings.psd1) over .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
EXIT_CODE: 0
Output Summary:
    powershell-files=2
    FORMAT .claude/hooks/validate-planner-output.ps1 already=1 formatted=0
    FORMAT tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 already=1 formatted=0
    targets-not-formatted=0
    warm-up=ok
    ANALYZE .claude/hooks/validate-planner-output.ps1 findings=0
    ANALYZE tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 findings=0
    analyzer-total=0
    exit=0

No test suite ran. Analyzer findings come from the direct Invoke-ScriptAnalyzer run, not from MCP output.
