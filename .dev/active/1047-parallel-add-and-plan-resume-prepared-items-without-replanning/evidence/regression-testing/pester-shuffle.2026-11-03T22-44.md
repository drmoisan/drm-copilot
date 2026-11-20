# Pester Seeded Shuffle (remediation cycle 3, loop pass 1)

Timestamp: 2026-11-03T22-44
Task: [P2-T4]
Command: sh SCRATCH/issue-1047-c3-shuffle.sh: for seeds 11, 23, 47, SCRATCH/issue-1047-seed-order.ps1 shuffles the six `tests/scripts/claude-lib/parallel-admission/*.Tests.ps1` files (name-sorted, Fisher-Yates with System.Random(seed)); then one PowerShell 7 process calls Invoke-PoshQCTest -ScanFolders <seeded order> with coverage disabled and the order-preserving -ResolveScanFolders seam; counts and testsuite order read from artifacts/pester/pester-junit.xml after each run
EXIT_CODE: 0
Output Summary: each seed: 6 suites, 221 tests, 0 failures, 0 errors (RUN_EXIT=0). The JUnit testsuite order equals the seeded order for all three seeds.

Prefix `tests/scripts/claude-lib/parallel-admission/` is omitted below.

| Seed | Seeded order = JUnit testsuite order | Tests | Failures | Errors |
| --- | --- | --- | --- | --- |
| 11 | ParallelAdmission.Tests.ps1, ParallelAdmissionJson.Tests.ps1, ParallelAdmissionPrecedence.Tests.ps1, Invoke-ParallelAdmission.Tests.ps1, Invoke-ParallelAdmission.Integration.Tests.ps1, ParallelAdmission.Manifest.Tests.ps1 | 221 | 0 | 0 |
| 23 | Invoke-ParallelAdmission.Integration.Tests.ps1, ParallelAdmissionPrecedence.Tests.ps1, Invoke-ParallelAdmission.Tests.ps1, ParallelAdmission.Tests.ps1, ParallelAdmission.Manifest.Tests.ps1, ParallelAdmissionJson.Tests.ps1 | 221 | 0 | 0 |
| 47 | ParallelAdmissionJson.Tests.ps1, Invoke-ParallelAdmission.Integration.Tests.ps1, ParallelAdmissionPrecedence.Tests.ps1, ParallelAdmission.Manifest.Tests.ps1, ParallelAdmission.Tests.ps1, Invoke-ParallelAdmission.Tests.ps1 | 221 | 0 | 0 |
