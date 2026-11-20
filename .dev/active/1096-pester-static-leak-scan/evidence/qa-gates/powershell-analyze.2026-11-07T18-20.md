# QA Gate: PowerShell Analyze (Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-20
Command: sh SCRATCH/issue-1096-static-ps.sh (direct Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over the .ps1 and .psm1 files of Get-PoshQCFileList -Root <item worktree>)
EXIT_CODE: 0
Output Summary: 1129 files analyzed; 0 findings; 0 analyzer engine errors.
