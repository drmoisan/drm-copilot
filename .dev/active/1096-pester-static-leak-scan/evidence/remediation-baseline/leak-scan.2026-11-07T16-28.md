# Remediation Baseline: Leak Scan (merged tree)

Timestamp: 2026-11-07T16-28
Command: sh SCRATCH/issue-1096-scan.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree> with the committed config/poshqc-leak-allowlist.json; exits 0 only when the scan does not throw)
EXIT_CODE: 0
Output Summary: Merged tree, including main's Pester files. Leak scan: 558 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures. No unallowlisted finding, stale entry, or parse error.

## Findings

FINDING: NONE

The scan logged no per-failure message; its only log line is the summary above. The scan configuration warned that the configured folder `tests/powershell` does not exist under the root and was skipped; that folder is absent on both sides of the merge.
