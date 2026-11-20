# Baseline format state of the existing suites (P0-T13)

Timestamp: 2026-10-16T23-27
Command: sh SCRATCH/tools/run-cr.sh cr-format -PathList "tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1"
EXIT_CODE: 0
Output Summary: Read-only check. All seven existing suites are FORMAT-CLEAN; FORMAT-DRIFT-COUNT: 0.

## Output

```
RUN-CR: cr-format
FORMAT-CLEAN: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1
FORMAT-CLEAN: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
FORMAT-CLEAN: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/CiWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```
