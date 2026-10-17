# New-suite purity and size check, re-run (P1-T5)

Timestamp: 2026-10-16T23-42
Command: sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"
EXIT_CODE: 0
Output Summary: Re-run after the W-suite helper fix (AllowEmptyString on the line parameters and a renamed local variable in W10). HERMETIC-HITS: 0 and LINES-OVER-500: 0 (98, 323, 411, 323 lines). The edited W suite is also FORMAT-CLEAN and has PSSA findings=0 (micro-action checks). This artifact supersedes p1-test-hygiene.2026-10-16T23-39.md.

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

## Supplementary (W suite after the edit)

```
RUN-CR: cr-format
FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
RUN-CR: cr-pssa
PSSA: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
```
