# Final QA: Pester with coverage over tests/scripts/claude-lib, loop re-run after the [P7-T9] hygiene edit ([P7-T3])

Timestamp: 2026-11-04T03-01
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib (`Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib` in one process with the PoshQC coverage configuration; counts read from artifacts/pester/pester-junit.xml and per-file line coverage from artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1033-coverage-summary.ps1)
EXIT_CODE: 0
Output Summary: tests=4139, failures=0, errors=0, skipped=1 (146 suite files). Every new production module is present in the coverage XML with line coverage of at least 85%: lowest DocsCSharpTokens 92.43%, highest 100.00%. Identical to the first pass `qa-pester-coverage.2026-11-04T02-25.md` (the hygiene edit changed a comment in a test support module only). CI: `poshqc / PowerShell QC` (Windows shards).

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

1020 modules in the same run: DocsAnalyzerRegistry 100.00 (126/126), DocsFinding 100.00, DocsJson 100.00, DocsProfile 100.00, DocsProfileCommands 97.10, DocsSchema 100.00, DocsSchemaWalk 100.00, DocsSurface 100.00, Invoke-DocsCommand 87.33. Folder-scoped overall figure 39.55% (10405 of 26308; the coverage population is the whole `config/poshqc-coverage.json` set); the repository-wide figure comes from the [P7-T6] run.

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib` (146 suite files) | 4139 | 0 | 0 | 1 |
