# Suite Evidence: DocsLedgerCommands arguments and input loading ([P4-T1])

Timestamp: 2026-11-04T00-47
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerCommands.Tests.ps1 tests=21 failures=0 errors=0; DocsLedgerCommands.Properties.Tests.ps1 tests=2 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsLedgerCommands.psm1`: 99.13 (343 covered, 3 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases that fail until the new LIB files are mirrored and manifested in Phase 6; no 1023 suite fails (JUnit root: tests=601 failures=4 errors=0).

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 21 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1` | 2 | 0 | 0 | 0 |

[P4-T1] tests (`DocsLedgerCommands.Tests.ps1`, `Describe 'Test-DocsUpdateLedgerArgument'` and `Describe 'Read-DocsLedgerInputSet'`): `returns one DOCS_CLI_ARGUMENTS finding for an option outside the operation set` (each of the six operations), `rejects Element with Limit and Limit with a non-deferred disposition`, `rejects a repeated Page value`, `rejects invalid Element, Limit, Revision, ActorId, Owner, Page and relative path values`, `rejects WriteReceipt outside docs-complete`, `returns null for valid arguments`, `returns null for an absent artifact and propagates other read failures`, `builds the ordinal page-path set from ListFile over documentation_roots`. The suite's 21 cases include the [P4-T2] and [P4-T3] cases recorded in their own evidence.

Properties (`DocsLedgerCommands.Properties.Tests.ps1`): `property Test-DocsUpdateLedgerArgument: one finding exactly when an option is outside the operation set (every operation and option)` (6 operations x 12 options = 72 combinations; `-Limit` beside the base `-Element` is the exclusive-target finding), `property Test-DocsValidateArgument: accepts exactly the four modes with a full revision; WriteReceipt only with docs-complete` (6 modes x 5 revisions x 2 = 60 combinations).

## Files

- Created `.claude/lib/docs/DocsLedgerCommands.psm1` with `Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument` and `Read-DocsLedgerInputSet -Profile -Need -ReadBytes -TestFile -ListFile` (returns `@{ Artifact; PagePath }`; an absent artifact is `$null`, an `ItemNotFoundException` on read is absence, any other read failure propagates; `page-path-set` in `Need` lists `documentation_roots[].path` through `ListFile`). Imports every 1023 module plus `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`, `DocsJson.psm1`, `DocsSurface.psm1` with literal joins; the private `Get-DocsLedgerCommandSchemaSet` mirrors the 1020 helper.
- Created `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1`.
- Support fix (test file, micro-action for the empty-file and non-documented-entry cases): `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` assigned an empty file's bytes and a non-documented entry's `page_bindings` through an `if` expression that outputs `@()`, which assigns `$null` (an empty file read failed; a deferred fixture entry serialized `[null]`). Both assignments now set the empty array first and reassign inside the `if`. The coverage-instrumented folder runs of Phases 1-3 had masked the second case; `DocsLedger.TestSupport.Tests.ps1` (8/0) and every Phase 1-3 suite pass again in a plain Pester process.

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
