# QA Gate: Leak Scan

Timestamp: 2026-11-07T15-38
Command: sh SCRATCH/issue-1096-scan.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree> with the committed config/poshqc-leak-allowlist.json; exits 0 only when the scan does not throw)
EXIT_CODE: 0
Output Summary: Third pass, after the Windows PowerShell 5.1 allowlist fix. Leak scan: 548 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures. No unallowlisted finding, stale entry, or parse error.
