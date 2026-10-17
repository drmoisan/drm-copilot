# Pass-After Run: Six Touched Suites (Issue #973)

Timestamp: 2026-10-17T13-33
Command: sh SCRATCH/issue-973-six.sh <worktree> (PowerShell 7; Invoke-PoshQCTest -ScanFolders with the six suites below in one Pester process, then issue-973-report.ps1 over artifacts/pester/pester-junit.xml); git diff --exit-code MB -- tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1; git status --porcelain
EXIT_CODE: 0

Suites (one process): `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`.

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-33): 208 test cases, 208 passed, 0 failed, 0 skipped; no container errors.

`git diff --exit-code MB -- tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`: exit code 0 (file unmodified).

`git status --porcelain`: no entry for `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`. Entries present: modified `.github/workflows/ci.yml`, `config/ci-docs-only-paths.json`, `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`, `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, the plan file; untracked `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` and the `FEATURE/evidence/` folders.

`tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` names `ci.yml` only as a path literal for a different classifier and is unaffected (not run here; covered by [P4-T8]).

## Acceptance criteria verified by this run (spec.md, document order)

| AC | Rows passing in this run |
|---|---|
| AC-1 | M1 |
| AC-2 | M2 |
| AC-3 | U5 `... rename into the allowlist (#973)`; M3 `... rename into the allowlist (#973)` |
| AC-4 | U5 `... rename out of the allowlist (#973)`; M3 `... rename out of the allowlist (#973)` |
| AC-5 | M4 `docs/features/archive/` (committed config); U4 and config row `lists docs/features/archive/ as an include prefix (#973)` |
| AC-6 | M4 `docs/features/parallel/` (committed config); U4 and config include-prefix row |
| AC-7 | M4 `docs/features/epics/` (committed config); U4 and config include-prefix row |
| AC-8 | M5 `BASE_SHA is blank` (summary ends `base=none`) |
| AC-9 | M5 `git cat-file exits 128` |
| AC-10 | M5 `git merge-base exits 1`, `git merge-base exits 128` |
| AC-11 | M5 empty, not a SHA, two SHA lines; U3 (8 rows) |
| AC-12 | M6 `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR` |
| AC-13 | M7 `development`, `epic/x` |
| AC-14 | M8 `RUN_LIST_FAILED`, `JOB_LIST_FAILED` |
| AC-15 | M11 (4 rows); every row of `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` passes and the file is unmodified |
| AC-16 | `CiWorkflow.Tests.ps1` event-field row; `CiChangeScopeWorkflow.Tests.ps1` row `passes BASE_SHA and BASE_REF to the scope step of the changes job (#973)` |
| AC-17 | `CiDocsOnlyPathsConfig.Tests.ps1` row `configures exactly the D3 include prefixes and extensions (AC-15)` |

Output Summary: 208 passed, 0 failed; diff exit code 0 for `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`; no porcelain entry for that file. AC-1 to AC-17 verified by the rows listed.
