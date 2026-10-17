# Existing suites against the edited workflows (P4-T12)

Timestamp: 2026-10-16T23-55
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1" -NamePatternList "reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph,WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE*,WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS*,returns success when a check is skipping (skipping is non-blocking),returns pending for an empty check array with -RequireWorkflow CI,returns pending when the only CI checks are skipping"
EXIT_CODE: 0
Output Summary: All seven existing suites pass (TOTAL Passed=107 Failed=0, same count as the P0-T10 baseline). Edit-points record POSHQC-SHAPE: sharded and A2-APPLICABLE: no, so the A2 row shows Total=0 and WF02/WF03 each show Passed=1 Failed=0 Total=1 (A4 keeps the result-gate helper satisfied under the new step-level run-heavy gate). The three PATTERNS-PARSER rows each show Passed=1 Failed=0 Total=1. EXIT_CODE_COMPUTED: 0. CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Passed=30 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Passed=35 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Passed=2 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Passed=15 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
NAMED: reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph | Passed=0 | Failed=0 | Total=0
NAMED: WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE* | Passed=1 | Failed=0 | Total=1
NAMED: WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS* | Passed=1 | Failed=0 | Total=1
NAMED: returns success when a check is skipping (skipping is non-blocking) | Passed=1 | Failed=0 | Total=1
NAMED: returns pending for an empty check array with -RequireWorkflow CI | Passed=1 | Failed=0 | Total=1
NAMED: returns pending when the only CI checks are skipping | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=107 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
