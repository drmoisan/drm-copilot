# Leak-Scan Merge Classification (Remediation Cycle 1)

Timestamp: 2026-11-07T16-29
Command: sh SCRATCH/issue-1096-scan.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree> with the committed config/poshqc-leak-allowlist.json; exits 0 only when the scan does not throw)
EXIT_CODE: 0
Output Summary: Re-run on the merged tree. Leak scan: 558 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.

Input: the `FINDING:` rows of `evidence/remediation-baseline/leak-scan.2026-11-07T16-28.md`, the lexicographically greatest `leak-scan.*.md` in that folder.

## Classification

| Input row | Class | Disposition |
|---|---|---|
| NONE | n/a | The merged tree introduces no finding, so no row is classified and no file under `tests/scripts/` or `config/poshqc-leak-allowlist.json` changes. |

The two allowlist entries remain matched (2 allowlisted, 0 stale), so no entry is removed.
