# PSSA Baseline, Plan B (P0-T3)

Timestamp: 2026-11-16T04-02
Command: pwsh -NoProfile -File SCRATCH/issue-1025-static.ps1 -OutJson SCRATCH/issue-1025-static-b0.json (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over every .ps1 and .psm1 file that Get-PoshQCFileList returns for scripts and tests/scripts)
EXIT_CODE: 0
Output Summary: 935 files analyzed; PSSA finding count 0.

PssaFindingCount: 0
