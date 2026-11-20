# Fresh Single-Process Pester Run over tests/scripts (issue #1009)

Timestamp: 2026-10-30T19-04
Command: sh SCRATCH/issue-1009-full.sh single3 (one new PowerShell 7 process: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts; every suite runs in that single process, which is the CI shape; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: JUnit total=13329 passed=13319 failed=0 skipped=10 (tests completed in 758.99s). No order-dependent or leaked-state failure appeared with the five new suites in the same process as the existing suites. The 10 skipped tests are pre-existing skip conditions outside this change.
