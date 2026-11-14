# PowerShell final QC static (P5-T3)

Timestamp: 2026-11-14T05-53
Command: sh SCRATCH/issue-1162-psstatic.sh (PowerShell 7 importing the branch-current scripts/powershell/PoshQC/PoshQC.psd1, from the item worktree root): Invoke-PoshQCFormat -Root <worktree>; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Step 1 Format: Command: Invoke-PoshQCFormat -Root <worktree> | EXIT_CODE: 0 | findings: 0 files reformatted. git status --porcelain before: 5 entries (P5-T1 and P5-T2 evidence, the plan check-offs, and the digest edit); after: the same 5 entries, byte-identical listing (PORCELAIN_UNCHANGED: True).
- Step 2 Analyzer: Command: Invoke-PoshQCAnalyze -Root <worktree> | EXIT_CODE: 0 | findings: 0 (the function throws "PSScriptAnalyzer reported N issue(s)." on any finding; no throw).
- Step 3 Leak scan: Command: Invoke-PoshQCLeakScan -Root <worktree> | EXIT_CODE: 0 | findings: 0 (the scan throws on any finding or stale allowlist entry; no throw).
- The Timestamp value is the launcher's end-of-run clock reading; its start-of-run reading was not captured in the retained output.
