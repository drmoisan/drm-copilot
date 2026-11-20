# Baseline PowerShell Static Stages (P0-T3)

Timestamp: 2026-10-28T13-04
Command: sh SCRATCH/issue-989-run.sh SCRATCH/issue-989-static.ps1 (PowerShell 7: per file, Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file content, report-only, no write; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0

| File | Formatting differs | Analyzer findings |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | False | 0 |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | False | 0 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | False | 0 |

Output Summary: all three existing CHF are formatter-clean and carry 0 PSScriptAnalyzer findings (TOTAL_FINDINGS=0).
