# PowerShell final QC static, second pass (P5-T3 loop restart)

Timestamp: 2026-11-14T06-37
Command: sh SCRATCH/issue-1162-psstatic.sh (PowerShell 7 importing the branch-current scripts/powershell/PoshQC/PoshQC.psd1, from the item worktree root): Invoke-PoshQCFormat -Root <worktree>; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Reason for this pass: the first Pester gate pass failed (evidence/qa-gates/pester.2026-11-14T06-37.md) and .claude/lib/epic-wave/EpicCrossDependency.psm1 and its two bundle copies changed, so the PowerShell loop restarts from step 1.
- Step 1 Format: Command: Invoke-PoshQCFormat -Root <worktree> | EXIT_CODE: 0 | findings: 0 files reformatted (1649 "Already formatted" lines, 0 "Formatted:" lines). git status --porcelain before: 10 entries; after: the same 10 entries (PORCELAIN_UNCHANGED: True).
- Step 2 Analyzer: Command: Invoke-PoshQCAnalyze -Root <worktree> | EXIT_CODE: 0 | findings: 0 (no throw).
- Step 3 Leak scan: Command: Invoke-PoshQCLeakScan -Root <worktree> | EXIT_CODE: 0 | findings: 0 (no throw).
- The run started at the Timestamp value and ended at 2026-11-14T06-41.
