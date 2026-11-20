# Pass-after — W18 after the _security-scan.yml edit (P1-T4, RI-1b)

Timestamp: 2026-10-17T01-34
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"
EXIT_CODE: 0
Output Summary: Five containers Passed; CiChangeScopeWorkflow.Tests.ps1 Passed=39 Failed=0; NAMED *(AC-36)* Passed=1 Failed=0 Total=1; TOTAL Passed=73 Failed=0 (equals BASELINE-TOTAL-PASSED 73 from baseline-pester-workflows.2026-10-17T01-31.md); EXIT_CODE_COMPUTED: 0. Paired fail-before evidence: rem1-w18-expect-fail.2026-10-17T01-33.md (expected outcome recorded). CI job: poshqc / PowerShell QC (windows-latest).

## Output (host paths redacted; passing `ROW:` lines condensed to the AC-36 row)

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
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)
TOTAL: Passed=73 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
