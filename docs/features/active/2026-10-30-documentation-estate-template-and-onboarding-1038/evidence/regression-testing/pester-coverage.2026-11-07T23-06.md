# Final Pester gate, cycle 1 (parallel, with coverage) ([P4-T4])

Timestamp: 2026-11-07T23-06
Command: sh SCRATCH/issue-1038-pester-parallel.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree>), then sh SCRATCH/issue-1038-pester-summary-c1.sh reading artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest ExitCode 0 (launcher exit 0), 8 workers, every shard exit 0, wall clock 818.84 s; run started 2026-11-07T22-52 and the merged JUnit and coverage files were written by this run (modified 2026-11-07T23-05 UTC). JUnit: 19342 test cases, 19332 passed, 0 failed, 10 skipped (root attributes tests=19342 failures=0 errors=0 disabled=10). Failing tests: none. Repo-wide line coverage 95.45% (34368/36005). 72 files under .claude/lib/docs/ are listed below.

LAUNCHER-EXIT: 0 (from the returned ExitCode)
PASSED: 19332
FAILED: 0
SKIPPED: 10
FAILING-TESTS: none

Per-suite (passed / failed / per-file `time` of the `testsuite` element):

- DocumentationEstateEpicTemplate.Tests.ps1: 19 passed, 0 failed, time 0.795 s
- DocumentationEstateOnboarding.Tests.ps1: 13 passed, 0 failed, time 1.172 s
- EndToEndDocumentationEstate.Tests.ps1: 10 passed, 0 failed, time 82.588 s

The test count rose by one against the previous final run (19341), which is the new positive control `fails with EPIC_MANIFEST_ISSUE_NUM_INVALID for a non-integer issue_num`. No single-process, seeded-shuffle, reversed-order or ordering-comparison run was made (owner decision of 2026-11-07).

COVERAGE: .claude/lib/docs/DocsAnalyzerArchitecture.psm1 | 100% (103/103)
COVERAGE: .claude/lib/docs/DocsAnalyzerConfigFiles.psm1 | 99.25% (132/133)
COVERAGE: .claude/lib/docs/DocsAnalyzerDotnetApi.psm1 | 98.2% (109/111)
COVERAGE: .claude/lib/docs/DocsAnalyzerDotnetConfig.psm1 | 99.06% (105/106)
COVERAGE: .claude/lib/docs/DocsAnalyzerDotnetHttp.psm1 | 99.45% (181/182)
COVERAGE: .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | 100% (195/195)
COVERAGE: .claude/lib/docs/DocsAnalyzerPythonApi.psm1 | 100% (151/151)
COVERAGE: .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | 100% (119/119)
COVERAGE: .claude/lib/docs/DocsAnalyzerPythonHttp.psm1 | 100% (137/137)
COVERAGE: .claude/lib/docs/DocsAnalyzerPythonNative.psm1 | 100% (93/93)
COVERAGE: .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 100% (135/135)
COVERAGE: .claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1 | 95.09% (155/163)
COVERAGE: .claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1 | 96.58% (226/234)
COVERAGE: .claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1 | 95.12% (78/82)
COVERAGE: .claude/lib/docs/DocsCompleteGate.psm1 | 100% (38/38)
COVERAGE: .claude/lib/docs/DocsCoverageReport.psm1 | 100% (78/78)
COVERAGE: .claude/lib/docs/DocsCSharpMember.psm1 | 99.13% (114/115)
COVERAGE: .claude/lib/docs/DocsCSharpSyntax.psm1 | 100% (229/229)
COVERAGE: .claude/lib/docs/DocsCSharpTokens.psm1 | 92.71% (178/192)
COVERAGE: .claude/lib/docs/DocsEvidencePins.psm1 | 96.84% (92/95)
COVERAGE: .claude/lib/docs/DocsExtensionShape.psm1 | 100% (104/104)
COVERAGE: .claude/lib/docs/DocsFinding.psm1 | 100% (88/88)
COVERAGE: .claude/lib/docs/DocsInventory.psm1 | 100% (121/121)
COVERAGE: .claude/lib/docs/DocsInventorySnapshot.psm1 | 100% (93/93)
COVERAGE: .claude/lib/docs/DocsJson.psm1 | 100% (103/103)
COVERAGE: .claude/lib/docs/DocsJsonSchemaKeys.psm1 | 100% (140/140)
COVERAGE: .claude/lib/docs/DocsLedger.psm1 | 98.27% (170/173)
COVERAGE: .claude/lib/docs/DocsLedgerCommands.psm1 | 99.14% (345/348)
COVERAGE: .claude/lib/docs/DocsLedgerMutation.psm1 | 98.39% (61/62)
COVERAGE: .claude/lib/docs/DocsLedgerRules.psm1 | 98.95% (94/95)
COVERAGE: .claude/lib/docs/DocsPageCheck.psm1 | 100% (160/160)
COVERAGE: .claude/lib/docs/DocsPageDiataxis.psm1 | 100% (54/54)
COVERAGE: .claude/lib/docs/DocsPageFrontMatter.psm1 | 100% (189/189)
COVERAGE: .claude/lib/docs/DocsPageLinks.psm1 | 100% (118/118)
COVERAGE: .claude/lib/docs/DocsPageMarkdown.psm1 | 100% (109/109)
COVERAGE: .claude/lib/docs/DocsPageMetadata.psm1 | 100% (111/111)
COVERAGE: .claude/lib/docs/DocsPageOrphans.psm1 | 100% (28/28)
COVERAGE: .claude/lib/docs/DocsParity.psm1 | 98.92% (184/186)
COVERAGE: .claude/lib/docs/DocsProfile.psm1 | 100% (81/81)
COVERAGE: .claude/lib/docs/DocsProfileCommands.psm1 | 97.33% (73/75)
COVERAGE: .claude/lib/docs/DocsPythonBindings.psm1 | 100% (166/166)
COVERAGE: .claude/lib/docs/DocsPythonCliArgparse.psm1 | 100% (130/130)
COVERAGE: .claude/lib/docs/DocsPythonCliClick.psm1 | 100% (162/162)
COVERAGE: .claude/lib/docs/DocsPythonCliTyper.psm1 | 100% (153/153)
COVERAGE: .claude/lib/docs/DocsPythonHttpSites.psm1 | 100% (132/132)
COVERAGE: .claude/lib/docs/DocsPythonNativeProtocol.psm1 | 100% (132/132)
COVERAGE: .claude/lib/docs/DocsPythonSyntax.psm1 | 99.45% (180/181)
COVERAGE: .claude/lib/docs/DocsPythonTokens.psm1 | 100% (151/151)
COVERAGE: .claude/lib/docs/DocsReceipt.psm1 | 100% (95/95)
COVERAGE: .claude/lib/docs/DocsReferenceFrontMatter.psm1 | 100% (90/90)
COVERAGE: .claude/lib/docs/DocsReferenceMarkers.psm1 | 100% (175/175)
COVERAGE: .claude/lib/docs/DocsReferencePlan.psm1 | 100% (159/159)
COVERAGE: .claude/lib/docs/DocsReferenceRender.psm1 | 100% (49/49)
COVERAGE: .claude/lib/docs/DocsReferenceReport.psm1 | 100% (80/80)
COVERAGE: .claude/lib/docs/DocsReferenceWriter.psm1 | 100% (178/178)
COVERAGE: .claude/lib/docs/DocsScannerCommon.psm1 | 98.34% (178/181)
COVERAGE: .claude/lib/docs/DocsSchema.psm1 | 100% (132/132)
COVERAGE: .claude/lib/docs/DocsSchemaWalk.psm1 | 100% (87/87)
COVERAGE: .claude/lib/docs/DocsSourceText.psm1 | 100% (117/117)
COVERAGE: .claude/lib/docs/DocsStaleness.psm1 | 100% (46/46)
COVERAGE: .claude/lib/docs/DocsSurface.psm1 | 99.24% (130/131)
COVERAGE: .claude/lib/docs/DocsSurfaceDelta.psm1 | 100% (70/70)
COVERAGE: .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | 97.33% (73/75)
COVERAGE: .claude/lib/docs/DocsTomlKeys.psm1 | 99.46% (185/186)
COVERAGE: .claude/lib/docs/DocsTypeScriptCliSupport.psm1 | 100% (120/120)
COVERAGE: .claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1 | 100% (89/89)
COVERAGE: .claude/lib/docs/DocsTypeScriptHttpSupport.psm1 | 100% (154/154)
COVERAGE: .claude/lib/docs/DocsTypeScriptSyntax.psm1 | 99.07% (213/215)
COVERAGE: .claude/lib/docs/DocsTypeScriptTokens.psm1 | 97.05% (230/237)
COVERAGE: .claude/lib/docs/DocsValidation.psm1 | 98.72% (154/156)
COVERAGE: .claude/lib/docs/DocsYamlKeys.psm1 | 99.35% (154/155)
COVERAGE: .claude/lib/docs/Invoke-DocsCommand.ps1 | 89.56% (163/182)
