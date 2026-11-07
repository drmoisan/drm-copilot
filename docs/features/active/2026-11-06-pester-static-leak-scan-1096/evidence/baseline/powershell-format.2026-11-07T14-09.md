# Baseline: PowerShell Format (check-only)

Timestamp: 2026-11-07T14-09
Command: sh SCRATCH/issue-1096-static-ps.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> with a no-op -WriteFile seam)
EXIT_CODE: 0
Output Summary: 1103 files reported `Already formatted:`; 0 files reported `Formatted:`. No file was written (no-op WriteFile seam).
