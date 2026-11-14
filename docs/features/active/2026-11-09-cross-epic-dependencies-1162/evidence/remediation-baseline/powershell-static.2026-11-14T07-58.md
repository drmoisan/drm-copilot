# PowerShell Static Baseline — Remediation Cycle 1, P0-T2 (Issue 1162)

Timestamp: 2026-11-14T07-54
Command: sh SCRATCH/issue-1162-psstatic.sh (PowerShell 7 importing the branch-current scripts/powershell/PoshQC/PoshQC.psd1 from the item worktree root): Invoke-PoshQCFormat -Root <worktree>; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Step 1 Format: Command: Invoke-PoshQCFormat -Root <worktree> | EXIT_CODE: 0 | findings: 0 files reformatted (1649 "Already formatted" lines, 0 "Formatted:" lines). `git status --porcelain` before and after: the same 2 entries (the plan check-off and the untracked P0-T1 evidence file). PORCELAIN_UNCHANGED: True.
- Step 2 Analyzer: Command: Invoke-PoshQCAnalyze -Root <worktree> | EXIT_CODE: 0 | findings: 0.
- Step 3 Leak scan: Command: Invoke-PoshQCLeakScan -Root <worktree> | EXIT_CODE: 0 | findings: 0 (no throw). Informational warning: the scan configuration folder `tests/powershell` named in config/poshqc-scan.json does not exist and was skipped. This warning predates this cycle.
- The run started at 2026-11-14T07-54 and ended at 2026-11-14T07-58.
