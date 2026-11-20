# Suite Evidence: DocsLedgerMutation ([P3-T2])

Timestamp: 2026-11-03T23-54
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerMutation.Tests.ps1 tests=8 failures=0 errors=0; DocsLedgerMutation.Properties.Tests.ps1 tests=1 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsLedgerMutation.psm1`: 98.33 (59 covered, 1 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p3-receipt evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerMutation.Tests.ps1` | 8 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsLedgerMutation.Properties.Tests.ps1` | 1 | 0 | 0 | 0 |

Tests: `marks unchanged text skipped and changed text planned`, `dry run invokes none of ReadBytes, TestFile and WriteText`, `creates an absent document only after TestFile returns false`, `reports conflict when a document expected absent exists`, `overwrites only when the re-read digest equals BeforeSha256`, `reports conflict on a digest mismatch, stops, and lists written paths`, `stops on a throwing WriteText and reports the failed path`, `writes in ordinal path order and never writes skipped plans`.

Property: `property Get-DocsArtifactWritePlan: ordinal-sorted by path; skipped exactly when the digest is unchanged` (seeds 11, 1023, 65537).

## Files

- Created `.claude/lib/docs/DocsLedgerMutation.psm1` (168 lines) exporting `Get-DocsArtifactWritePlan` and `Invoke-DocsArtifactWrite`; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` with literal joins and no 1023 module. Plans are `@{ Path; ArtifactKind; ArtifactId; Text; BeforeSha256; Sha256; Status }`; `Invoke-DocsArtifactWrite` returns `@{ Write; Failed; WrittenPath }` where `Failed` is the failing plan copy with a `Message` member (status `conflict` for a present-when-absent document or a digest mismatch; status unchanged for a throwing `WriteText`). The only scriptblock invocations are `& $TestFile`, `& $ReadBytes` and `& $WriteText`; `-DryRun` invokes none.
- Created `tests/scripts/claude-lib/docs/DocsLedgerMutation.Tests.ps1` (194 lines) and `tests/scripts/claude-lib/docs/DocsLedgerMutation.Properties.Tests.ps1` (65 lines), both over the recording context of `DocsLedger.TestSupport.psm1`.

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
