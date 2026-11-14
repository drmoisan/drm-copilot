# PowerShell leak scan baseline ([P0-T1])

Timestamp: 2026-11-10T03-22
Command: sh SCRATCH/issue-1161-leak.sh (PowerShell 7; imports the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, runs `Invoke-PoshQCLeakScan -Root <worktree>`)
EXIT_CODE: 0
Output Summary: Leak scan: 741 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures. One warning: configured scan folder `tests/powershell` does not exist and is skipped.
