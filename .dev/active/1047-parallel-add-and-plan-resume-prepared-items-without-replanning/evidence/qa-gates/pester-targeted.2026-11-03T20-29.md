# Targeted Pester Run (loop pass 3)

Timestamp: 2026-11-03T20-29
Task: [P6-T3]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-run-pester.ps1 -NoCoverage: Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/parallel-admission, tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1, tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1, tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1, tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1, tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 (branch-current PoshQC; coverage disabled for this targeted run); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: 11 suites, 936 tests, 0 failures, 0 errors. Covers M3 (Describe Invoke-ParallelAdmissionGitChecked; It surfaces the git stderr line when the branch cannot be listed), M1 (Usage errors reuse-edges rows; Describe reuse-edges; Integration It reuse-edges reuses the committed record for a matching plan hash; ParallelAdmission.Manifest.Tests.ps1), and M2 (Its documents the fetch side effect of assess and fetches origin once before reading the branch).

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 78 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 56 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 12 | 0 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 51 | 0 | 0 |
| tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | 7 | 0 | 0 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 33 | 0 | 0 |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 671 | 0 | 0 |
