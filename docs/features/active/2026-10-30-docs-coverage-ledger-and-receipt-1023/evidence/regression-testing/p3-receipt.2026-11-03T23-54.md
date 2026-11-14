# Suite Evidence: DocsReceipt ([P3-T1])

Timestamp: 2026-11-03T23-54
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsReceipt.Tests.ps1 tests=12 failures=0 errors=0; DocsReceipt.Properties.Tests.ps1 tests=6 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsReceipt.psm1`: 100 (95 covered, 0 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases that fail until the new LIB files are mirrored and manifested in Phase 6 (see the Phase 1-2 evidence); no 1023 suite fails (JUnit root: tests=539 failures=4 errors=0).

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsReceipt.Tests.ps1` | 12 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsReceipt.Properties.Tests.ps1` | 6 | 0 | 0 | 0 |

Tests (`DocsReceipt.Tests.ps1`): `formats the invariant UTC timestamp and throws for a non-Utc Kind`, `returns writer version 1.0.0`, `pins raw bytes with Get-DocsBytesSha256Hex and pins nothing for absent bytes`, `sorts inputs by artifact_kind then path`, `property Get-DocsReceiptId: unchanged when only issued_at, counts or findings differ; changed when any identity member differs` (the receipt identity property, seeds 11, 1023, 65537), `counts zeros where the mode reads no input and excludes precision-limit entries`, `builds pass and fail receipts that produce no finding from Test-DocsArtifactText`, `returns receipt-invalid for unparsable or schema-invalid text`, `returns mode-not-docs-complete`, `returns result-fail`, `returns revision-mismatch including a letter-case-only difference`, `allows a passing docs-complete receipt pinned to the revision`.

Properties (`DocsReceipt.Properties.Tests.ps1`): `property ConvertTo-DocsTimestampText: seeded UTC instants round-trip at second precision; every non-Utc Kind throws`, `property Get-DocsWriterVersion: constant across calls`, `property Get-DocsArtifactPin: sha256 equals Get-DocsBytesSha256Hex of seeded byte arrays`, `property Measure-DocsReceiptCount: by_disposition sums to entries matching current elements; precision-limit entries excluded`, `property New-DocsValidationReceipt: receipt validates and inputs are sorted for seeded pins`, `property Get-DocsReceiptGateDecision: reason follows the fixed precedence over all combinations of the four failure conditions (exhaustive)` (16 combinations).

## Files

- Created `.claude/lib/docs/DocsReceipt.psm1` (299 lines) exporting `ConvertTo-DocsTimestampText`, `Get-DocsWriterVersion`, `Get-DocsArtifactPin`, `Get-DocsReceiptId`, `Measure-DocsReceiptCount`, `New-DocsValidationReceipt` and `Get-DocsReceiptGateDecision`; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` with literal joins. OQ-4 default: the gate decision compares with the supplied `-HeadRevision` ordinally. OQ-5 default: counts exclude precision-limit (marked) entries. `Get-DocsArtifactPin -Bytes $null` returns `$null`, and `New-DocsValidationReceipt` drops null pins and sorts the rest, so an absent artifact is never pinned (S11).
- Created `tests/scripts/claude-lib/docs/DocsReceipt.Tests.ps1` (291 lines) and `tests/scripts/claude-lib/docs/DocsReceipt.Properties.Tests.ps1` (191 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings per file under timeout (0 findings; one transient `Object reference not set` analyzer fault was observed on the first file of a process and reproduced on the unchanged 1020 file `DocsSchema.psm1`, then cleared on re-run), parser (0 errors).
