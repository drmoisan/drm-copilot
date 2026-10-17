# Final QA pass 1: PowerShell linting stage (P6-T2)

Timestamp: 2026-10-17T00-02
Command: sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1"
EXIT_CODE: 0
MCP_CALL: returned
MCP EXIT_CODE: 0
Output Summary: PSScriptAnalyzer with the repository settings (Error, Warning, Information): findings=0 for each of the seven files of LIST-PS-WRITTEN, PSSA-TOTAL: 0, EXIT_CODE_COMPUTED: 0. mcp__drm-copilot__run_poshqc_analyze (scan_folders scripts/ci, tests/scripts/ci) returned; no count is read from it (rule 5).

## CR-PSSA output

```
RUN-CR: cr-pssa
PSSA: scripts/ci/CiChangeScope.psm1 | findings=0
PSSA: scripts/ci/Invoke-CiChangeScope.ps1 | findings=0
PSSA: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | findings=0
PSSA: tests/scripts/ci/CiChangeScope.Tests.ps1 | findings=0
PSSA: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
```

## MCP call

`mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` <WORKSPACE_ROOT> and `scan_folders` `["scripts/ci", "tests/scripts/ci"]`: MCP_CALL: returned (ok=true).
