# Baseline Pester — workflow suites (P0-T4)

Timestamp: 2026-10-17T01-31
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"
EXIT_CODE: 0
Output Summary: TOTAL: Passed=73 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
Five containers Passed; CiChangeScopeWorkflow.Tests.ps1 Passed=39 Failed=0; NAMED *(AC-36)* Passed=1 Failed=0 Total=1; EXIT_CODE_COMPUTED: 0. CI job: poshqc / PowerShell QC (windows-latest).
BASELINE-TOTAL-PASSED: 73

## Output (host paths redacted; the 73 `ROW:` lines all report `Passed` and are condensed to the AC-36 row)

```text
RUN-CR: cr-pester-list
Starting discovery in 5 files.
Discovery found 73 tests in 214ms.
Running tests.
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/CiWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
[+] <WORKSPACE_ROOT>/tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
Tests Passed: 73, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Passed=15 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | runs the security scan under bash after installing the Poetry export plugin and without continue-on-error (AC-36)
TOTAL: Passed=73 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
