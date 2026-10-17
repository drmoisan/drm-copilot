# Unit-test stage — workflow suites (P2-T4)

Timestamp: 2026-10-17T01-37
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*"
EXIT_CODE: 0
Output Summary: Five containers Passed; CiChangeScopeWorkflow.Tests.ps1 Passed=39 Failed=0; NAMED Totals 5, 9, 21, 3, 1 (AC-18, AC-19, AC-20, AC-21, AC-36), each Failed=0; TOTAL Passed=73 Failed=0 (equals BASELINE-TOTAL-PASSED 73); EXIT_CODE_COMPUTED: 0. CI job: poshqc / PowerShell QC (windows-latest).

## Output (host paths redacted; the 73 passing `ROW:` lines condensed)

```text
RUN-CR: cr-pester-list
Discovery found 73 tests in 207ms.
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
NAMED: *(AC-18)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-19)* | Passed=9 | Failed=0 | Total=9
NAMED: *(AC-20)* | Passed=21 | Failed=0 | Total=21
NAMED: *(AC-21)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=73 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
