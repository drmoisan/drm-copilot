# Targeted Pester Run (remediation cycle 3, loop pass 1)

Timestamp: 2026-11-03T22-44
Task: [P2-T3]
Command: sh SCRATCH/issue-1047-pester.sh SCRATCH/issue-1047-c3-p2t3.log -NoCoverage -ScanFolders tests/scripts/claude-lib/parallel-admission,tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (one PowerShell 7 process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest); counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: JUnit: 8 suites, 232 tests, 0 failures, 0 errors, 0 skipped. The six rows of It `takes the receipt base commit only when it is a full object name: <Case>` (40-char lowercase hex, 64-char uppercase hex, option-shaped, short hex, 40-char non-hex, empty) are each status Passed. Invoke-ParallelAdmission.Tests.ps1 has 85 tests (81 in cycle 2: two Its removed, six rows added).

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 85 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 | 0 |

## Discrimination check

Before this run, the B1 condition was restored temporarily to the previous `IsNullOrWhiteSpace` test and `Invoke-ParallelAdmission.Tests.ps1` was run alone (SCRATCH/issue-1047-c3-mutant.log): 85 tests, 3 failures, namely the option-shaped, short hex, and 40-char non-hex rows. The empty row passes under both conditions because both treat an empty value as absent. The fixed script was then restored and its SHA256 (fd25cf532c7c0de8b33e21f1dcb055d9625d4760c3df77d50c3d9ecbef418f3b) re-checked before this run.
