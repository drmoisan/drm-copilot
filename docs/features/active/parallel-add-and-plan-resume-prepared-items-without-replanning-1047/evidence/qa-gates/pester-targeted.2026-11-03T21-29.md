# Targeted Pester Gate (remediation cycle 2, loop pass 1)

Timestamp: 2026-11-03T21-29
Task: [P3-T3]
Command: sh SCRATCH/issue-1047-pester.sh (PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1, Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/parallel-admission,tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1, coverage disabled); counts read from artifacts/pester/pester-junit.xml by SCRATCH/issue-1047-read-results.ps1
EXIT_CODE: 0
Output Summary: 8 suites, 228 tests, 0 failures, 0 errors, 0 skipped (JUnit). It `exits 2 on <Subcommand> <Name> <Value>` passed for all six rows.

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 81 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 | 0 |

## It `exits 2 on <Subcommand> <Name> <Value>` (JUnit testcase status)

| Row | Status |
| --- | --- |
| exits 2 on reuse-edges -IssueNum 0 | Passed |
| exits 2 on reuse-edges -IssueNum x1 | Passed |
| exits 2 on reuse-edges -Slug a/b | Passed |
| exits 2 on assess -Branch --upload-pack=x | Passed |
| exits 2 on assess -Main --output=x | Passed |
| exits 2 on reuse-edges -Ref -p | Passed |
