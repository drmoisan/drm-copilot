# Pester Seeded Shuffled File-Order Runs (remediation cycle 1, loop pass 2)

Timestamp: 2026-11-03T19-57
Task: [P6-T4]
Command: for each seed, SCRATCH/issue-1047-seed-order.ps1 -Seed <seed> (Fisher-Yates shuffle with System.Random(<seed>) over the six suites under tests/scripts/claude-lib/parallel-admission/, sorted by name first), then one sh-launched PowerShell 7 process running Invoke-PoshQCTest -ScanFolders <shuffled list> with an order-preserving -ResolveScanFolders seam and coverage disabled; counts and executed order read from artifacts/pester/pester-junit.xml (testsuite id order)
EXIT_CODE: 0
Output Summary: seeds 11, 23, and 47 each ran 214 tests in one process with 0 failures and 0 errors, and in every run the JUnit testsuite id order equals the seeded file order.

## Seed 11 (214 tests, 0 failures, 0 errors)

| Executed position | File | Tests | Failures |
| --- | --- | --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 |
| 1 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 |
| 2 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 3 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 78 | 0 |
| 4 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 5 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |

## Seed 23 (214 tests, 0 failures, 0 errors)

| Executed position | File | Tests | Failures |
| --- | --- | --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 1 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 2 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 78 | 0 |
| 3 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 |
| 4 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |
| 5 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 |

## Seed 47 (214 tests, 0 failures, 0 errors)

| Executed position | File | Tests | Failures |
| --- | --- | --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 |
| 1 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 2 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 3 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |
| 4 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 |
| 5 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 78 | 0 |
