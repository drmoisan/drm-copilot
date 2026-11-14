# Suite Evidence: DocsLedger.TestSupport ([P1-T1])

Timestamp: 2026-11-03T22-59
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts read from artifacts/pester/pester-junit.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedger.TestSupport.Tests.ps1 tests=8 failures=0 errors=0 skipped=0 (passed=8). Folder run: 490 tests, 486 passed, 4 failed, 0 errors; the four failures are the Docs.Manifest.Tests.ps1 (1020) cases that require the bundle copies and core.json entries of [P6-T1] and [P6-T2] (`lists every filtered docs file exactly once in core.json paths`, `reports a path absent from an in-memory manifest (positive control)`, `ships a bundled counterpart for every filtered docs file`, `ships byte-identical bundled counterparts`), which the plan records as passing once Phase 6 lands; Pester's Run.Exit sets the exit code to that failure count, so 4 is the expected exit until Phase 6.

## Named suite (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1` | 8 | 0 | 0 | 0 |

Tests: `records every context call in order`, `returns written text on a later ReadBytes`, `raises the injected read and write failures`, `uses the supplied clock and keeps a fresh file map per context`, `fixture snapshot produces no finding from Test-DocsArtifactText`, `fixture profile loads without an error finding`, `fixture ledger, matrix and pin collection produce no finding from Test-DocsArtifactText`, `shuffle is a permutation and deterministic per seed`.

## Files

- Created `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` (534 lines): `New-DocsLedgerTestContext` (ordinal path-to-bytes map; call log of every `ReadText`, `ReadBytes`, `TestFile`, `ListFile` and `WriteText` call in order; `WriteText` stores the text; injected `ReadBytesFailure` and `WriteTextFailure` maps; `UtcNow` of Kind Utc, overridable), fixture builders `New-DocsLedgerTestElement`, `New-DocsLedgerTestPrecisionLimitDiagnostic`, `New-DocsLedgerTestSnapshot`, `New-DocsLedgerTestProfile`, `New-DocsLedgerTestEntry`, `New-DocsLedgerTestLedger`, `New-DocsLedgerTestRow`, `New-DocsLedgerTestMatrix`, `New-DocsLedgerTestPin`, `New-DocsLedgerTestPinSet`, `Get-DocsLedgerTestSchemaSet`, `$script:DocsPropertySeed` (11, 1023, 65537; also `Get-DocsLedgerTestSeed`) and `Get-DocsLedgerTestShuffle -Item -Seed`.
- Created `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1` (179 lines).

Toolchain on the two files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (0 findings), PowerShell parser (0 errors).
