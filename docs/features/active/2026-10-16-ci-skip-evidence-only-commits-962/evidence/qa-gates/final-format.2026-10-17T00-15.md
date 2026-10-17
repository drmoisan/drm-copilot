# Final QA pass 2 (after rule 17 re-integration): PowerShell formatting stage (P6-T1)

Timestamp: 2026-10-17T00-15
Command: sh SCRATCH/tools/run-cr.sh cr-format -PathList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1" -Write
EXIT_CODE: 0
MCP_CALL: returned
MCP EXIT_CODE: 0
Output Summary: LIST-PS-WRITTEN now has eight files (LIST-EDITED-SUITES includes CiWorkflow.Tests.ps1 after A2). CR-FORMAT in write mode: FORMAT-CLEAN for all eight, FORMAT-DRIFT-COUNT: 0, no FORMAT-WRITTEN line. mcp__drm-copilot__run_poshqc_format (scan_folders scripts/ci, tests/scripts/ci) returned; git status --porcelain and git diff --numstat HEAD are identical before and after the call. No loop restart.

## CR-FORMAT output

```
RUN-CR: cr-format
FORMAT-CLEAN: scripts/ci/CiChangeScope.psm1
FORMAT-CLEAN: scripts/ci/Invoke-CiChangeScope.ps1
FORMAT-CLEAN: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/CiWorkflow.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```

## MCP call

`mcp__drm-copilot__run_poshqc_format` with `workspace_root` <WORKSPACE_ROOT> and `scan_folders` `["scripts/ci", "tests/scripts/ci"]`: MCP_CALL: returned (ok=true).

## Tree observation before and after the MCP call (identical)

`git status --porcelain` (before and after):

```
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes.2026-10-16T23-15.md
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
 M tests/scripts/workflows/CiWorkflow.Tests.ps1
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/commit-phase-5.2026-10-17T00-00.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/dependency-state.2026-10-17T00-09.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/edit-points.2026-10-17T00-09.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/reintegration.2026-10-17T00-09.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/workflow-suite-adjustment.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-actionlint.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-ci-suite-edit.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-existing-suites.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-onblock.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-poshqc-suite-edit.2026-10-17T00-12.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-workflow-suite-pass.2026-10-17T00-12.md
```

`git diff --numstat HEAD` (before and after):

```
24	0	docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes.2026-10-16T23-15.md
4	4	docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
16	1	tests/scripts/workflows/CiWorkflow.Tests.ps1
```
