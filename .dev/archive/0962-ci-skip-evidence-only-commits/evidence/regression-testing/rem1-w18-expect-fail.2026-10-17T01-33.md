# Expect-fail — new W18 row against the unchanged _security-scan.yml (P1-T2, RI-1b fail-before)

Timestamp: 2026-10-17T01-33
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure observed. CiChangeScopeWorkflow.Tests.ps1 Passed=38 Failed=1; NAMED *(AC-36)* Passed=0 Failed=1 Total=1; exactly one FAILED line, for the new W18 row, failing at line 321 (the job's continue-on-error lines joined are '' instead of '        continue-on-error: true'); the other four suites Failed=0; TOTAL Passed=72 Failed=1; EXIT_CODE_COMPUTED: 1. CI job: poshqc / PowerShell QC (windows-latest).

## Output (host paths redacted; passing `ROW:` lines condensed)

```text
RUN-CR: cr-pester-list
Starting discovery in 5 files.
Discovery found 73 tests in 208ms.
Running tests.
[-] issue #962 change-scope workflow gating.security scan.runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36) 47ms (47ms|1ms)
 at (@($job | Where-Object { $_ -match '^\s*continue-on-error:' }) -join ' | ') | Should -BeExactly '        continue-on-error: true' -Because 'only the scan step is non-blocking while the pre-existing safety findings remain (issue #962 PD-18)', <WORKSPACE_ROOT>/tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1:321
 at <ScriptBlock>, <WORKSPACE_ROOT>/tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1:321
 Expected strings to be the same, because only the scan step is non-blocking while the pre-existing safety findings remain (issue #962 PD-18), but they were different.
 Expected length: 31
 Actual length:   0
 Strings differ at index 0.
 Expected: '        continue-on-error: true'
 But was:  ''
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/CiWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
Tests Passed: 72, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Result=Failed
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=38 | Failed=1 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Passed=15 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-36)* | Passed=0 | Failed=1 | Total=1
FAILED: issue #962 change-scope workflow gating.security scan.runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36) :: Expected strings to be the same, because only the scan step is non-blocking while the pre-existing safety findings remain (issue #962 PD-18), but they were different. Expected length: 31 Actual length: 0 Strings differ at index 0. Expected: ' continue-on-error: true' But was: '' ^
TOTAL: Passed=72 | Failed=1 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 1
```
