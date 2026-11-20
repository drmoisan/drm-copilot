# Suite Evidence: DocsLedger operations ([P1-T4])

Timestamp: 2026-11-03T22-59
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedger.Tests.ps1 tests=15 failures=0 errors=0; DocsLedger.Properties.Tests.ps1 tests=9 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsLedger.psm1`: 98.82 (167 covered, 2 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p1-test-support evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedger.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedger.Properties.Tests.ps1` | 9 | 0 | 0 | 0 |

Tests (`DocsLedger.Tests.ps1`, Describe `Ledger operations`): `replaces or inserts by element_id and sorts entries`, `leaves the input ledger unchanged` (canonical JSON before and after merge, removal and sync), `removes only the named entry including a precision-limit entry`, `sync sets snapshot_ref and refreshes analysis_method of element entries only`.

Properties (`DocsLedger.Properties.Tests.ps1`, seeds 11, 1023, 65537): `property Merge-DocsLedgerEntry: sorted, one entry per id, input unchanged`, `property Get-DocsLedgerWithoutEntry: removes exactly the named id; inverse of a merge of a new id`, `property Merge-DocsLedgerSnapshotRef: idempotent; element-entry analysis_method equals its element`.

## Files

- `.claude/lib/docs/DocsLedger.psm1` carries `Merge-DocsLedgerEntry`, `Get-DocsLedgerWithoutEntry` and `Merge-DocsLedgerSnapshotRef`; each returns a deep copy (ordered tables and new arrays) with entries sorted by `element_id` ordinally and never mutates its input.

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
