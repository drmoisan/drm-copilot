# Final QA pass 2: structure, purity, and shell recheck (P6-T11; AC-17, rule 18)

Timestamp: 2026-10-17T00-21
Command: sh SCRATCH/tools/run-cr.sh cr-structure
EXIT_CODE: 0
Second command: sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1"
Second EXIT_CODE: 0
Third command: sh SCRATCH/tools/run-cr.sh cr-shell-static
Third EXIT_CODE: 0
Output Summary: CR-STRUCTURE success literals all hold (eight module functions, no banned commands, no & invocation, no IO types, three seams, dot-source guard, no non-PowerShell files under scripts/ci or tests/scripts/ci). CR-HERMETIC: one LINES line per file of LIST-PS-WRITTEN (8 files, largest 411 lines), HERMETIC-HITS: 0, LINES-OVER-500: 0. CR-SHELL-STATIC success literals all hold (SHELL-RECURSIVE-INVOCATIONS: 2, threshold function and wiring present, 432/106/265 lines, no CRLF); local shellcheck and shfmt -d both exit 0 (-LintInformational not used). All three EXIT_CODE_COMPUTED: 0.

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
LINES: tests/scripts/workflows/CiWorkflow.Tests.ps1 | 255
LINES: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | 217
HERMETIC-HITS: 0
LINES-OVER-500: 0
EXIT_CODE_COMPUTED: 0
```

## cr-shell-static output

```
RUN-CR: cr-shell-static
SHELL-LINES: scripts/bash/shell_qc_lib.sh | 432
SHELL-LINES: scripts/bash/shell-qc.sh | 106
SHELL-LINES: tests/shell/test_shell_qc_commands.bats | 265
SHELL-RECURSIVE-INVOCATIONS: 2
SHELL-NONRECURSIVE-INVOCATIONS: 0
SHELL-THRESHOLD-FUNCTION: 1
SHELL-THRESHOLD-WIRING: 1
SHELL-THRESHOLD-DEFAULT-85: 1
SHELL-USAGE-THRESHOLD-LINE: 1
SHELL-NOUNSET-ASSERTIONS-UPDATED: 2
SHELL-NEW-TESTS-MISSING: 0
SHELL-NESTED-FILE: helpers/codex_web_setup_common.bash
SHELL-NESTED-BATS-FILES: 0
SHELL-TESTS-BASH-DIR-EXISTS: False
SHELL-LINES-OVER-500: 0
SHELL-CRLF-FILES: 0
SHELLCHECK-EXIT: 0
SHFMT-EXIT: 0
SHELL-LOCAL-LINT: ran=2 | failing=0 | informational=False
EXIT_CODE_COMPUTED: 0
```
