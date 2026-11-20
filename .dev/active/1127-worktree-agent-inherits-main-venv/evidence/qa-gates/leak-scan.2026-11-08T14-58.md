# Final QA: PoshQC leak scan (P4-T3)

Timestamp: 2026-11-08T14-58
Command: sh SCRATCH/issue-1127-leak.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree>; the scan throws on any failure)
EXIT_CODE: 0
Output Summary:
- Leak scan: 702 files, 73 findings, 71 exempt, 2 allowlisted, 0 failures.
- Warning only: the scan folder `tests/powershell` named in config/poshqc-scan.json does not exist in the tree and was skipped (pre-existing configuration, not changed by this branch).
- `git diff --name-only <merge-base of origin/main and HEAD> HEAD -- config/poshqc-leak-allowlist.json` and `git status --porcelain -- config` both list nothing: the allowlist is unchanged.
