# [P0-T3] Existing 1020 test disposition (issue #1022)

Timestamp: 2026-11-03T21-47
Command: grep -n -e 'Get-DocsAnalyzerRegistration' -e 'Get-DocsCommandTable' -e 'DocsAnalyzerRow' -e 'DocsCommandRow' -e '-Help' -e 'core.json' -e '# --- ' -e 'config-files' -e 'python-architecture' -e 'python-cli' -e 'python-http' -e 'python-public-api' -e 'inventory' <the seven 1020 suites under tests/scripts/claude-lib/docs/>
EXIT_CODE: 0
Output Summary: 12 matching `It` blocks across 5 suites (DocsAnalyzerRegistry, Invoke-DocsCommand, Docs.Manifest, DocsProfileCommands, DocsProfile); every one asserts membership, anchor presence or order, row validity, or per-file manifest and mirror identity. 0 MISMATCH. DocsNeutrality.Tests.ps1 and DocsSchemaContract.Tests.ps1 contain no assertion over the registry rows, the dispatch rows, the help listing, the `CORE` docs entries or the `LIB` file set (DocsNeutrality scans files for consumer identifiers only).

## Dispositions

| Suite | `It` | Assertion class | Disposition |
|---|---|---|---|
| `DocsAnalyzerRegistry.Tests.ps1` | `declares the scanner table with the 1022 then 1033 anchors and the native table after it with the 1031 anchor` | anchor presence and order (`IndexOf` comparisons) | unchanged |
| `DocsAnalyzerRegistry.Tests.ps1` | `holds both tables in module scope (read only)` | variable presence | unchanged |
| `DocsAnalyzerRegistry.Tests.ps1` | `carries no placeholder-numbered anchor, and the guard regex matches a positive control` | absence of `900xxx` anchors | unchanged |
| `DocsAnalyzerRegistry.Tests.ps1` | `reports no finding for the committed registry` | row validity (`Test-DocsAnalyzerRegistration` count 0) | unchanged (five valid scanner rows keep the count at 0) |
| `DocsAnalyzerRegistry.Tests.ps1` | `Get-DocsAnalyzerRegistration` / `Select-DocsAnalyzerRegistration` describes (in-memory rows via `-ScannerRow` and `-NativeRow`) | in-memory rows, not the committed table | unchanged |
| `Invoke-DocsCommand.Tests.ps1` | `returns no finding for the committed table` | row validity (`Test-DocsCommandTable` count 0) | unchanged (the `inventory` row is valid) |
| `Invoke-DocsCommand.Tests.ps1` | `rejects <Case>` | in-memory tables | unchanged |
| `Invoke-DocsCommand.Tests.ps1` | `carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor` | anchor presence and order; `init` after the 1020 anchor and `validate-profile` before the 1021 anchor | unchanged (the `inventory` row sits between the 1022 and 1023 anchors) |
| `Invoke-DocsCommand.Tests.ps1` | `exits 0 for -Help and reads nothing; with -Json the envelope has no findings and result usage` | `Stdout` matches `validate-profile` (membership), usage count greater than 1 | unchanged (no exact help text) |
| `Invoke-DocsCommand.Tests.ps1` | `writes usage and sets exit code 0 for -Help, and exit code 2 with an empty stderr without -Command` | exit codes and empty stderr | unchanged |
| `Docs.Manifest.Tests.ps1` | `lists every filtered docs file exactly once in core.json paths`, `ships a bundled counterpart for every filtered docs file`, `ships byte-identical bundled counterparts`, `lists no path under .claude/lib/docs/python/ in core.json` | per-file manifest membership and mirror identity over files discovered on disk | unchanged (gains the seventeen new files as sources; satisfied by [P5-T1] and [P5-T2]) |
| `DocsProfileCommands.Tests.ps1` | `carries the 1021 and 1034 anchors in order with no placeholder-numbered anchor` | `Get-DocsInitTemplate` anchors in `DocsProfileCommands.psm1` (not a 1022 file) | unchanged |
| `DocsProfile.Tests.ps1` | `accepts a selected analyzer that is in AnalyzerId`; starter-profile case asserting `surface_selection` has no `analyzers` key; `DOCS_ANALYZER_UNKNOWN` mutation with `unregistered-analyzer` | in-memory `-AnalyzerId` lists and the starter profile | unchanged |

## MISMATCH search result

- Zero-row assertion over the committed registry: none found (the 1020 suite heading reads `Committed provider tables (membership only)`).
- Exact row or name set, row count, exact help text: none found.
- Assertion that `config-files`, `python-architecture`, `python-cli`, `python-http`, `python-public-api` or `inventory` is unknown or unregistered: none found (the unknown-analyzer cases use `unregistered-analyzer` and `not-registered`-style in-memory values).

Result: 0 MISMATCH; execution continues.
