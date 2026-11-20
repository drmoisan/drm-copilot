# Baseline: Fresh Single-Process Pester Run over tests/scripts (Issue #973)

Timestamp: 2026-10-17T13-25
Command: sh SCRATCH/issue-973-run.sh issue-973-test.ps1 -Root <worktree> -ScanList tests/scripts (PowerShell 7; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts, one process), then sh SCRATCH/issue-973-run.sh issue-973-report.ps1 (reads artifacts/pester/pester-junit.xml)
EXIT_CODE: 0

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-25): 11223 test cases in 407 suites; 11213 passed, 0 failed, 10 skipped; no suite reported a container error. Discovery found 11223 tests at the start of the run, against the unchanged production and test files (Phase 1 files were not part of the discovered set).

Pre-existing failing set (compared by [P4-T8]): empty. No test failed.

Output Summary: 11213 passed, 0 failed, 10 skipped (11223 total). Pre-existing failure set: none.
