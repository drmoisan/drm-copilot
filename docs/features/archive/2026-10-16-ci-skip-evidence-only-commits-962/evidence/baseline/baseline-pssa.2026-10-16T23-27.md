# Baseline analyzer state of the existing suites (P0-T14)

Timestamp: 2026-10-16T23-27
Command: sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1"
EXIT_CODE: 0
Output Summary: All seven existing suites have findings=0; PSSA-TOTAL: 0.

## Output

```
RUN-CR: cr-pssa
PSSA: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | findings=0
PSSA: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | findings=0
PSSA: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/CiWorkflow.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
```
