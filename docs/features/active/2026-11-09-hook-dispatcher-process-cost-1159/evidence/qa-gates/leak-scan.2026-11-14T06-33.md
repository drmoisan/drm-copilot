# Final leak scan ([P7-T6])

Timestamp: 2026-11-14T06-33
Command: sh SCRATCH/issue-1159-leak.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <repository root>); git diff 063504dc4b2ea08a2c5bd39b57d70ce5963815ed HEAD -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Leak scan: 788 files, 77 findings, 75 exempt, 2 allowlisted, 0 failures (baseline: 743 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures). The scan exited 0. config/poshqc-leak-allowlist.json has no diff against the merge base (0 diff lines), so no allowlist entry was added. Warning (pre-existing, as at baseline): the scan folder tests/powershell named in config/poshqc-scan.json does not exist and was skipped.
