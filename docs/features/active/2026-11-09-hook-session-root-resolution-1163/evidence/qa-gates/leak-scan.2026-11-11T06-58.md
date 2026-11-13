# PoshQC Leak Scan, final tree (issue #1163, P8-T3)

Timestamp: 2026-11-11T06-58
Command: sh SCRATCH/issue-1163-leak.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <item worktree>); allowlist check: git diff --exit-code <merge base of origin/main and HEAD> -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: Rerun after the resolver-failure rows were added to the two file-size TargetWorktree suites, so the scan covers the final tree. Leak scan: 749 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (exit 0). config/poshqc-leak-allowlist.json is unchanged against the merge base, so no allowlist entry was added. Supersedes leak-scan.2026-11-11T06-20.md.
