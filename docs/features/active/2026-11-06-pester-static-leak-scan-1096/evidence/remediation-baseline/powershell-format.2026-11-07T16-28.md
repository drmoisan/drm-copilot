# Remediation Baseline: PowerShell Format (merged tree)

Timestamp: 2026-11-07T16-28
Command: sh SCRATCH/issue-1096-static-ps.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> with a no-op -WriteFile seam; each Logger line is classified case-sensitively from the line start)
EXIT_CODE: 0
Output Summary: Merged tree after the origin/main merge commit. 0 lines beginning `Formatted:`; 1124 lines beginning `Already formatted:`. Check-only run; git status --porcelain through -C was empty afterwards.
