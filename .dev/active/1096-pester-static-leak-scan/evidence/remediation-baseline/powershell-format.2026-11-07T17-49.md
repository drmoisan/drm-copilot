# Remediation Baseline: PowerShell Format (cycle 2 merged tree)

Timestamp: 2026-11-07T17-49
Command: sh SCRATCH/issue-1096-static-ps.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> with a no-op -WriteFile seam; each Logger line is classified case-sensitively from the line start)
EXIT_CODE: 0
Output Summary: Merged tree at the cycle 2 merge commit (PR #1110 merged). 0 lines beginning `Formatted:`; 1126 lines beginning `Already formatted:`. Check-only run; git status --porcelain through -C was empty afterwards.
