# PSSA Baseline (P0-T2)

Timestamp: 2026-11-16T01-02
Command: pwsh -NoProfile -File SCRATCH/issue-1025-static.ps1 (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over every .ps1 and .psm1 file that Get-PoshQCFileList returns for scripts and tests/scripts; a transient engine NullReferenceException is retried after a module re-import, as Invoke-PoshQCAnalyze does); run started 2026-11-16T00-56
EXIT_CODE: 0
Output Summary: 928 files analyzed; PSSA finding count 0.
