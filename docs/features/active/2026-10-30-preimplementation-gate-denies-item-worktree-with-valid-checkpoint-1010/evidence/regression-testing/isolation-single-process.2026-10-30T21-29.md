# Isolation: Fresh Single-Process Pester Run Over tests/scripts (Issue #1010, P5-T9)

Timestamp: 2026-10-30T21-17
Command: sh SCRATCH/issue-1010-full.sh (a fresh PowerShell 7 process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts in one process, Run.Exit off, coverage disabled; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: 473 test files in one process (2026-10-30T21-17 to 2026-10-30T21-29 UTC). JUnit total 13397, passed 13387, failed 0, errors 0, skipped 10. The 10 skipped tests are pre-existing skip conditions in suites this plan does not touch; no failure was reported.
