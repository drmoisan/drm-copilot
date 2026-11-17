# Final-QC Static: PowerShell (P3-T1)

Timestamp: 2026-11-16T01-20
Command: sh SCRATCH/issue-1195-final-static.sh, which runs (1) PoshQC format: Invoke-PoshQCFormat over the repository with a no-op -WriteFile seam (Formatted: log lines are the drift count), git status --porcelain captured before and after; (2) PSScriptAnalyzer: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over every .ps1 and .psm1 from Get-PoshQCFileList, with the same transient NullReferenceException retry that Invoke-PoshQCAnalyze applies; (3) Invoke-PoshQCLeakScan -Root <worktree> through the branch-current scripts/powershell/PoshQC/PoshQC.psd1
EXIT_CODE: 0
Output Summary:
- Format: exit 0; 1793 files checked; finding count (files the formatter would change) 0; git status --porcelain identical before and after.
- PSScriptAnalyzer: exit 0; 1783 files; finding count 0; NullReferenceException retries 0.
- Leak scan: exit 0; 859 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (one warning: the scan configuration folder tests/powershell does not exist and is skipped).
- Type check: not applicable to PowerShell.
- Loop history: the first P3-T1 pass ended with a transient PSScriptAnalyzer engine error (Object reference not set to an instance of an object; 0 findings, no file changed); the analyzer step gained the NRE retry that Invoke-PoshQCAnalyze uses and the loop restarted from this task. This artifact records the clean second pass.
