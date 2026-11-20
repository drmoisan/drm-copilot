# Suite Evidence: DocsParity matrix rules and operations ([P2-T4])

Timestamp: 2026-11-03T23-01
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsParity.Tests.ps1 tests=18 failures=0 errors=0; DocsParity.Properties.Tests.ps1 tests=12 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsParity.psm1`: 98.92 (183 covered, 2 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p2-evidence-pins evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsParity.Tests.ps1` | 18 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsParity.Properties.Tests.ps1` | 12 | 0 | 0 | 0 |

[P2-T4] tests: `reports no finding for a consistent matrix`, `reports DOCS_MATRIX_UNBOUND_ROW`, `reports DOCS_MATRIX_ROW_MISSING`, `reports DOCS_MATRIX_DUPLICATE_ROW`, `reports DOCS_MATRIX_PIN_UNKNOWN` (unknown and foreign pin ids), `reports DOCS_MATRIX_ACCURACY_UNPINNED`, `reports DOCS_MATRIX_EXISTS_INCONSISTENT`, `reports DOCS_MATRIX_OWNER_INCONSISTENT`, `reports DOCS_MATRIX_LEDGER_REF as a warning`, `creates an absent row and derives sorted evidence_pin_ids`, `removes rows of one element and page`, `removes one pin id from every row`, `sets snapshot_ref and ledger_ref`.

Properties ([P2-T4]): `property Get-DocsMatrixFinding: findings and canonical output invariant under row permutation`, `property Merge-DocsParityDimension: changes only the named dimension; sorted evidence_pin_ids`, `property Get-DocsMatrixWithoutBinding: removes exactly the rows of the named element and page`, `property Merge-DocsMatrixPinRemoval: no row references the removed pin; other ids keep their order`, `property Merge-DocsMatrixRef: idempotent; both refs equal the supplied pins` (seeds 11, 1023, 65537).

## Files

- `.claude/lib/docs/DocsParity.psm1` carries `Get-DocsMatrixFinding`, `Merge-DocsParityDimension`, `Get-DocsMatrixWithoutBinding`, `Merge-DocsMatrixPinRemoval` and `Merge-DocsMatrixRef`; each operation returns a deep copy with rows sorted by `element_id` then `page_path` and never mutates its input. Matrix findings are emitted through `Get-DocsOrderedFinding` with the finding count as the limit (clamped to 10000).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
