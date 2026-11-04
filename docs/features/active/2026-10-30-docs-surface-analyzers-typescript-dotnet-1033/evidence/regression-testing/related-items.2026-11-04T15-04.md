# Related items: exact-case tables and single-source constants ([P4-T5])

Timestamp: 2026-11-04T15-04
Command: sh SCRATCH/issue-1033-pester-files.sh with tests/scripts/claude-lib/docs/DocsExtensionShape.Tests.ps1, DocsAnalyzerExtensionImport.Tests.ps1, DocsScannerContract.Tests.ps1, DocsAnalyzerDotnetHttp.Tests.ps1, Docs.Manifest.Tests.ps1, tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 (one `Invoke-Pester` process, `Run.PassThru`; counts from the result object)
EXIT_CODE: 0
Output Summary: Total=177, Passed=177, Failed=0, Skipped=0, failed containers 0. Includes `Describe 'Get-DocsExtensionManifestIdentity'`, `It 'takes the manifest schema URN and artifact kind from DocsExtensionShape and carries no copy of either literal'`, and `It 'recognizes verb attributes and Map* methods by their exact case and ignores a wrong-case name'`. CI: `poshqc / PowerShell QC`.

## Targeted runs before this one

| Suite | Total | Passed | Failed |
|---|---|---|---|
| `DocsAnalyzerDotnetHttp.Tests.ps1` after [P3-T2] | 11 | 11 | 0 |
| `DocsExtensionShape.Tests.ps1` after [P4-T2] | 38 | 38 | 0 |
| `DocsAnalyzerExtensionImport.Tests.ps1` after [P4-T3] | 60 | 60 | 0 |

Line counts: `DocsAnalyzerDotnetHttp.psm1` 353 physical lines, `DocsExtensionShape.psm1` 286, `DocsAnalyzerExtensionImport.psm1` 491 (unchanged from `CYCLE_HEAD`).
