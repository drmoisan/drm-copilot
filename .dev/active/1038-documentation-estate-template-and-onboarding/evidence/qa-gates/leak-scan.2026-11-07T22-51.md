# Leak scan ([P4-T3])

Timestamp: 2026-11-07T22-51
Command: sh SCRATCH/issue-1038-leak.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree>)
EXIT_CODE: 0
Output Summary: Leak scan: 690 files, 71 findings, 69 exempt, 2 allowlisted, 0 failures. The scan log names none of the three CHANGED-PS files (grep count 0). One informational warning: the scan configuration folder `tests/powershell` does not exist and is skipped.

CHANGED-PS findings: 0
