# Final Leak Scan, Plan B (P2-T2)

Timestamp: 2026-11-16T05-10
Command: pwsh -NoProfile -File SCRATCH/issue-1025-leak.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: Leak scan: 863 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (same as leak-scan-baseline-b). One configuration warning: the scan folder tests/powershell named in config/poshqc-scan.json does not exist and was skipped.

Findings: 0 (0 failures; the 78 raw findings are all exempt or allowlisted)
Failures: 0
