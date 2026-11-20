# scripts/ci structure and purity (P3-T3, AC-17)

Timestamp: 2026-10-16T23-50
Command: sh SCRATCH/tools/run-cr.sh cr-structure
EXIT_CODE: 0
Second command: sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"
Second EXIT_CODE: 0
Output Summary: CR-STRUCTURE: the module defines exactly the eight functions, with no banned commands, no & invocation, and no IO/Net/Diagnostics types; the entry script declares the three seams and the dot-source guard; scripts/ci and tests/scripts/ci hold only PowerShell files; EXIT_CODE_COMPUTED: 0. CR-HERMETIC: HERMETIC-HITS: 0, LINES-OVER-500: 0 (module 345, entry script 271 lines).

## cr-structure output

```
RUN-CR: cr-structure
STRUCT-MODULE-PARSE-ERRORS: 0
STRUCT-MODULE-FUNCTIONS: ConvertFrom-CiDocsOnlyPathConfig,ConvertFrom-CiNulPathList,Get-CiChangeScopePathDecision,New-CiChangeScopeDecision,Select-CiGreenBaseCandidates,Test-CiChangeScopeEventEligible,Test-CiDocsOnlyPath,Test-CiFullRunMarker
STRUCT-MODULE-FUNCTIONS-MATCH: True
STRUCT-MODULE-BANNED-COMMANDS: 0
STRUCT-MODULE-INVOCATION-OPERATORS: 0
STRUCT-MODULE-IO-TYPES: 0
STRUCT-ENTRY-PARSE-ERRORS: 0
STRUCT-ENTRY-SEAMS: 3
STRUCT-ENTRY-GUARD: True
STRUCT-NON-POWERSHELL-FILES: 0
EXIT_CODE_COMPUTED: 0
```

## cr-hermetic output

```
RUN-CR: cr-hermetic
LINES: scripts/ci/CiChangeScope.psm1 | 345
LINES: scripts/ci/Invoke-CiChangeScope.ps1 | 271
LINES: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | 98
LINES: tests/scripts/ci/CiChangeScope.Tests.ps1 | 323
LINES: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | 411
LINES: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | 323
HERMETIC-HITS: 0
LINES-OVER-500: 0
EXIT_CODE_COMPUTED: 0
```
