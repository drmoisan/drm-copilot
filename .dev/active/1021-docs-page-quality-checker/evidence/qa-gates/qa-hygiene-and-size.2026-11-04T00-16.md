# QA Test Hygiene and File Size - Issue #1021

Timestamp: 2026-11-04T00-16
Task: [P6-T10]
Command: `sh SCRATCH/issue-1021-hygiene.sh` (in `tests/scripts/claude-lib/docs`, for each token `grep -r -i -F -e <token>` over the 14 suites listed below, counted with `wc -l`); `pwsh -NoProfile -Command "@(Get-Content -LiteralPath <module>).Count"` for each of the seven new modules
EXIT_CODE: 0
Output Summary: 0 matches for each of `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` and `$env:TEMP` in 14 suites; the seven new modules have 263, 422, 303, 335, 177, 102 and 428 logical lines, each at most 500. Result: PASS.

## Suites scanned (14)

The ten 1021 suites `DocsPageMarkdown.Tests.ps1`, `DocsPageFrontMatter.Tests.ps1`, `DocsPageMetadata.Tests.ps1`, `DocsPageMetadataSchema.Tests.ps1`, `DocsPageLinks.Tests.ps1`, `DocsPageDiataxis.Tests.ps1`, `DocsPageOrphans.Tests.ps1`, `DocsPageCheck.Tests.ps1`, `DocsPageImportIsolation.Tests.ps1`, `DocsPageTemplates.Tests.ps1`, and the four 1020 suites edited by this feature, `DocsSchema.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1` ([P4-T3]) and `DocsProfileCommands.Tests.ps1` ([P4-T5]).

## Match counts

| Token | Matches |
|---|---|
| `New-TemporaryFile` | 0 |
| `TestDrive` | 0 |
| `GetTempPath` | 0 |
| `GetTempFileName` | 0 |
| `$env:TEMP` | 0 |

## Logical line counts (`@(Get-Content -LiteralPath <path>).Count`)

| Module | Lines | At most 500 |
|---|---|---|
| `DocsPageMarkdown.psm1` | 263 | yes |
| `DocsPageFrontMatter.psm1` | 422 | yes |
| `DocsPageMetadata.psm1` | 303 | yes |
| `DocsPageLinks.psm1` | 335 | yes |
| `DocsPageDiataxis.psm1` | 177 | yes |
| `DocsPageOrphans.psm1` | 102 | yes |
| `DocsPageCheck.psm1` | 428 | yes |

Test files (for the reviewer's file-size tiers): `DocsPageCheck.Tests.ps1` 696 (below the 700-line advisory tier), `DocsPageFrontMatter.Tests.ps1` 522, every other 1021 suite at most 314. No file exceeds the 800-line hard limit.
