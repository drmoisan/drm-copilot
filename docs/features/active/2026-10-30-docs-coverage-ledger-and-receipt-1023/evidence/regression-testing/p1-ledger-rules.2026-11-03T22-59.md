# Suite Evidence: DocsLedger rules ([P1-T3])

Timestamp: 2026-11-03T22-59
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerRules.Tests.ps1 tests=13 failures=0 errors=0; DocsLedgerRules.Properties.Tests.ps1 tests=2 failures=0 errors=0; the DocsLedger family (DocsLedger.Tests.ps1 15/0, DocsLedger.Properties.Tests.ps1 9/0) also passes. Line coverage of `.claude/lib/docs/DocsLedgerRules.psm1`: 98.94 (93 covered, 1 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p1-test-support evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerRules.Tests.ps1` | 13 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedgerRules.Properties.Tests.ps1` | 2 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedger.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedger.Properties.Tests.ps1` | 9 | 0 | 0 | 0 |

Suite placement under the split rule: the plan task names `DocsLedger.Tests.ps1` for these tests, and `## Design Notes` requires a split module to carry its own suite. The rule tests therefore live in `DocsLedgerRules.Tests.ps1` and the two rule properties in `DocsLedgerRules.Properties.Tests.ps1`; together with `DocsLedger.Tests.ps1` and `DocsLedger.Properties.Tests.ps1` they form the DocsLedger suite family that the acceptance criteria naming `DocsLedger.Tests.ps1` (S1, S2, S4, S5, U13) denote.

Tests (`DocsLedgerRules.Tests.ps1`): `reports no finding for a complete and consistent ledger`, `reports DOCS_LEDGER_MISSING_DISPOSITION naming kind, declaration and element id` (asserts `related_ids` and `related_paths`), `reports DOCS_LEDGER_RATIONALE_REQUIRED for excluded without rationale`, `reports DOCS_LEDGER_OWNER_REQUIRED and DOCS_LEDGER_TARGET_REQUIRED for deferred without owner or target`, `reports DOCS_LEDGER_BINDING_REQUIRED for documented without binding`, `reports DOCS_LEDGER_DUPLICATE_ENTRY`, `reports DOCS_LEDGER_ORPHAN_ENTRY for an unmarked unknown id`, `reports DOCS_LEDGER_KIND_MISMATCH`, `reports DOCS_LEDGER_SNAPSHOT_REF as a warning`, `reports DOCS_LEDGER_ANALYSIS_METHOD_CHANGED as a warning`, `reports DOCS_LEDGER_LIMIT_UNRECORDED naming analyzer, code, path, diagnostic id and element id`, `reports DOCS_LEDGER_LIMIT_MISMATCH for a non-deferred, non-scanner, unmarked or differing limit entry`, `reports DOCS_LEDGER_LIMIT_RESOLVED as a warning`.

Properties (`DocsLedgerRules.Properties.Tests.ps1`): `property Get-DocsLedgerEntryCompanionFinding: findings equal the companion table over every disposition and field-presence combination` (48 combinations, exhaustive); `property Get-DocsLedgerFinding: missing-disposition findings name exactly the complement of every entry subset; DOCS_LEDGER_LIMIT_UNRECORDED names exactly the unrecorded limits of every limit subset; findings and canonical output invariant under entry permutation` (64 element subsets, 8 limit subsets, seeds 11, 1023, 65537).

## Files

- Created `.claude/lib/docs/DocsLedgerRules.psm1` (265 lines) exporting `Get-DocsLedgerEntryCompanionFinding` and `Get-DocsLedgerFinding`; findings are emitted through `Get-DocsOrderedFinding` with the finding count as the limit (clamped to the 10000 maximum), so exit codes and validation results can be computed from the unbounded set (OQ-3 default). Imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` with literal joins.
- Created `tests/scripts/claude-lib/docs/DocsLedgerRules.Tests.ps1` (296 lines) and `tests/scripts/claude-lib/docs/DocsLedgerRules.Properties.Tests.ps1` (114 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
