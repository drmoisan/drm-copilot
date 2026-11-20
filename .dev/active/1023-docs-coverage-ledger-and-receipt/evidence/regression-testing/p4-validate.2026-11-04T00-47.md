# Suite Evidence: validate subcommand ([P4-T6])

Timestamp: 2026-11-04T00-47
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerCommands.Validate.Tests.ps1 tests=11 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsLedgerCommands.psm1`: 99.13 (343 covered, 3 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6; no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Validate.Tests.ps1` | 11 | 0 | 0 | 0 |

Tests: `makes zero WriteText calls without WriteReceipt in every mode` (pass and fail in all four modes), `writes only the receipt at validation_receipt on pass and on fail with WriteReceipt` (the written text parsed with `ConvertFrom-DocsJsonText` carries `id`, `mode`, `repository`, `revision` and `validation_result` equal to the receipt in `result`; `create` when absent, `overwrite` when present; the receipt is not pinned as its own input), `pins the receipt revision to the Revision argument`, `exits 2 for WriteReceipt with any other mode`, `reports DOCS_LEDGER_LIMIT_UNRECORDED in ledger mode` (message names analyzer, code, path, diagnostic id and element id), `exits 1 with DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete`, `exits 1 with null result when the profile does not load` (absent, schema-invalid, unparsable; a profile with a semantic finding still loads and yields a fail receipt), `exits 2 for a missing Mode, an invalid Revision and an unknown option before any read` (six cases, zero context calls), `exits 3 for an injected read failure, a receipt write failure and a non-UTC clock`, `emits schema-valid byte-identical Json envelopes` (exit 0, 1, 2, 3; the receipt in `result` validates), `prints the summary line without Json`.

## Files

- Added to `.claude/lib/docs/DocsLedgerCommands.psm1`: `Invoke-DocsValidateCommand -Argument -Context`. It reads the profile bytes, loads the profile for `artifact_paths` and `documentation_roots`, reads the inputs of `Get-DocsValidationInputKind -Mode`, and calls `Invoke-DocsValidation`; the receipt is `result` on exit 0 and 1 (null when the profile does not load). With `-WriteReceipt` (docs-complete only, enforced by `Test-DocsValidateArgument`) the receipt text is planned against the digest of any existing receipt (read through `Read-DocsLedgerInputSet`, never through a member expression) and committed through `Invoke-DocsArtifactWrite`; a conflict or write failure is exit 3 with one `DOCS_CLI_RUNTIME` finding. Without `-WriteReceipt` the `WriteText` member is never read.
- Created `tests/scripts/claude-lib/docs/DocsLedgerCommands.Validate.Tests.ps1` (343 lines).

Toolchain on the Phase 4 files: Invoke-Formatter check-only (0 differing over 57 files under LIB and TESTS), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
