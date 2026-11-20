# Suite Evidence: DocsValidation matrix and docs-complete modes ([P3-T4])

Timestamp: 2026-11-03T23-54
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsValidation.Tests.ps1 tests=15 failures=0 errors=0; DocsValidation.Properties.Tests.ps1 tests=4 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsValidation.psm1`: 98.72 (154 covered, 2 missed); 367 logical lines. The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p3-receipt evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsValidation.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsValidation.Properties.Tests.ps1` | 4 | 0 | 0 | 0 |

[P3-T4] tests (`Describe 'Invoke-DocsValidation matrix and docs-complete layers'`): `matrix mode reports DOCS_STALE_PAGE as a warning`, `reports DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete`, `reports DOCS_PARITY_REQUIRED_DIMENSION for fail and not-assessed`, `reports DOCS_BOUND_PAGE_MISSING for a bound page outside the page-path set`, `makes DOCS_STALE_PAGE an error only above max_stale_pages` (below, equal, above), `passes deferred and precision-limit entries with allow_deferred true and reports DOCS_DEFERRED_NOT_ALLOWED with false`, `returns a schema-valid receipt pinned to the revision in matrix and docs-complete modes on pass and fail`.

[P3-T4] properties: `property Get-DocsCompletionGateFinding: DOCS_STALE_PAGE is an error exactly when the stale count exceeds max_stale_pages` (seeds 11, 1023, 65537; 8 rounds per seed), `property Invoke-DocsValidation: finding codes of each mode include those of the previous mode; every receipt validates` (seeded defects over the complete fixture, four modes per seed).

## Files

- Added to `.claude/lib/docs/DocsValidation.psm1`: `Get-DocsCompletionGateFinding -Gate -SnapshotView -Ledger [-Matrix] [-StalePage] [-PagePath] [-SnapshotRevision] [-PinSet] [-SnapshotPath] [-LedgerPath] [-MatrixPath] [-PinPath]` (codes `DOCS_SNAPSHOT_UNPINNED`, `DOCS_DEFERRED_NOT_ALLOWED` over element and precision-limit entries alike, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_BOUND_PAGE_MISSING`, and `DOCS_STALE_PAGE` at `error` exactly when the stale-page count exceeds `max_stale_pages`), and the matrix layer of `Invoke-DocsValidation` (schema checks of the matrix and pin collection, `Get-DocsPinFinding`, `Get-DocsMatrixFinding` over the page-path set and the profile `page_owners`, `Get-DocsStalePage`; `DOCS_STALE_PAGE` as `warning` in `matrix` mode and through the gate in `docs-complete`). The fixture matrices give a text `rationale` to every `fail` and `not-applicable` dimension, which the matrix schema requires.

Toolchain on these files: Invoke-Formatter check-only (0 differing over 49 files under LIB and TESTS), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
