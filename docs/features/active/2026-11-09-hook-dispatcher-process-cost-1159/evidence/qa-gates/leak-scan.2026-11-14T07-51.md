# Leak scan — main-sync cycle 1 ([P1-T11])

Timestamp: 2026-11-14T07-51
Command: sh SCRATCH/issue-1159-leak.sh (pwsh 7 from the worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <repository root>); git diff 2c8dee6dd3a82f210561d9efe623767ae902de51 -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Leak scan: 800 files, 77 findings, 75 exempt, 2 allowlisted, 0 failures, exit 0. The scan printed one warning: scan folder 'tests/powershell' from config/poshqc-scan.json does not exist under the root and was skipped. config/poshqc-leak-allowlist.json has no diff against the new merge base (0 diff lines), and no allowlist entry was added.
