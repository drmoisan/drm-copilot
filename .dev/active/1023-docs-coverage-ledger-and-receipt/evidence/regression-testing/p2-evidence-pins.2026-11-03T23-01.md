# Suite Evidence: DocsEvidencePins ([P2-T1])

Timestamp: 2026-11-03T23-01
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsEvidencePins.Tests.ps1 tests=8 failures=0 errors=0; DocsEvidencePins.Properties.Tests.ps1 tests=6 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsEvidencePins.psm1`: 96.84 (92 covered, 3 missed). Folder run: 490 tests, 486 passed, 4 failed, 0 errors; the four failures are the Docs.Manifest.Tests.ps1 (1020) cases that require the bundle copies and core.json entries of [P6-T1] and [P6-T2], which the plan records as passing once Phase 6 lands; Pester's Run.Exit sets the exit code to that failure count, so 4 is the expected exit until Phase 6. No 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsEvidencePins.Tests.ps1` | 8 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsEvidencePins.Properties.Tests.ps1` | 6 | 0 | 0 | 0 |

Tests: `derives pin_id with Get-DocsStableId over element_id, page_path and symbol`, `copies source_sha256 as an opaque value and allows a null revision`, `builds an empty collection whose id depends on the repository id`, `reports DOCS_PIN_INCONSISTENT for a tampered identity`, `reports DOCS_PIN_INCONSISTENT for a wrong pin_id`, `reports DOCS_PIN_INCONSISTENT for a duplicate pin_id`, `replaces a pin with the same pin_id`, `removes the pins of one element and page`. Built pins and collections are validated with `Test-DocsArtifactText -ArtifactKind 'docs-evidence-pin'` (0 findings) inside those tests.

Properties (seeds 11, 1023, 65537): `property Get-DocsPinId: injective over seeded triples; stable across calls`, `property New-DocsEvidencePin: built pins yield no DOCS_PIN_INCONSISTENT`, `property New-DocsPinCollectionDocument: id depends only on the repository id`, `property Get-DocsPinFinding: findings and canonical output invariant under pin permutation`, `property Merge-DocsEvidencePin: re-pinning keeps one pin with the same pin_id`, `property Get-DocsPinSetWithoutPin: removes exactly the pins of the named element and page`.

## Files

- Created `.claude/lib/docs/DocsEvidencePins.psm1` (285 lines) exporting `Get-DocsPinId`, `New-DocsEvidencePin`, `New-DocsPinCollectionDocument`, `Get-DocsPinFinding`, `Merge-DocsEvidencePin`, `Get-DocsPinSetWithoutPin`; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` with literal joins.
- Created `tests/scripts/claude-lib/docs/DocsEvidencePins.Tests.ps1` (197 lines) and `tests/scripts/claude-lib/docs/DocsEvidencePins.Properties.Tests.ps1` (195 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (0 findings), parser (0 errors).
