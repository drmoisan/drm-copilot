# QA Gate: PowerShell Format

Timestamp: 2026-11-07T15-05
Command: sh SCRATCH/issue-1096-static-ps.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree>; each Logger line is classified case-sensitively from the line start)
EXIT_CODE: 0
Output Summary: 0 lines beginning `Formatted:`; 1110 lines beginning `Already formatted:`. No file needed formatting.
