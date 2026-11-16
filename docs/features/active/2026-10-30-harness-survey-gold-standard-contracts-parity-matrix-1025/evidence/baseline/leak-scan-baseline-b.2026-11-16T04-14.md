# Leak Scan Baseline, Plan B (P0-T2)

Timestamp: 2026-11-16T04-14
Command: pwsh -NoProfile -File SCRATCH/issue-1025-leak.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: Leak scan: 863 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures. One configuration warning: the scan folder tests/powershell named in config/poshqc-scan.json does not exist and was skipped.

Findings: 78 (76 exempt, 2 allowlisted)
Failures: 0
