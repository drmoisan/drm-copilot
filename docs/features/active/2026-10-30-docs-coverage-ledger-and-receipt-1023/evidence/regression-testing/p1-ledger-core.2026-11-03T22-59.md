# Suite Evidence: DocsLedger core ([P1-T2])

Timestamp: 2026-11-03T22-59
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedger.Tests.ps1 tests=15 failures=0 errors=0; DocsLedger.Properties.Tests.ps1 tests=9 failures=0 errors=0 (the six [P1-T2] properties plus the three [P1-T4] properties). Line coverage of `.claude/lib/docs/DocsLedger.psm1`: 98.82 (167 covered, 2 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p1-test-support evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedger.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedger.Properties.Tests.ps1` | 9 | 0 | 0 | 0 |

[P1-T2] tests in `DocsLedger.Tests.ps1`: `rebuilds every element keyed by element_id`, `reports DOCS_SNAPSHOT_ELEMENT_INVALID at the element pointer for a tampered element id`, `reports DOCS_SNAPSHOT_LIMIT_INVALID for an unknown marker element_kind`, `reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic with null path`, `reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic from a native analyzer`, `reports DOCS_SNAPSHOT_LIMIT_INVALID when the precision-limit id equals an element id`, `ignores diagnostics without the marker`, `derives the precision-limit id with Get-DocsElementId over kind, path and diagnostic id`, `copies element_id, kind and analysis_method and sorts bindings with a null anchor first`, `builds a deferred scanner precision-limit entry with the marker`, `builds an empty ledger whose id depends on the repository id`. Every built entry and document is validated with `Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger'` (0 findings) inside those tests.

Properties ([P1-T2], `DocsLedger.Properties.Tests.ps1`, seeds 11, 1023, 65537 or exhaustive): `property ConvertTo-DocsSnapshotView: element map and findings invariant under element and diagnostic permutation`, `property Test-DocsPrecisionLimitDiagnostic: true exactly when all three marker rules hold (exhaustive)` (24 combinations), `property Get-DocsPrecisionLimitElementId: equals Get-DocsElementId over kind, path and diagnostic id and passes Test-DocsElementId`, `property New-DocsLedgerEntry: bindings ordinal-sorted; output invariant under binding permutation`, `property New-DocsPrecisionLimitEntry: entry validates for seeded owners, targets and rationales`, `property New-DocsLedgerDocument: id depends only on the repository id`.

## Files and the split rule

- Created `.claude/lib/docs/DocsLedger.psm1` (533 lines) exporting `ConvertTo-DocsSnapshotView`, `Test-DocsPrecisionLimitDiagnostic`, `Get-DocsPrecisionLimitElementId`, `New-DocsLedgerEntry`, `New-DocsPrecisionLimitEntry`, `New-DocsLedgerDocument`, `Merge-DocsLedgerEntry`, `Get-DocsLedgerWithoutEntry`, `Merge-DocsLedgerSnapshotRef`. Imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` with literal joins.
- Split applied (plan `## Design Notes`, pre-approved): the module with the rules measured 687 lines, above the 500-line guidance, so `Get-DocsLedgerEntryCompanionFinding` and `Get-DocsLedgerFinding` live in `.claude/lib/docs/DocsLedgerRules.psm1` (created in this phase, recorded under [P1-T3]) with its own suites. `DocsLedger.psm1` stays at 533 lines (between the 500 guidance and the 700 advisory tiers; no gate fails).
- `Test-DocsPrecisionLimitDiagnostic` takes `-Diagnostic` and `-Analyzer` (the snapshot `analyzers` array), because rule 3 needs the analyzer table.
- Created `tests/scripts/claude-lib/docs/DocsLedger.Tests.ps1` (361 lines) and `tests/scripts/claude-lib/docs/DocsLedger.Properties.Tests.ps1` (307 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
