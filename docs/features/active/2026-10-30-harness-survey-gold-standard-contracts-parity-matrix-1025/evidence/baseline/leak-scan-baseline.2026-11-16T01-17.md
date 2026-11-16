# Leak Scan Baseline (P0-T3)

Timestamp: 2026-11-16T01-17
Command: pwsh -NoProfile -File SCRATCH/issue-1025-leak.ps1 (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: Leak scan: 859 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures. Finding count that fails the scan: 0. The scan warned that the configured folder tests/powershell does not exist and skipped it.
