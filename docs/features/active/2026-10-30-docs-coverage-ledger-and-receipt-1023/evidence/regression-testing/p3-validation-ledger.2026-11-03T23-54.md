# Suite Evidence: DocsValidation profile and ledger modes ([P3-T3])

Timestamp: 2026-11-03T23-54
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsValidation.Tests.ps1 tests=15 failures=0 errors=0; DocsValidation.Properties.Tests.ps1 tests=4 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsValidation.psm1`: 98.72 (154 covered, 2 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p3-receipt evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsValidation.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsValidation.Properties.Tests.ps1` | 4 | 0 | 0 | 0 |

[P3-T3] tests (`Describe 'Invoke-DocsValidation profile and ledger layers'`): `profile mode returns ConvertFrom-DocsProfileText findings`, `returns a null receipt when the profile does not load`, `reports DOCS_INPUT_UNREADABLE for an absent snapshot or ledger`, `reports schema findings for a schema-invalid ledger`, `reports DOCS_REVISION_MISMATCH for a differing non-null snapshot revision`, `fails validation_result on an error beyond the finding bound` (101 ledger warnings sort before one snapshot error; the receipt carries the unbounded ordered set and `validation_result` is `fail` while the 100-bounded view holds no error), `raises the receipt defect guard for a receipt that fails its schema`, `returns a schema-valid receipt pinned to the revision in profile and ledger modes on pass and fail`.

[P3-T3] properties: `property Get-DocsValidationMode: four modes in layering order`, `property Get-DocsValidationInputKind: each mode needs a superset of the previous mode's inputs` (exhaustive over the four modes).

## Files

- Created `.claude/lib/docs/DocsValidation.psm1` exporting `Get-DocsValidationMode`, `Get-DocsValidationInputKind` and `Invoke-DocsValidation` (signature `-Mode -Revision -IssuedAt -ProfileText -ProfilePath -Artifact -PagePath -ComposedSchemaSet [-AnalyzerId]`, returning `@{ Receipt; Findings; Ok }`); imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`, `DocsProfile.psm1`, `DocsLedger.psm1`, `DocsLedgerRules.psm1` (the Phase 1 split), `DocsParity.psm1`, `DocsEvidencePins.psm1`, `DocsStaleness.psm1` and `DocsReceipt.psm1` with literal joins. `Artifact` maps a kind to `@{ Path; Bytes }` or `$null`; `Get-DocsValidationInputKind` names `docs-profile`, `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin` and the pseudo-kind `page-path-set`. Exit code and `validation_result` come from the unbounded set ordered with the finding count as the limit (OQ-3 default); the receipt defect guard throws `DOCS_RECEIPT_INVALID`.
- Order-dependence found and fixed on the module side: the first full-folder run failed four `DocsValidation` cases with `CommandNotFoundException: Test-DocsRelativePath` because the module called a `DocsSurface.psm1` function without importing that sibling; the literal `DocsSurface.psm1` import was added and the folder run repeated (this record is the repeated run).
- Created `tests/scripts/claude-lib/docs/DocsValidation.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsValidation.Properties.Tests.ps1` (counts above include the [P3-T4] cases).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
