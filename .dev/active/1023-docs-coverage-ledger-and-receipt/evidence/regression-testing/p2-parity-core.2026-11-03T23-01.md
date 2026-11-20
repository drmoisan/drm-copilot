# Suite Evidence: DocsParity core ([P2-T3])

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

[P2-T3] tests: `matches the enumerated path_or_glob table` (17 cases: exact, prefix plus slash, star across slash, question mark, class, negated class, letter-case difference not matching, no-escape literal), `returns the first matching page owner`, `creates a row with every dimension not-assessed`, `computes the integer basis-point floor and null for a zero denominator`, `counts per dimension summing to the row count`; rows and documents are validated with `Test-DocsArtifactText -ArtifactKind 'docs-parity-matrix'` (0 findings) inside those tests.

Properties ([P2-T3]): `property Get-DocsParityDimension: five dimensions in contract order on every call`, `property Test-DocsPathOrGlobMatch: agrees with the enumerated table; a letter-case change of a literal character never matches`, `property Get-DocsPageOwner: first match wins; appending non-matching entries keeps the owner`, `property New-DocsParityRow: every dimension not-assessed; row validates`, `property New-DocsParityMatrixDocument: id depends only on the repository id`, `property Get-DocsScoreBasisPoint: equals the integer floor formula or null for a zero denominator`, `property Measure-DocsParityScore: per-dimension counts sum to the row count` (seeds 11, 1023, 65537).

## Files

- Created `.claude/lib/docs/DocsParity.psm1` (545 lines) exporting `Get-DocsParityDimension`, `Test-DocsPathOrGlobMatch`, `Get-DocsPageOwner`, `New-DocsParityRow`, `New-DocsParityMatrixDocument`, `Get-DocsScoreBasisPoint`, `Measure-DocsParityScore` and the [P2-T4] functions; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` with literal joins (OQ-1 default: 1023 owns the path matching). The glob is translated character by character to an anchored .NET regular expression (`\z` anchor, `CultureInvariant`, no `IgnoreCase`); `-like` and `[WildcardPattern]` are not used. Scores use `[System.Math]::DivRem` over `[long]` values. The file is between the 500-line guidance and the 700-line advisory tier; the plan pre-approves no split for this module and no gate fails.
- Created `tests/scripts/claude-lib/docs/DocsParity.Tests.ps1` (371 lines) and `tests/scripts/claude-lib/docs/DocsParity.Properties.Tests.ps1` (329 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
