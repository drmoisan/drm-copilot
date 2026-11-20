# QA Gate - Issue #198 adapter-ID collision guard

Timestamp: 2026-06-18T01-11
Scope (touched files):
- tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 (new, test-only)

No production PowerShell files were modified. The previously-fixed
`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` was not changed by this work.

## Toolchain (format -> analyze -> test), scan folders: tests/scripts/claude-runtime, tests/scripts/dev-tools

Tool entry points: repository PoshQC modules
(`scripts/powershell/PoshQC/PoshQC.psd1`: `Invoke-PoshQCFormat`,
`Invoke-PoshQCAnalyze`) and Pester 5.6.1. The canonical `mcp__drm-copilot__*`
PoshQC MCP tools were not available in this execution environment; the
repository module functions that those MCP tools wrap were invoked directly with
identical settings (`scripts/powershell/PoshQC/settings/pssa.settings.psd1`).

### Format
Command: Invoke-PoshQCFormat -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools
EXIT_CODE: 0
Output Summary: All files already formatted; no files changed.

### Analyze (PSScriptAnalyzer)
Command: Invoke-PoshQCAnalyze -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools
EXIT_CODE: 0
Output Summary: 0 findings. (Two warnings on the new file - PSUseBOMForUnicodeEncodedFile
and PSReviewUnusedParameter - were resolved before this gate by removing non-ASCII
characters and making the SourceLabel parameter usage explicit via [string]::Format.)

### Test (Pester 5.6.1)
Command: Invoke-Pester -Path tests/scripts/claude-runtime, tests/scripts/dev-tools
EXIT_CODE: 0
Output Summary: Passed=294 Failed=0 Skipped=2 Total=296. The 2 skips are pre-existing
and unrelated to this change.

## Guard test results (new file)
Command: Invoke-Pester -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: Passed=5 Failed=0 Skipped=0 Total=5.
- [+] detects two sibling It names that differ only by letter case (positive)
- [+] detects a literal -ForEach whose rows differ only by data-value case (positive)
- [+] reports no collision when a literal -ForEach disambiguates rows with a distinct data key (negative)
- [+] skips a non-literal -ForEach argument without raising a collision (negative)
- [+] reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1 (suite scan, negative)

## File-size check
tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1: 495 lines (< 500 limit).

## Helper function (shared code path)
`Get-AdapterIdCollision` is the single detection helper exercised by both the
in-memory fixtures and the repository suite scan. Supporting helpers:
`Get-LiteralArgumentValue`, `ConvertTo-LiteralHashtableRow`,
`Get-LiteralHashtableElement`, `ConvertTo-LiteralDataRow`, `Get-BlockDiscriminator`.

## Delta vs baseline
- PSScriptAnalyzer delta: 0 new findings.
- Pester delta: 0 new failing tests (added 5 new passing tests).
- Production coverage delta: not applicable; test-only change, no production lines modified.
