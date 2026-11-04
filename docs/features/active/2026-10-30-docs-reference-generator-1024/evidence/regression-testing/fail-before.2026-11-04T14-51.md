# Fail-Before: Narrowed Front-Matter Serializer Fallback (issue 1024, remediation cycle 1)

Timestamp: 2026-11-04T14-51
Task: [P1-T2] [expect-fail]
Command: sh SCRATCH/issue-1024-pester-fm.sh (PowerShell 7 script SCRATCH/issue-1024-pester.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1), then sh SCRATCH/issue-1024-report.sh reading artifacts/pester/pester-junit.xml
EXIT_CODE: 7
ExpectedExitCode: 7
Output Summary: Production module unchanged (still the try/catch fallback). JUnit: total 31, passed 24, failed 7, errors 0. The failed set equals the seven test cases added in [P1-T1]; every pre-existing test in the file passes.

## Failed test cases (from artifacts/pester/pester-junit.xml)

1. `ConvertTo-DocsReferenceFrontMatterText.routes a non-integral extension number to the JSON writer without calling the canonical serializer` (canonical mock called 1 time, expected 0)
2. `ConvertTo-DocsReferenceFrontMatterText.routes an extension number above the safe-integer bound to the JSON writer` (canonical mock called 1 time, expected 0)
3. `ConvertTo-DocsReferenceFrontMatterText.propagates an unrelated canonical serializer failure without calling the JSON writer` (no exception thrown; the catch swallowed it)
4. `ConvertTo-DocsReferenceFrontMatterText.propagates a canonical serializer failure for an extensions value with only integral numbers` (no exception thrown)
5. `ConvertTo-DocsReferenceFrontMatterText.propagates the canonical rejection of a non-integral number outside extensions` (no exception thrown)
6. `ConvertTo-DocsReferenceFrontMatterText.routes a non-integral number nested in an extensions array to the JSON writer` (canonical mock called 1 time, expected 0)
7. `ConvertTo-DocsReferenceFrontMatterText.routes a non-integral number nested in an extensions object to the JSON writer` (canonical mock called 1 time, expected 0)

The launcher exit code 7 equals the Pester failed count propagated by the run; the report step was then run separately against the same JUnit file.
