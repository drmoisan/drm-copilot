# New-suite purity and size check (P1-T5)

Timestamp: 2026-10-16T23-39
Command: sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"
EXIT_CODE: 0
Output Summary: HERMETIC-HITS: 0 and LINES-OVER-500: 0 for the four new suites (98, 323, 411, 323 lines). Supplementary micro-action checks on the same files: cr-format -Write reported FORMAT-CLEAN for all four (FORMAT-DRIFT-COUNT: 0, no file written) and cr-pssa reported PSSA-TOTAL: 0.

## Output

```
RUN-CR: cr-hermetic
LINES: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | 98
LINES: tests/scripts/ci/CiChangeScope.Tests.ps1 | 323
LINES: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | 411
LINES: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | 323
HERMETIC-HITS: 0
LINES-OVER-500: 0
EXIT_CODE_COMPUTED: 0
```

## Supplementary: cr-format -Write (EXIT_CODE: 0)

```
RUN-CR: cr-format
FORMAT-CLEAN: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1
FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```

## Supplementary: cr-pssa (EXIT_CODE: 0)

```
RUN-CR: cr-pssa
PSSA: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | findings=0
PSSA: tests/scripts/ci/CiChangeScope.Tests.ps1 | findings=0
PSSA: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | findings=0
PSSA: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
```
