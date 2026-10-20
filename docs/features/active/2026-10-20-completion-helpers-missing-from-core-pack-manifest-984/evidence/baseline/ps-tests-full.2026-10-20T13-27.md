# Baseline Full Single-Process Pester Run (Issue #984)

Timestamp: 2026-10-20T13-27
Command: sh SCRATCH/issue-984-run-full.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts -DisableKoverageCopy; then SCRATCH/issue-984-parse.ps1 over artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: 11320 test cases in one process: 11310 passed, 0 failed, 10 skipped. The pre-existing failure set is empty.

Counts from `artifacts/pester/pester-junit.xml`: total 11320, passed 11310, failed 0, skipped 10.

Pre-existing failing tests (full name and file): none.
