# PowerShell static baseline (P0-T2)

Timestamp: 2026-11-10T03-35
Command: sh SCRATCH/issue-1162-static.sh baseline (PowerShell 7 importing the branch-current scripts/powershell/PoshQC/PoshQC.psd1, from the item worktree root): Invoke-PoshQCFormat -Root <worktree>; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Step 1 Format: Command: Invoke-PoshQCFormat -Root <worktree> | EXIT_CODE: 0 | findings: 0 files reformatted (no "Formatted:" log line). git status --porcelain before: 2 entries (plan check-off and new evidence); after: the same 2 entries; unchanged across the format step.
- Step 2 Analyzer: Command: Invoke-PoshQCAnalyze -Root <worktree> | EXIT_CODE: 0 | findings: 0 (no throw; the function throws "PSScriptAnalyzer reported N issue(s)." on any finding).
- Step 3 Leak scan: Command: Invoke-PoshQCLeakScan -Root <worktree> | EXIT_CODE: 0 | findings: 0 (no throw; the scan throws on any finding or stale allowlist entry).
