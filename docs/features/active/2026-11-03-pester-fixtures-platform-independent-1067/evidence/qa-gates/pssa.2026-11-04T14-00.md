# Final QA: PSScriptAnalyzer (P6-T5, restart pass after resume)

Timestamp: 2026-11-04T14-00
Command: sh SCRATCH/issue-1067-fmt-pssa.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-pssa.ps1: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over the 22 change-set files)
EXIT_CODE: 0
Output Summary:
- FILES 22
- PSSA-FINDINGS=0
