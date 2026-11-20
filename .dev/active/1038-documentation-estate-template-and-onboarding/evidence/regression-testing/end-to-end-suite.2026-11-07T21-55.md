# End-to-end suite result (from the parallel Pester gate)

Timestamp: 2026-11-07T21-55
Command: Invoke-PoshQCParallelTest -Root <worktree> through sh SCRATCH/issue-1038-pester-parallel.sh (the [P4-T3] run); counts read from the testsuite element of tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1 in the merged artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: EndToEndDocumentationEstate.Tests.ps1: 10 passed, 0 failed, 0 skipped (at least ten required).

Owner-directive substitution (owner directive 2026-11-07, decision 1): [P3-T7] names a single-process Pester 5 run of this file; its gate evidence is filled from the [P4-T3] parallel run. Focused single-file runs made during development were debugging only and are not evidence.

Implementation note: the `Unpinned` step replays the R1 baseline before running `inventory -AnalysisMethod scanner -Write` without `-Revision` and `validate -Mode docs-complete -Revision R1`. Without the ledger, matrix and pins of the baseline, validate stops at DOCS_INPUT_UNREADABLE before reaching the revision gate.
