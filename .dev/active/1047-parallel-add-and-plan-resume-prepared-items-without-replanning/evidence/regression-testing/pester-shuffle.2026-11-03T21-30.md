# Seeded Shuffled Pester File Order (remediation cycle 2, loop pass 1)

Timestamp: 2026-11-03T21-30
Task: [P3-T4]
Command: sh SCRATCH/issue-1047-c2-shuffle.sh: for seeds 11, 23, and 47, SCRATCH/issue-1047-seed-order.ps1 (System.Random(seed) Fisher-Yates over the six name-sorted suites under tests/scripts/claude-lib/parallel-admission) gives the file order; one PowerShell 7 process per seed runs Invoke-PoshQCTest -ScanFolders <seeded order> with the order-preserving -ResolveScanFolders seam (returns the folders unchanged) and coverage disabled; the executed order and counts are read from the testsuite elements of artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: every seed: 6 suites, 217 tests, 0 failures, 0 errors; the JUnit testsuite order equals the seeded order for all three seeds.

All paths below are under `tests/scripts/claude-lib/parallel-admission/`.

## Seed 11

| Position | Seeded order | JUnit testsuite order | Tests | Failures |
| --- | --- | --- | --- | --- |
| 1 | ParallelAdmission.Tests.ps1 | ParallelAdmission.Tests.ps1 | 56 | 0 |
| 2 | ParallelAdmissionJson.Tests.ps1 | ParallelAdmissionJson.Tests.ps1 | 12 | 0 |
| 3 | ParallelAdmissionPrecedence.Tests.ps1 | ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 4 | Invoke-ParallelAdmission.Tests.ps1 | Invoke-ParallelAdmission.Tests.ps1 | 81 | 0 |
| 5 | Invoke-ParallelAdmission.Integration.Tests.ps1 | Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 6 | ParallelAdmission.Manifest.Tests.ps1 | ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |

## Seed 23

| Position | Seeded order | JUnit testsuite order | Tests | Failures |
| --- | --- | --- | --- | --- |
| 1 | Invoke-ParallelAdmission.Integration.Tests.ps1 | Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 2 | ParallelAdmissionPrecedence.Tests.ps1 | ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 3 | Invoke-ParallelAdmission.Tests.ps1 | Invoke-ParallelAdmission.Tests.ps1 | 81 | 0 |
| 4 | ParallelAdmission.Tests.ps1 | ParallelAdmission.Tests.ps1 | 56 | 0 |
| 5 | ParallelAdmission.Manifest.Tests.ps1 | ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |
| 6 | ParallelAdmissionJson.Tests.ps1 | ParallelAdmissionJson.Tests.ps1 | 12 | 0 |

## Seed 47

| Position | Seeded order | JUnit testsuite order | Tests | Failures |
| --- | --- | --- | --- | --- |
| 1 | ParallelAdmissionJson.Tests.ps1 | ParallelAdmissionJson.Tests.ps1 | 12 | 0 |
| 2 | Invoke-ParallelAdmission.Integration.Tests.ps1 | Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 |
| 3 | ParallelAdmissionPrecedence.Tests.ps1 | ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 |
| 4 | ParallelAdmission.Manifest.Tests.ps1 | ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 |
| 5 | ParallelAdmission.Tests.ps1 | ParallelAdmission.Tests.ps1 | 56 | 0 |
| 6 | Invoke-ParallelAdmission.Tests.ps1 | Invoke-ParallelAdmission.Tests.ps1 | 81 | 0 |
