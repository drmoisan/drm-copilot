# Phase 0 Baseline: Pester Gate (P0-T4)

Timestamp: 2026-11-24T12-07
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, coverage on, integration and golden lanes excluded); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml with SCRATCH/issue-1220-pester-summary.ps1
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 862.54s, exit code 0. Tests total 29936, passed 29918, failed 0, errors 0, skipped 18. Repo-wide line coverage 96.88% (47905 covered, 1541 missed). Per-file line coverage below. No pre-existing failure.

Merged report write time (UTC): 2026-11-24T12:07:32Z.

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| .claude/lib/docs/DocsPageMetadata.psm1 | 111 | 0 | 100% |
| .claude/lib/docs/DocsPageFrontMatter.psm1 | 189 | 0 | 100% |
| .claude/lib/docs/DocsValidation.psm1 | 157 | 2 | 98.74% |
| .claude/lib/docs/DocsValidateCommands.psm1 | 105 | 0 | 100% |
| .claude/lib/docs/DocsReferenceFrontMatter.psm1 | 90 | 0 | 100% |
| .claude/lib/docs/DocsStaleness.psm1 | 46 | 0 | 100% |
| .claude/lib/docs/DocsCompleteGate.psm1 | 39 | 0 | 100% |

Pre-existing failures: none.
