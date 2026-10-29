# PowerShell Baseline: PoshQC Format Check (P0-T5)

Timestamp: 2026-10-29T14-35
Command: sh SCRATCH/issue-992-ps.sh static -FormatMode check (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> with an injected non-writing WriteFile that records each file the formatter would change)
EXIT_CODE: 0
Output Summary: Check mode; 0 files would be changed by the formatter. No file was written.
