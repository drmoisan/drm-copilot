# Suite Evidence: DocsStaleness ([P2-T2])

Timestamp: 2026-11-03T23-01
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsStaleness.Tests.ps1 tests=6 failures=0 errors=0; DocsStaleness.Properties.Tests.ps1 tests=3 failures=0 errors=0. Line coverage of `.claude/lib/docs/DocsStaleness.psm1`: 100 (46 covered, 0 missed). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6 (see p2-evidence-pins evidence); no 1023 suite fails.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsStaleness.Tests.ps1` | 6 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsStaleness.Properties.Tests.ps1` | 3 | 0 | 0 | 0 |

Tests: `returns digest-changed when digests differ`, `returns element-missing when no current element has the id`, `returns current for equal digests`, `ignores a revision difference` (also proves the ordinal digest comparison), `lists a page exactly when one of its pins is not current`, `names page path, declaration, element id and status in DOCS_STALE_PAGE` (warning and error severities, related ids and paths).

Properties: `property Get-DocsPinStatus: presence by digest by revision product yields the three statuses; revision never matters (exhaustive)` (8 combinations), `property Get-DocsStalePage: page listed exactly when a pin is not current; ordinal and permutation invariant` and `property Get-DocsStalenessFinding: one finding per stale page with the requested severity` (seeds 11, 1023, 65537).

## Files

- Created `.claude/lib/docs/DocsStaleness.psm1` (150 lines) exporting `Get-DocsPinStatus`, `Get-DocsStalePage`, `Get-DocsStalenessFinding`; imports `DocsFinding.psm1` and `DocsEvidencePins.psm1` with literal joins. `Get-DocsStalenessFinding` takes an optional `-PinSet` so the message can name the declaration of a pin whose element is missing from the snapshot (the pin symbol).
- Created `tests/scripts/claude-lib/docs/DocsStaleness.Tests.ps1` (153 lines) and `tests/scripts/claude-lib/docs/DocsStaleness.Properties.Tests.ps1` (124 lines).

Toolchain on these files: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings (0 findings), parser (0 errors).
