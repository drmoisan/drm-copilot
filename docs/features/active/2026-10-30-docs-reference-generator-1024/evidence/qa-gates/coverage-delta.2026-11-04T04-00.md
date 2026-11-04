# Coverage Delta (issue 1024)

Timestamp: 2026-11-04T04-00
Task: [P9-T4]
Command: comparison of the [P0-T7] baseline (evidence/baseline/pester-baseline.2026-11-04T01-46.md) with the [P9-T3] coverage (evidence/qa-gates/coverage-final.2026-11-04T04-00.md); both read from artifacts/pester/powershell-coverage.xml produced by Invoke-PoshQCTest over the same scan set
EXIT_CODE: 0
Output Summary: No pre-existing LIB file decreased. 14 baseline files unchanged at 100%; DocsProfileCommands.psm1 unchanged at 97.3%; the changed Invoke-DocsCommand.ps1 rose from 87.42% (132/151) to 87.74% (136/155). New-code coverage is 100% for each of the six NEW-MODULES files (709/709 lines combined).

## Pre-existing LIB files (baseline at [P0-T7])

| File | Baseline | Post-change | Change |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 100% (119/119) | 100% (119/119) | 0 |
| `.claude/lib/docs/DocsFinding.psm1` | 100% (88/88) | 100% (88/88) | 0 |
| `.claude/lib/docs/DocsJson.psm1` | 100% (102/102) | 100% (102/102) | 0 |
| `.claude/lib/docs/DocsPageCheck.psm1` | 100% (159/159) | 100% (159/159) | 0 |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | 100% (54/54) | 100% (54/54) | 0 |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | 100% (183/183) | 100% (183/183) | 0 |
| `.claude/lib/docs/DocsPageLinks.psm1` | 100% (114/114) | 100% (114/114) | 0 |
| `.claude/lib/docs/DocsPageMarkdown.psm1` | 100% (102/102) | 100% (102/102) | 0 |
| `.claude/lib/docs/DocsPageMetadata.psm1` | 100% (109/109) | 100% (109/109) | 0 |
| `.claude/lib/docs/DocsPageOrphans.psm1` | 100% (28/28) | 100% (28/28) | 0 |
| `.claude/lib/docs/DocsProfile.psm1` | 100% (81/81) | 100% (81/81) | 0 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 97.3% (72/74) | 97.3% (72/74) | 0 |
| `.claude/lib/docs/DocsSchema.psm1` | 100% (129/129) | 100% (129/129) | 0 |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 100% (87/87) | 100% (87/87) | 0 |
| `.claude/lib/docs/DocsSurface.psm1` | 100% (130/130) | 100% (130/130) | 0 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (changed) | 87.42% (132/151) | 87.74% (136/155) | +0.32 |

The `Invoke-DocsCommand.ps1` line total grew by 4 between the two runs: one line is the 1024 `generate-reference` row and the others are the 1023 rows that arrived with the integration merge after [P0-T7].

## 1023 modules (added by the integration merge after [P0-T7]; no 1024 baseline)

Recorded for completeness; these files are not 1024 code and were not in the [P0-T7] baseline. Post-change values: `DocsCoverageReport.psm1` 100% (77/77), `DocsEvidencePins.psm1` 96.84% (92/95), `DocsLedger.psm1` 98.82% (167/169), `DocsLedgerCommands.psm1` 99.13% (343/346), `DocsLedgerMutation.psm1` 98.33% (59/60), `DocsLedgerRules.psm1` 98.94% (93/94), `DocsParity.psm1` 98.92% (183/185), `DocsReceipt.psm1` 100% (95/95), `DocsStaleness.psm1` 100% (46/46), `DocsValidation.psm1` 98.72% (154/156).

## New-code coverage (NEW-MODULES)

| File | Baseline | Post-change (new code) |
|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | not present | 100% (156/156) |
| `.claude/lib/docs/DocsReferenceRender.psm1` | not present | 100% (49/49) |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | not present | 100% (169/169) |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | not present | 100% (77/77) |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | not present | 100% (178/178) |
| `.claude/lib/docs/DocsReferenceReport.psm1` | not present | 100% (80/80) |
