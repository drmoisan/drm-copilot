# Final-QC Static: PowerShell (remediation cycle 1, P2-T1)

Timestamp: 2026-11-16T03-37
Plan: remediation-plan.2026-11-16T02-21.md
Command: sh SCRATCH/issue-1195-final-static.sh, which runs (1) PoshQC format: Invoke-PoshQCFormat over the repository with a no-op -WriteFile seam (Formatted: log lines are the drift count), git status --porcelain captured before and after; (2) PSScriptAnalyzer: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over every .ps1 and .psm1 from Get-PoshQCFileList, with the transient NullReferenceException retry that Invoke-PoshQCAnalyze applies; (3) Invoke-PoshQCLeakScan -Root <worktree> through the branch-current scripts/powershell/PoshQC/PoshQC.psd1
EXIT_CODE: 0
Output Summary:
- Run window: 2026-11-16T03-30 to 03-37, at HEAD 9063a8c07 (Phase 1 committed).
- Format: exit 0; 1793 files checked; finding count (files the formatter would change) 0; git status --porcelain identical before and after.
- PSScriptAnalyzer: exit 0; 1783 files; finding count 0; one transient NullReferenceException retried (engine error, not a finding).
- Leak scan: exit 0; 859 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (one warning: the scan configuration folder tests/powershell does not exist and is skipped; unchanged from the prior cycle).
- Type check: not applicable to PowerShell.
- Loop: single clean pass; no restart.
