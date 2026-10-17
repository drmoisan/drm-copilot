# P7-T14 Proof step P3 edit and its local QA

Timestamp: 2026-10-17T03-10
Command: git diff --numstat HEAD -- scripts/ci/CiChangeScope.psm1 ; sh SCRATCH/tools/run-cr.sh cr-format -PathList scripts/ci/CiChangeScope.psm1 ; sh SCRATCH/tools/run-cr.sh cr-pssa -PathList scripts/ci/CiChangeScope.psm1 ; sh SCRATCH/tools/run-cr.sh cr-structure ; sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList tests/scripts/ci/CiChangeScope.Tests.ps1
EXIT_CODE: 0
Output Summary: See verbatim output: numstat, CR-FORMAT, CR-PSSA, CR-STRUCTURE, and the CiChangeScope suite after appending the PD-11 line. Launcher path written as SCRATCH/tools/run-cr.sh per rule 2.


## `git diff --numstat HEAD -- scripts/ci/CiChangeScope.psm1`

exit: 0

```text
1	0	scripts/ci/CiChangeScope.psm1
```

## `sh SCRATCH/tools/run-cr.sh cr-format -PathList scripts/ci/CiChangeScope.psm1`

exit: 0

```text
RUN-CR: cr-format
FORMAT-CLEAN: scripts/ci/CiChangeScope.psm1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```

## `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList scripts/ci/CiChangeScope.psm1`

exit: 0

```text
RUN-CR: cr-pssa
PSSA: scripts/ci/CiChangeScope.psm1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
```

## `sh SCRATCH/tools/run-cr.sh cr-structure`

exit: 0

```text
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

## `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList tests/scripts/ci/CiChangeScope.Tests.ps1`

exit: 0

```text
RUN-CR: cr-pester-list

Starting discovery in 1 files.
Discovery found 54 tests in 233ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\ci\CiChangeScope.Tests.ps1 1.2s (433ms|566ms)
Tests completed in 1.23s
Tests Passed: 54, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER: tests/scripts/ci/CiChangeScope.Tests.ps1 | Result=Passed
SUITE: tests/scripts/ci/CiChangeScope.Tests.ps1 | Passed=54 | Failed=0 | Skipped=0 | NotRun=0
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for merge_group (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for push (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for workflow_dispatch (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns nothing for a same-repository pull_request (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a different head repository (AC-2)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a blank head repository (AC-2)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig parses a valid config and lower-cases the extensions (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects malformed JSON (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects empty text (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects version 2 (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects missing include_prefixes (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects empty include_prefixes (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects extension without a dot (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/a.md (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/completed/x/evidence/b.txt (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/potential/x/c.log (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/research/d.json (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/e.xml (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/RUN.MD (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/templates/README.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/potential/template.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/engineering/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/discovery/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.ps1 (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.py (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.yml (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/../../scripts/a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs\features\active\x\a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects /docs/features/active/a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects Docs/features/active/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects config/ci-docs-only-paths.json (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/noextension (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList splits a NUL-terminated list (AC-8)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList returns an empty valid list for empty text (AC-9)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList marks text without a trailing NUL invalid (AC-8)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision returns EMPTY_DIFF for no paths (AC-9)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision names the first non-allowlisted path of a mixed set (AC-10)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision returns nothing when every path is allowlisted (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes the current run (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes runs from a foreign head repository (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates orders unsorted runs by run_number descending (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes runs whose conclusion is not success (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID for malformed JSON (AC-3)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID when workflow_runs is missing (AC-3)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns true when CI full run concluded success (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded skipped (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded failure (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded cancelled (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when no CI full run job exists (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker throws CI_JOB_LIST_INVALID for malformed JSON (AC-4)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision renders code=false with the DOCS_ONLY_SINCE reason and base (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision renders code=true with base none (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision throws when code is false without a DOCS_ONLY_SINCE reason (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | CiChangeScope.psm1 defines only the eight pure functions and calls no git, gh, file, or network command (AC-17)
TOTAL: Passed=54 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
