# Coverage delta ([P7-T7])

Timestamp: 2026-11-04T03-22
Command: figures read from `evidence/baseline/baseline-pester-coverage.2026-11-03T22-12.md` ([P0-T8], `Invoke-PoshQCTest` over `tests/scripts`), `evidence/regression-testing/isolation-single-process.2026-11-04T03-22.md` ([P7-T6], the same command on the final tree) and `evidence/qa-gates/qa-pester-coverage.2026-11-04T03-01.md` ([P7-T3], `Invoke-PoshQCTest` over `tests/scripts/claude-lib`), each taken from artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1033-coverage-summary.ps1 at that run
EXIT_CODE: 0
Output Summary: overall line coverage 92.64% (baseline) -> 93.21% (post-change), +0.57 points; every 1020 module keeps its baseline figure; every new module is at least 85% (lowest DocsCSharpTokens 92.43%, highest 100.00%). No value below its floor; no branch figure is recorded (Pester measures none). Disposition: PASS.

## Overall line coverage (full `tests/scripts` run)

| Run | lines | covered | line coverage % |
|---|---|---|---|
| baseline [P0-T8] | 23651 | 21910 | 92.64 |
| post-change [P7-T6] | 26308 | 24523 | 93.21 |
| delta | +2657 | +2613 | +0.57 |

## 1020 modules before and after (`.claude/lib/docs/`)

| Module | baseline % | post-change % ([P7-T6]) | change |
|---|---|---|---|
| DocsAnalyzerRegistry.psm1 (edited: seven rows) | 100.00 (119/119) | 100.00 (126/126) | 0.00 |
| DocsFinding.psm1 | 100.00 | 100.00 | 0.00 |
| DocsJson.psm1 | 100.00 | 100.00 | 0.00 |
| DocsProfile.psm1 | 100.00 | 100.00 | 0.00 |
| DocsProfileCommands.psm1 | 97.10 | 97.10 | 0.00 |
| DocsSchema.psm1 | 100.00 | 100.00 | 0.00 |
| DocsSchemaWalk.psm1 | 100.00 | 100.00 | 0.00 |
| DocsSurface.psm1 | 100.00 | 100.00 | 0.00 |
| Invoke-DocsCommand.ps1 | 87.33 | 87.33 | 0.00 |

## New modules ([P7-T3]; identical figures in the [P7-T6] run)

| Module | lines | covered | line coverage % | floor 85% |
|---|---|---|---|---|
| DocsScannerCommon.psm1 | 179 | 176 | 98.32 | PASS |
| DocsTypeScriptTokens.psm1 | 229 | 222 | 96.94 | PASS |
| DocsCSharpTokens.psm1 | 185 | 171 | 92.43 | PASS |
| DocsTypeScriptSyntax.psm1 | 210 | 209 | 99.52 | PASS |
| DocsTypeScriptCliSupport.psm1 | 114 | 114 | 100.00 | PASS |
| DocsAnalyzerTypeScriptCli.psm1 | 158 | 151 | 95.57 | PASS |
| DocsTypeScriptHttpDeclaration.psm1 | 84 | 84 | 100.00 | PASS |
| DocsTypeScriptHttpSupport.psm1 | 152 | 152 | 100.00 | PASS |
| DocsAnalyzerTypeScriptHttp.psm1 | 80 | 77 | 96.25 | PASS |
| DocsAnalyzerTypeScriptExports.psm1 | 232 | 224 | 96.55 | PASS |
| DocsCSharpSyntax.psm1 | 225 | 225 | 100.00 | PASS |
| DocsAnalyzerDotnetHttp.psm1 | 174 | 173 | 99.43 | PASS |
| DocsAnalyzerDotnetConfig.psm1 | 105 | 104 | 99.05 | PASS |
| DocsCSharpMember.psm1 | 115 | 114 | 99.13 | PASS |
| DocsAnalyzerDotnetApi.psm1 | 110 | 108 | 98.18 | PASS |
| DocsExtensionShape.psm1 | 103 | 103 | 100.00 | PASS |
| DocsAnalyzerExtensionImport.psm1 | 195 | 195 | 100.00 | PASS |

New-code baseline: not present (no 1033 module existed at [P0-T8]); new-code coverage is the per-module table above (2650 lines, 2602 covered, 98.19% over the 17 modules).
