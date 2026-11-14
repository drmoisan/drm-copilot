# PoshQC Leak Scan, remediation cycle 1 (issue #1163, [P0-T1], finding F1)

Timestamp: 2026-11-13T14-53
Command: sh SCRATCH/issue-1163-leak.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <item worktree>); allowlist check: git diff --exit-code <merge base of origin/main and HEAD> -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Leak scan on the head carrying "fix(1163): name the full stale branch in the repair detail (F1)": 750 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (exit 0), the same result as leak-scan.2026-11-13T14-10.md. The scan printed the same warning that the configured scan folder tests/powershell does not exist under the root and was skipped (absent on main as well). config/poshqc-leak-allowlist.json is unchanged against the merge base (git diff --exit-code exit 0). SCRATCH here is the item worktree's gitignored scratch folder for issue 1163.
