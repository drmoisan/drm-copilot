# Final QA: Pester with coverage over tests/scripts/claude-lib ([P7-T3])

Timestamp: 2026-11-04T02-25
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib` in one process with the PoshQC coverage configuration; counts read from artifacts/pester/pester-junit.xml and per-file line coverage from artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1033-coverage-summary.ps1)
EXIT_CODE: 0
Output Summary: tests=4139, failures=0, errors=0, skipped=1 (146 suite files). Every new production module of `## Artifact Classification` (including the seven split modules) is present in artifacts/pester/powershell-coverage.xml with line coverage of at least 85%: lowest DocsCSharpTokens 92.43%, highest 100.00% (seven modules). No shortfall; no loop restart. CI: `poshqc / PowerShell QC` (Windows shards).

## Per-file line coverage of the new modules (`.claude/lib/docs/`)

| Module | lines | covered | line coverage % |
|---|---|---|---|
| DocsScannerCommon.psm1 | 179 | 176 | 98.32 |
| DocsTypeScriptTokens.psm1 | 229 | 222 | 96.94 |
| DocsCSharpTokens.psm1 | 185 | 171 | 92.43 |
| DocsTypeScriptSyntax.psm1 | 210 | 209 | 99.52 |
| DocsTypeScriptCliSupport.psm1 | 114 | 114 | 100.00 |
| DocsAnalyzerTypeScriptCli.psm1 | 158 | 151 | 95.57 |
| DocsTypeScriptHttpDeclaration.psm1 | 84 | 84 | 100.00 |
| DocsTypeScriptHttpSupport.psm1 | 152 | 152 | 100.00 |
| DocsAnalyzerTypeScriptHttp.psm1 | 80 | 77 | 96.25 |
| DocsAnalyzerTypeScriptExports.psm1 | 232 | 224 | 96.55 |
| DocsCSharpSyntax.psm1 | 225 | 225 | 100.00 |
| DocsAnalyzerDotnetHttp.psm1 | 174 | 173 | 99.43 |
| DocsAnalyzerDotnetConfig.psm1 | 105 | 104 | 99.05 |
| DocsCSharpMember.psm1 | 115 | 114 | 99.13 |
| DocsAnalyzerDotnetApi.psm1 | 110 | 108 | 98.18 |
| DocsExtensionShape.psm1 | 103 | 103 | 100.00 |
| DocsAnalyzerExtensionImport.psm1 | 195 | 195 | 100.00 |

## 1020 modules in the same run (unchanged except the registry rows)

| Module | lines | covered | line coverage % |
|---|---|---|---|
| DocsAnalyzerRegistry.psm1 (edited: seven rows) | 126 | 126 | 100.00 |
| DocsFinding.psm1 | 88 | 88 | 100.00 |
| DocsJson.psm1 | 102 | 102 | 100.00 |
| DocsProfile.psm1 | 81 | 81 | 100.00 |
| DocsProfileCommands.psm1 | 69 | 67 | 97.10 |
| DocsSchema.psm1 | 127 | 127 | 100.00 |
| DocsSchemaWalk.psm1 | 87 | 87 | 100.00 |
| DocsSurface.psm1 | 130 | 130 | 100.00 |
| Invoke-DocsCommand.ps1 | 150 | 131 | 87.33 |

Overall line coverage of this folder-scoped run (coverage population is the whole `config/poshqc-coverage.json` set, exercised only by the `tests/scripts/claude-lib` suites): 39.55% (10405 of 26308); the repository-wide figure is read from the full `tests/scripts` run of [P7-T6].

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib` (146 suite files) | 4139 | 0 | 0 | 1 |
