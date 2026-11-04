# Suite Evidence: update-ledger pins, dimensions, sync-refs and the Write commit ([P4-T5])

Timestamp: 2026-11-04T00-47
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerCommands.UpdateLedger.Tests.ps1 tests=21 failures=0 errors=0 (10 cases of [P4-T5] in `Describe 'update-ledger pin, unpin, set-dimension, sync-refs and the Write commit'`). Line coverage of `.claude/lib/docs/DocsLedgerCommands.psm1`: 99.13; `.claude/lib/docs/DocsLedgerMutation.psm1`: 98.33. The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.UpdateLedger.Tests.ps1` | 21 | 0 | 0 | 0 |

[P4-T5] tests: `re-pins the same element and page under the same pin_id and clears staleness` (one pin, same `pin_id`, current digest, `pinned_at` from the clock, revision from the snapshot, claim; `Get-DocsStalePage` empty afterwards), `unpin removes the pin and its id from every row` (and `DOCS_UPDATE_TARGET_INVALID` for an absent pin), `set-dimension creates the row and derives evidence_pin_ids` (new row with the other dimensions `not-assessed`, `evidence_pin_ids` from the existing pin of the element and page; an existing row keeps its other dimensions), `sync-refs refreshes analysis_method and sets both refs` (`ledger_ref.sha256` equals the digest of the ledger bytes as written), `rejects pin, unpin and set-dimension on a precision-limit id`, `writes only through Invoke-DocsArtifactWrite with Write` (every `WriteText` call is an `overwrite` immediately preceded by the digest re-read of the same path, in ascending path order; no write without `-Write`), `exits 3 with one DOCS_CLI_RUNTIME naming the path on a digest conflict` (the matrix changes between the load and the re-read; `artifact_path` is the conflicting path, `related_paths` holds it and the two paths already written, which are not rolled back), `exits 3 for an injected write failure, an injected read failure and a non-UTC clock`, `emits schema-valid byte-identical Json envelopes` (exit 0, 1, 2, 3), `prints the summary line without Json`.

## Files

- `Invoke-DocsUpdateLedgerCommand` result: `{dry_run, preexisting_errors, writes: [{path, artifact_kind, artifact_id, sha256, status}]}` sorted by path (ordinal: `docs-coverage-ledger.json`, `docs-evidence-pins.json`, `docs-parity-matrix.json`); every present document is listed (`skipped` when unchanged), an absent unchanged document is not planned. The commit conflict and write failure map to exit 3 with one `DOCS_CLI_RUNTIME` finding whose message names the path and status (`conflict`, or the unchanged status for a throwing `WriteText`).
- `DocsLedgerCommands.psm1` is 785 logical lines after this phase: above the 700-line advisory tier and below the 800-line hard limit. The pre-approved `DocsCoverageReport.psm1` split was applied in [P4-T3]; the plan pre-approves no further split of this module, and `## Artifact Classification` (checked by [P7-T10]) lists no other module, so the remaining size is recorded here as the advisory reason: the three command functions, the operation dispatcher and the shared loader.
