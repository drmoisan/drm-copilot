# Final QA pass 1: PowerShell formatting stage (P6-T1)

Timestamp: 2026-10-17T00-02
Command: sh SCRATCH/tools/run-cr.sh cr-format -PathList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1" -Write
EXIT_CODE: 0
MCP_CALL: returned
MCP EXIT_CODE: 0
Output Summary: CR-FORMAT in write mode over LIST-PS-WRITTEN (six new files plus the A4-edited PoshQcWorkflow.Tests.ps1): FORMAT-CLEAN for all seven, FORMAT-DRIFT-COUNT: 0, no FORMAT-WRITTEN line. mcp__drm-copilot__run_poshqc_format (workspace_root <WORKSPACE_ROOT>, scan_folders scripts/ci and tests/scripts/ci) returned; git status --porcelain and git diff --numstat HEAD are identical before and after the call, so the MCP stage formatted no file. No loop restart.

## CR-FORMAT output

```
RUN-CR: cr-format
FORMAT-CLEAN: scripts/ci/CiChangeScope.psm1
FORMAT-CLEAN: scripts/ci/Invoke-CiChangeScope.ps1
FORMAT-CLEAN: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```

## MCP call

`mcp__drm-copilot__run_poshqc_format` with `workspace_root` = output of `git rev-parse --show-toplevel` (<WORKSPACE_ROOT>) and `scan_folders` `["scripts/ci", "tests/scripts/ci"]`: MCP_CALL: returned (ok=true). No count or finding is read from the result (rule 5).

## Tree observation before the MCP call

`git status --porcelain`:

```
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/commit-phase-5.2026-10-17T00-00.md
```

`git diff --numstat HEAD`:

```
1	1	docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
```

## Tree observation after the MCP call

`git status --porcelain`:

```
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/commit-phase-5.2026-10-17T00-00.md
```

`git diff --numstat HEAD`:

```
1	1	docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
```
