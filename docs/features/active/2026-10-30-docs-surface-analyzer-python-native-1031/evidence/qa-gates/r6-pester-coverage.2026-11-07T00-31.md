# [P6-T8] Single-process Pester over tests/scripts with coverage

Timestamp: 2026-11-07T00-31
Command: branch-current Invoke-PoshQCTest with coverage over tests/scripts in a new PowerShell process (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths tests/scripts`); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: tests 16542, failures 0, errors 0, skipped 10, suites 611, in 1785.77 s. Overall line coverage 95.26% (32369/33979) from artifacts/pester/powershell-coverage.xml. No test fails, so no test is listed as pending CI.

## Named suites

| Suite | Tests | Failures | Errors |
|---|---|---|---|
| every test file under TESTS (102 suites) | 2136 | 0 | 0 |
| TESTS/DocsPythonTokens.Tests.ps1 | 58 | 0 | 0 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 35 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 |

## Failing tests pending CI

None.
