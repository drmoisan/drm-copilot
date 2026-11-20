# P3 Orphans - Issue #1021

Timestamp: 2026-11-03T23-00
Task: [P3-T3]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1 issue-1021-p3-orphans.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=9 PASSED=9 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. Property-test seed: 1021 (25 rounds). CI: CI-PESTER.

## Scope

- Module `.claude/lib/docs/DocsPageOrphans.psm1`: `Get-DocsPageEntryPage`, `Get-DocsPageReachable`, `Get-DocsPageOrphanFinding`; imports `DocsFinding.psm1` by a literal join.
- Suite `tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1`: `README.md` preferred over `index.md`; `index.md` fallback; no entry page yields `$null`; breadth-first walk terminates on cycles; an unreachable page yields `DOCS_PAGE_ORPHAN` with the page as `artifact_path`, pointer `''` and severity `error`; entry pages are never orphans; nested roots reach their pages from their own entry page; an edge from a file outside the page set does not count.
- Property test (seeded `[System.Random]` 1021, seed and round printed through `-Because`): the orphan result is unchanged under permutation of the page listing, of the entry-page order and of edge insertion order.
- First run: 9 of 9 passed.
