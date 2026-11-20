# Suite Evidence: coverage subcommand and the coverage report split ([P4-T3])

Timestamp: 2026-11-04T00-47
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerCommands.Tests.ps1 tests=21 failures=0 errors=0; DocsLedgerCommands.Properties.Tests.ps1 tests=2 failures=0 errors=0; DocsCoverageReport.Tests.ps1 tests=3 failures=0 errors=0; DocsCoverageReport.Properties.Tests.ps1 tests=2 failures=0 errors=0. Line coverage: `.claude/lib/docs/DocsCoverageReport.psm1` 100 (77 covered, 0 missed); `.claude/lib/docs/DocsLedgerCommands.psm1` 99.13. The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 21 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1` | 2 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Tests.ps1` | 3 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Properties.Tests.ps1` | 2 | 0 | 0 | 0 |

[P4-T3] tests (`DocsLedgerCommands.Tests.ps1`, `Describe 'coverage'`, through `Invoke-DocsCommandCli` with the recording context): `returns totals with by_analysis_method, undocumented, deferred, precision_limits, stale_pages and parity`, `marks an unrecorded precision limit recorded false`, `lists every element as undocumented and exits 0 without ledger, matrix or pins`, `makes zero WriteText calls`, `exits 1 with DOCS_INPUT_UNREADABLE and null result for an absent snapshot` (and `DOCS_PROFILE_MISSING` for an absent profile), `exits 1 for a schema-invalid snapshot` (schema, element rebuild, schema-invalid ledger), `exits 2 with one DOCS_CLI_ARGUMENTS before any read` (unknown option, missing value, absolute and parent-relative paths, positional token; zero context calls), `exits 3 with one DOCS_CLI_RUNTIME for an injected read failure and a non-UTC clock` (zero context calls before the clock), `emits an envelope with no finding from Test-DocsArtifactText docs-command-envelope` (exit 0, 1, 2, 3), `produces byte-identical Json stdout for identical runs`, `prints finding lines and the summary line without Json`.

Split applied (pre-approved in `## Design Notes`): `Get-DocsCoverageReport` and `ConvertTo-DocsCoverageReportLine` live in `.claude/lib/docs/DocsCoverageReport.psm1` (163 lines; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsParity.psm1`, `DocsStaleness.psm1`, `DocsReceipt.psm1`), with its own suites `DocsCoverageReport.Tests.ps1` (`builds totals with by_analysis_method, undocumented, deferred, stale_pages and parity`, `marks an unrecorded precision limit recorded false and lists every element as undocumented over empty documents`, `renders the totals line, one line per listed item and one line per parity dimension`) and `DocsCoverageReport.Properties.Tests.ps1` (`property Get-DocsCoverageReport: undocumented, deferred, excluded and documented partition the current elements`, `property ConvertTo-DocsCoverageReportLine: one line per listed item plus the fixed lines for seeded reports`; seeds 11, 1023, 65537). The two report properties the plan places in `DocsLedgerCommands.Properties.Tests.ps1` therefore live in the split module's own property suite, following the Phase 1 `DocsLedgerRules` precedent. The split module needs its own bundle copy and `core.json` line in Phase 6.

## Files

- Added to `.claude/lib/docs/DocsLedgerCommands.psm1`: `Invoke-DocsCoverageCommand -Argument -Context` (OQ-3 and OQ-5 defaults: `totals` is the receipt counts object plus `by_analysis_method`; no finding on exit 0) and the shared private plumbing (`Get-DocsLedgerCommandSchemaSet`, `Get-DocsLedgerCommandTimestamp`, `Read-DocsLedgerCommandProfile`, `ConvertFrom-DocsLedgerCommandArtifact`, `Read-DocsLedgerCommandDocumentSet`, `New-DocsLedgerCommandRuntimeResult`). The clock is formatted after argument validation and before any read; the `WriteText` member is never read by `coverage`.
