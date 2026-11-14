# P3 Diataxis Rules - Issue #1021

Timestamp: 2026-11-03T22-59
Task: [P3-T2]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1 issue-1021-p3-diataxis.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=28 PASSED=28 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. Property-test seeds: 1021 (paragraph insertion, 4 cases x 20 rounds) and 7 (fenced ordered lists, 25 rounds). CI: CI-PESTER.

## Scope

- Module `.claude/lib/docs/DocsPageDiataxis.psm1` (177 lines): `Test-DocsPagePathMatch` (hosted here because CR-8 was not accepted, `1020-precondition`), `Get-DocsPageDirectoryMode`, `Get-DocsPageModeSignal`, `Get-DocsPageDiataxisFinding`; imports `DocsFinding.psm1` and `DocsPageMarkdown.psm1` by literal joins.
- Suite `tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1`: exact, prefix-plus-slash and case-sensitive wildcard matches (`*` crossing `/`, `?`, `[ab]`); first covering entry wins; no covering entry yields `$null` and no finding; each of the five `DOCS_PAGE_MODE_*` codes at its catalog pointer (`/diataxis_mode` for the policy, directory and steps rules, `''` with a `line <n>:` prefix for the heading and generated-block rules); signals inside fences and comments ignored.
- Property tests (seeded `[System.Random]`, seed and round printed through `-Because`): the verdict is unchanged under insertion of plain paragraph lines (seed 1021); ordered-list lines inside a fence never count as steps (seed 7).
- First run: 28 of 28 passed.
