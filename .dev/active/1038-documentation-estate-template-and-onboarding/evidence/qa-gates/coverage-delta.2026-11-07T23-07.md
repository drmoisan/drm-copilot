# Coverage delta, cycle 1 final gate against PHASE0-PESTER ([P4-T5])

Timestamp: 2026-11-07T23-07
Command: sh SCRATCH/issue-1038-pester-summary-c1.sh (PowerShell 7: SCRATCH/issue-1038-delta.ps1 comparing the COVERAGE rows of evidence/baseline/pester-coverage.2026-11-07T21-04.md with those of evidence/regression-testing/pester-coverage.2026-11-07T23-06.md)
EXIT_CODE: 0
Output Summary: 72 .claude/lib/docs/ files compared; 0 negative deltas, 0 missing figures, every per-file delta 0. Repo-wide line coverage 95.45% (34368/36005) at baseline and post-change, delta 0.

Baseline: evidence/baseline/pester-coverage.2026-11-07T21-04.md (PHASE0-PESTER: 19300 tests, 19290 passed, 0 failed, 10 skipped).
Post-change: evidence/regression-testing/pester-coverage.2026-11-07T23-06.md (19342 tests, 19332 passed, 0 failed, 10 skipped).

- Production lines changed: none. The cycle edits three test files under tests/scripts/claude-lib/docs/, one onboarding page and feature-folder documents; no file under .claude/lib/docs/ changed.
- Failing tests absent from PHASE0-PESTER: none (both runs have 0 failing tests).
- New or changed code coverage: not applicable; no production file changed. The changed files are test files outside the coverage denominator.
- Repo-wide: baseline 95.45% (34368/36005), post-change 95.45% (34368/36005), delta 0.
- NEGATIVE-DELTAS: 0
- MISSING-FIGURES: 0

## Per-file deltas (.claude/lib/docs/)

- .claude/lib/docs/DocsAnalyzerArchitecture.psm1 | baseline 100% (103/103) | post-change 100% (103/103) | delta 0
- .claude/lib/docs/DocsAnalyzerConfigFiles.psm1 | baseline 99.25% (132/133) | post-change 99.25% (132/133) | delta 0
- .claude/lib/docs/DocsAnalyzerDotnetApi.psm1 | baseline 98.2% (109/111) | post-change 98.2% (109/111) | delta 0
- .claude/lib/docs/DocsAnalyzerDotnetConfig.psm1 | baseline 99.06% (105/106) | post-change 99.06% (105/106) | delta 0
- .claude/lib/docs/DocsAnalyzerDotnetHttp.psm1 | baseline 99.45% (181/182) | post-change 99.45% (181/182) | delta 0
- .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | baseline 100% (195/195) | post-change 100% (195/195) | delta 0
- .claude/lib/docs/DocsAnalyzerPythonApi.psm1 | baseline 100% (151/151) | post-change 100% (151/151) | delta 0
- .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | baseline 100% (119/119) | post-change 100% (119/119) | delta 0
- .claude/lib/docs/DocsAnalyzerPythonHttp.psm1 | baseline 100% (137/137) | post-change 100% (137/137) | delta 0
- .claude/lib/docs/DocsAnalyzerPythonNative.psm1 | baseline 100% (93/93) | post-change 100% (93/93) | delta 0
- .claude/lib/docs/DocsAnalyzerRegistry.psm1 | baseline 100% (135/135) | post-change 100% (135/135) | delta 0
- .claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1 | baseline 95.09% (155/163) | post-change 95.09% (155/163) | delta 0
- .claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1 | baseline 96.58% (226/234) | post-change 96.58% (226/234) | delta 0
- .claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1 | baseline 95.12% (78/82) | post-change 95.12% (78/82) | delta 0
- .claude/lib/docs/DocsCompleteGate.psm1 | baseline 100% (38/38) | post-change 100% (38/38) | delta 0
- .claude/lib/docs/DocsCoverageReport.psm1 | baseline 100% (78/78) | post-change 100% (78/78) | delta 0
- .claude/lib/docs/DocsCSharpMember.psm1 | baseline 99.13% (114/115) | post-change 99.13% (114/115) | delta 0
- .claude/lib/docs/DocsCSharpSyntax.psm1 | baseline 100% (229/229) | post-change 100% (229/229) | delta 0
- .claude/lib/docs/DocsCSharpTokens.psm1 | baseline 92.71% (178/192) | post-change 92.71% (178/192) | delta 0
- .claude/lib/docs/DocsEvidencePins.psm1 | baseline 96.84% (92/95) | post-change 96.84% (92/95) | delta 0
- .claude/lib/docs/DocsExtensionShape.psm1 | baseline 100% (104/104) | post-change 100% (104/104) | delta 0
- .claude/lib/docs/DocsFinding.psm1 | baseline 100% (88/88) | post-change 100% (88/88) | delta 0
- .claude/lib/docs/DocsInventory.psm1 | baseline 100% (121/121) | post-change 100% (121/121) | delta 0
- .claude/lib/docs/DocsInventorySnapshot.psm1 | baseline 100% (93/93) | post-change 100% (93/93) | delta 0
- .claude/lib/docs/DocsJson.psm1 | baseline 100% (103/103) | post-change 100% (103/103) | delta 0
- .claude/lib/docs/DocsJsonSchemaKeys.psm1 | baseline 100% (140/140) | post-change 100% (140/140) | delta 0
- .claude/lib/docs/DocsLedger.psm1 | baseline 98.27% (170/173) | post-change 98.27% (170/173) | delta 0
- .claude/lib/docs/DocsLedgerCommands.psm1 | baseline 99.14% (345/348) | post-change 99.14% (345/348) | delta 0
- .claude/lib/docs/DocsLedgerMutation.psm1 | baseline 98.39% (61/62) | post-change 98.39% (61/62) | delta 0
- .claude/lib/docs/DocsLedgerRules.psm1 | baseline 98.95% (94/95) | post-change 98.95% (94/95) | delta 0
- .claude/lib/docs/DocsPageCheck.psm1 | baseline 100% (160/160) | post-change 100% (160/160) | delta 0
- .claude/lib/docs/DocsPageDiataxis.psm1 | baseline 100% (54/54) | post-change 100% (54/54) | delta 0
- .claude/lib/docs/DocsPageFrontMatter.psm1 | baseline 100% (189/189) | post-change 100% (189/189) | delta 0
- .claude/lib/docs/DocsPageLinks.psm1 | baseline 100% (118/118) | post-change 100% (118/118) | delta 0
- .claude/lib/docs/DocsPageMarkdown.psm1 | baseline 100% (109/109) | post-change 100% (109/109) | delta 0
- .claude/lib/docs/DocsPageMetadata.psm1 | baseline 100% (111/111) | post-change 100% (111/111) | delta 0
- .claude/lib/docs/DocsPageOrphans.psm1 | baseline 100% (28/28) | post-change 100% (28/28) | delta 0
- .claude/lib/docs/DocsParity.psm1 | baseline 98.92% (184/186) | post-change 98.92% (184/186) | delta 0
- .claude/lib/docs/DocsProfile.psm1 | baseline 100% (81/81) | post-change 100% (81/81) | delta 0
- .claude/lib/docs/DocsProfileCommands.psm1 | baseline 97.33% (73/75) | post-change 97.33% (73/75) | delta 0
- .claude/lib/docs/DocsPythonBindings.psm1 | baseline 100% (166/166) | post-change 100% (166/166) | delta 0
- .claude/lib/docs/DocsPythonCliArgparse.psm1 | baseline 100% (130/130) | post-change 100% (130/130) | delta 0
- .claude/lib/docs/DocsPythonCliClick.psm1 | baseline 100% (162/162) | post-change 100% (162/162) | delta 0
- .claude/lib/docs/DocsPythonCliTyper.psm1 | baseline 100% (153/153) | post-change 100% (153/153) | delta 0
- .claude/lib/docs/DocsPythonHttpSites.psm1 | baseline 100% (132/132) | post-change 100% (132/132) | delta 0
- .claude/lib/docs/DocsPythonNativeProtocol.psm1 | baseline 100% (132/132) | post-change 100% (132/132) | delta 0
- .claude/lib/docs/DocsPythonSyntax.psm1 | baseline 99.45% (180/181) | post-change 99.45% (180/181) | delta 0
- .claude/lib/docs/DocsPythonTokens.psm1 | baseline 100% (151/151) | post-change 100% (151/151) | delta 0
- .claude/lib/docs/DocsReceipt.psm1 | baseline 100% (95/95) | post-change 100% (95/95) | delta 0
- .claude/lib/docs/DocsReferenceFrontMatter.psm1 | baseline 100% (90/90) | post-change 100% (90/90) | delta 0
- .claude/lib/docs/DocsReferenceMarkers.psm1 | baseline 100% (175/175) | post-change 100% (175/175) | delta 0
- .claude/lib/docs/DocsReferencePlan.psm1 | baseline 100% (159/159) | post-change 100% (159/159) | delta 0
- .claude/lib/docs/DocsReferenceRender.psm1 | baseline 100% (49/49) | post-change 100% (49/49) | delta 0
- .claude/lib/docs/DocsReferenceReport.psm1 | baseline 100% (80/80) | post-change 100% (80/80) | delta 0
- .claude/lib/docs/DocsReferenceWriter.psm1 | baseline 100% (178/178) | post-change 100% (178/178) | delta 0
- .claude/lib/docs/DocsScannerCommon.psm1 | baseline 98.34% (178/181) | post-change 98.34% (178/181) | delta 0
- .claude/lib/docs/DocsSchema.psm1 | baseline 100% (132/132) | post-change 100% (132/132) | delta 0
- .claude/lib/docs/DocsSchemaWalk.psm1 | baseline 100% (87/87) | post-change 100% (87/87) | delta 0
- .claude/lib/docs/DocsSourceText.psm1 | baseline 100% (117/117) | post-change 100% (117/117) | delta 0
- .claude/lib/docs/DocsStaleness.psm1 | baseline 100% (46/46) | post-change 100% (46/46) | delta 0
- .claude/lib/docs/DocsSurface.psm1 | baseline 99.24% (130/131) | post-change 99.24% (130/131) | delta 0
- .claude/lib/docs/DocsSurfaceDelta.psm1 | baseline 100% (70/70) | post-change 100% (70/70) | delta 0
- .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | baseline 97.33% (73/75) | post-change 97.33% (73/75) | delta 0
- .claude/lib/docs/DocsTomlKeys.psm1 | baseline 99.46% (185/186) | post-change 99.46% (185/186) | delta 0
- .claude/lib/docs/DocsTypeScriptCliSupport.psm1 | baseline 100% (120/120) | post-change 100% (120/120) | delta 0
- .claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1 | baseline 100% (89/89) | post-change 100% (89/89) | delta 0
- .claude/lib/docs/DocsTypeScriptHttpSupport.psm1 | baseline 100% (154/154) | post-change 100% (154/154) | delta 0
- .claude/lib/docs/DocsTypeScriptSyntax.psm1 | baseline 99.07% (213/215) | post-change 99.07% (213/215) | delta 0
- .claude/lib/docs/DocsTypeScriptTokens.psm1 | baseline 97.05% (230/237) | post-change 97.05% (230/237) | delta 0
- .claude/lib/docs/DocsValidation.psm1 | baseline 98.72% (154/156) | post-change 98.72% (154/156) | delta 0
- .claude/lib/docs/DocsYamlKeys.psm1 | baseline 99.35% (154/155) | post-change 99.35% (154/155) | delta 0
- .claude/lib/docs/Invoke-DocsCommand.ps1 | baseline 89.56% (163/182) | post-change 89.56% (163/182) | delta 0
