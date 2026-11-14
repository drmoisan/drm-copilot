# Leak Scan Final (remediation cycle 2, issue #1118)

Timestamp: 2026-11-08T00-32
Command: sh SCRATCH/issue-1118-c2-static.sh (pwsh -NoProfile -File SCRATCH/issue-1118-leak.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <item worktree>), then pwsh -NoProfile -File SCRATCH/issue-1118-leak-files.ps1 (Get-PoshQCLeakFinding over each TESTDIR file; VERDICT(total -eq 0))
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCLeakScan: `Leak scan: 573 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.`; the scan throws on any failure, and it exited 0.
- Per-file findings for the eleven TESTDIR files: 0 each, TESTDIR_FINDINGS=0 (no finding for a TESTDIR file).
- `git diff --stat HEAD -- config/poshqc-leak-allowlist.json`: empty (no new allowlist entry).
- VERDICT: PASS.
