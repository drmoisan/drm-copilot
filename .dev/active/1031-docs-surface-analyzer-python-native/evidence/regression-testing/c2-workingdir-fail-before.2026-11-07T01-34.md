# [P1-T1] Working-directory test fails before the fix

Timestamp: 2026-11-07T01-34
Command: branch-current Invoke-PoshQCTest over TESTS/Invoke-DocsCommand.Tests.ps1 (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 -NoCoverage`); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: tests 48, failures 1, errors 0, skipped 0. The single failure is the new case, as expected before the fix.

## Failed test

`InvokeProcess member and process functions.runs Invoke-DocsProcess with the context repository root as the working directory`

Every other case in the suite passes (47 passed). The case fails because the member passes no working directory to `Invoke-DocsProcess`.
