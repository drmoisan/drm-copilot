# PoshQC Leak Scan after the self-review fix (issue #1163, P8-T3 re-run)

Timestamp: 2026-11-13T14-10
Command: sh SCRATCH/issue-1163-leak.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <item worktree>); allowlist check: git diff --exit-code <merge base of origin/main and HEAD> -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Leak scan on the head carrying the P8-T8 fix: 750 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (exit 0), the same result as leak-scan.2026-11-12T13-03.md. The scan printed one warning that the configured scan folder tests/powershell does not exist under the root and was skipped; that folder is absent on main as well, so the warning is outside this item. config/poshqc-leak-allowlist.json is unchanged against the merge base (git diff --exit-code exit 0), so no allowlist entry was added. SCRATCH here is the item worktree's gitignored scratch folder for issue 1163.
