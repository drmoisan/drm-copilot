# Baseline - Leak Scan - [P0-T5]

Timestamp: 2026-11-19T08-56
Command: sh SCRATCH/issue-1049-static.sh leak (PowerShell 7 session importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: `Leak scan: 896 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` Failure count 0. One warning: configured scan folder `tests/powershell` does not exist and is skipped.
