# PoshQC Leak Scan (issue #1163, P8-T3)

Timestamp: 2026-11-11T06-20
Command: sh SCRATCH/issue-1163-leak.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <item worktree>); allowlist check: git diff --exit-code <merge base of origin/main and HEAD> -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Leak scan: 749 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (exit 0; the scan throws on any failure). config/poshqc-leak-allowlist.json is unchanged against the merge base (git diff --exit-code exit 0), so no allowlist entry was added. The scan warned that the configured scan folder tests/powershell does not exist and was skipped, which is a pre-existing configuration condition unrelated to this change.
