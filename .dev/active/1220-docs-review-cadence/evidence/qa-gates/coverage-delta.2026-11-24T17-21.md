# Coverage Delta (P4-T3)

Timestamp: 2026-11-24T17-21
Command: compare FEATURE/evidence/baseline/pester.2026-11-24T12-07.md (lexicographically greatest baseline/pester.*.md) with FEATURE/evidence/qa-gates/pester.2026-11-24T17-21.md (lexicographically greatest qa-gates/pester.*.md)
EXIT_CODE: 0
Output Summary: every changed file is at or above 85% line coverage with no drop against the Phase 0 baseline; the new DocsReviewCadence.psm1 is at 100% (threshold only). Repo-wide 96.88% to 96.89%. Tests 29936 to 30098 total, 0 failures in both runs. Result PASS.

| File | Baseline | Post-change | >= 85% | No drop | Result |
|---|---|---|---|---|---|
| .claude/lib/docs/DocsReviewCadence.psm1 | N/A - new file, no pre-change run | 100% (76/76) | yes | N/A | PASS |
| .claude/lib/docs/DocsPageMetadata.psm1 | 100% (111/111) | 100% (128/128) | yes | yes | PASS |
| .claude/lib/docs/DocsPageFrontMatter.psm1 | 100% (189/189) | 100% (189/189) | yes | yes | PASS |
| .claude/lib/docs/DocsValidation.psm1 | 98.74% (157/159) | 98.8% (164/166) | yes | yes | PASS |
| .claude/lib/docs/DocsValidateCommands.psm1 | 100% (105/105) | 100% (108/108) | yes | yes | PASS |
| .claude/lib/docs/DocsReferenceFrontMatter.psm1 | 100% (90/90) | 100% (91/91) | yes | yes | PASS |
| Repo-wide | 96.88% | 96.89% | yes | yes | PASS |

New and changed-line coverage: the missed-line count of every changed module is unchanged from the baseline (0, or 2 for DocsValidation.psm1 in both runs) while the covered counts rose with the added lines (DocsPageMetadata +17, DocsValidation +7, DocsValidateCommands +3, DocsReferenceFrontMatter +1), so no added executable line is reported as missed. Unchanged reference files: DocsStaleness.psm1 100% (46/46) and DocsCompleteGate.psm1 100% (39/39) in both runs. PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
