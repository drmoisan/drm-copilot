# Final QA pass 1: unit-test stage, counts (P6-T5; AC-26, AC-28)

Timestamp: 2026-10-17T00-02
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1" -NamePatternList "*(AC-1)*,*(AC-2)*,*(AC-3)*,*(AC-4)*,*(AC-5)*,*(AC-6)*,*(AC-7)*,*(AC-8)*,*(AC-9)*,*(AC-10)*,*(AC-11)*,*(AC-12)*,*(AC-13)*,*(AC-14)*,*(AC-15)*,*(AC-16)*,*(AC-17)*,*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*,returns success when a check is skipping (skipping is non-blocking),returns pending for an empty check array with -RequireWorkflow CI,returns pending when the only CI checks are skipping"
EXIT_CODE: 0
Output Summary: One invocation over LIST-NEW-TESTS and LIST-EXISTING-SUITES (11 containers, all Result=Passed): TOTAL Passed=253 Failed=0 (146 new rows + 107 existing rows). Every AC NAMED line shows Failed=0 with its section 8 total; the three PATTERNS-PARSER rows (Invoke-CiGateParser.Tests.ps1, unchanged) each show Passed=1 Failed=0 Total=1. EXIT_CODE_COMPUTED: 0. CI job: poshqc / PowerShell QC (windows-latest).

AC-28 test names recorded: `returns success when a check is skipping (skipping is non-blocking)` (skipping is non-blocking), `returns pending for an empty check array with -RequireWorkflow CI` (the -RequireWorkflow empty-set refusal), and `returns pending when the only CI checks are skipping`.

## Output (summary lines; the per-row ROW lines are in the same run and all read Passed)

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/ci/CiChangeScope.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/ci/CiChangeScope.Tests.ps1 | Passed=54 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Passed=23 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | Passed=30 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Passed=30 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Passed=35 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Passed=2 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Passed=15 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-1)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-2)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-3)* | Passed=4 | Failed=0 | Total=4
NAMED: *(AC-4)* | Passed=2 | Failed=0 | Total=2
NAMED: *(AC-5)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-6)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-7)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-8)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-9)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-10)* | Passed=2 | Failed=0 | Total=2
NAMED: *(AC-11)* | Passed=7 | Failed=0 | Total=7
NAMED: *(AC-12)* | Passed=6 | Failed=0 | Total=6
NAMED: *(AC-13)* | Passed=13 | Failed=0 | Total=13
NAMED: *(AC-14)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-15)* | Passed=24 | Failed=0 | Total=24
NAMED: *(AC-16)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-17)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-18)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-19)* | Passed=9 | Failed=0 | Total=9
NAMED: *(AC-20)* | Passed=21 | Failed=0 | Total=21
NAMED: *(AC-21)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
NAMED: returns success when a check is skipping (skipping is non-blocking) | Passed=1 | Failed=0 | Total=1
NAMED: returns pending for an empty check array with -RequireWorkflow CI | Passed=1 | Failed=0 | Total=1
NAMED: returns pending when the only CI checks are skipping | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=253 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
