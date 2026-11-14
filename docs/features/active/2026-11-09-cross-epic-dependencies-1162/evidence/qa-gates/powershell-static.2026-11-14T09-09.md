# PowerShell Final QC Static — Remediation Cycle 1, P2-T2 (Issue 1162)

Timestamp: 2026-11-14T09-04
Command: sh SCRATCH/issue-1162-psstatic.sh (PowerShell 7 importing the branch-current scripts/powershell/PoshQC/PoshQC.psd1 from the item worktree root, at HEAD after the origin/main merge): Invoke-PoshQCFormat -Root <worktree>; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Step 1 Format: Command: Invoke-PoshQCFormat -Root <worktree> | EXIT_CODE: 0 | findings: 0 files reformatted (1678 "Already formatted" lines, 0 "Formatted:" lines; the count rose from 1649 because #1156 added PowerShell files). `git status --porcelain` empty before and after (PORCELAIN_UNCHANGED: True).
- Step 2 Analyzer: Command: Invoke-PoshQCAnalyze -Root <worktree> | EXIT_CODE: 0 | findings: 0.
- Step 3 Leak scan: Command: Invoke-PoshQCLeakScan -Root <worktree> | EXIT_CODE: 0 | findings: 0 (clean; the pre-existing informational warning about the absent `tests/powershell` scan folder is unchanged).
- The run started at 2026-11-14T09-04 and ended at 2026-11-14T09-09.
