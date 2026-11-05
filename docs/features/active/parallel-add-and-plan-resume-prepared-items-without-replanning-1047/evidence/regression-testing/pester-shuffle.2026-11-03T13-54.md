# Pester Seeded Shuffled File-Order Runs (loop pass 2)

Timestamp: 2026-11-03T13-54
Task: [P8-T10]
Command: for each seed, SCRATCH/issue-1047-seed-order.ps1 -Seed <seed> (Fisher-Yates shuffle with System.Random(<seed>) over the six touched suites), then one sh-launched PowerShell 7 process running Invoke-PoshQCTest -ScanFolders <shuffled list> with an order-preserving -ResolveScanFolders seam; counts and the executed suite order read from artifacts/pester/pester-junit.xml (testsuite id order)
EXIT_CODE: 0
Output Summary: Loop pass 2 after the ParallelAdmissionPrecedence.psm1 change. Seeds 11, 23, and 47 each ran 242 tests in one process with 0 failures and 0 errors, and the JUnit testsuite id order equals the seeded file order in every run.

Method note: Invoke-PoshQCTest resolves -ScanFolders through Resolve-PoshQCScanFolder, which returns the folders sorted (Sort-Object -Unique). A first set of runs at 2026-11-03T13-44 therefore executed the files in alphabetical order whatever the seed; those runs are not counted here. The runs below pass the documented ResolveScanFolders seam of Invoke-PoshQCTest with an order-preserving resolver, so Pester receives Run.Path in the seeded order, and the JUnit ids confirm it.

## Seed 11 (242 tests, 0 failures)

| Executed position | File |
| --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 |
| 1 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 |
| 2 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 |
| 3 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 |
| 4 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 |
| 5 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 |

## Seed 23 (242 tests, 0 failures)

| Executed position | File |
| --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 |
| 1 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 |
| 2 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 |
| 3 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 |
| 4 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 |
| 5 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 |

## Seed 47 (242 tests, 0 failures)

| Executed position | File |
| --- | --- |
| 0 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 |
| 1 | tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 |
| 2 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 |
| 3 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 |
| 4 | tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 |
| 5 | tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 |
