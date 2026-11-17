# Final Leak Scan (P4-T2)

Timestamp: 2026-11-16T03-29
Command: pwsh -NoProfile -File SCRATCH/issue-1025-leak.ps1 (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: Leak scan: 863 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures. Findings that fail the scan: 0 (baseline 0; the four new harness test files add no finding). The scan warned that the configured folder tests/powershell does not exist and skipped it.
