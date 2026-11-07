# PoshQC Leak Scan - remediation cycle 1, issue #1114

Timestamp: 2026-11-07T20-27
Command: sh SCRATCH/issue-1114-leak.sh (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <item worktree>, as the poshqc / PowerShell QC static job runs it)
EXIT_CODE: 0
Output Summary:
- Launcher exit 0. Scan summary line: 570 files scanned, 69 findings, 67 exempt, 2 allowlisted, 0 failures.
- The only warning is the scan configuration's absent folder `tests/powershell`, which is skipped.
- `config/poshqc-leak-allowlist.json` is unchanged (`git status --porcelain` for it: 0 lines).
