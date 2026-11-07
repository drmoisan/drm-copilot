# Regression: Leak Scan After Remediation

Timestamp: 2026-11-07T14-42
Command: sh SCRATCH/issue-1096-scan.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree> with the committed config/poshqc-leak-allowlist.json; the launcher exits 0 only when the scan does not throw)
EXIT_CODE: 0
Output Summary: Leak scan: 547 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures. No unallowlisted finding, no stale entry, no parse error. The first scan reported 71 findings; the 2 class T rows were fixed (P3-T1, P3-T3), the 67 LASTEXITCODE rows are covered by the single exemptGlobalVariables entry, and the 2 class C2 rows are allowlisted.

## Allowlist Check

- version: 1
- exemptGlobalVariables: 1 entry (LASTEXITCODE, spec Decision 2 reason)
- entries: 2, equal to the false-positive (C2) key-group count of the classification, 2
- entry keys: `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | env | [string]$key` and `... | env | $key`; neither belongs to a class T group
- every entry reason names the class route (scriptblock variable invoked from AfterEach) and carries no line number

## Leak-Scan Counts

- Raw findings (first scan): 71
- Fixed (class T): 2
- Allowlisted (class C2): 2
- Exempt (class C1, LASTEXITCODE): 67
