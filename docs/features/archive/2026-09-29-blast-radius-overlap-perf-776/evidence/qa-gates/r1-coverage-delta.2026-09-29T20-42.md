# Remediation Coverage Threshold and Delta for AC-5 (P2-T9)

Timestamp: 2026-09-29T20-42
Command: derived from evidence/baseline/full-suite-pester.2026-09-29T19-31.md (ORIGINAL-BASELINE P0-T12), evidence/remediation-baseline/r1-blast-radius-pester-coverage.2026-09-29T20-17.md (P0-T10), evidence/qa-gates/r1-blast-radius-pester-coverage.2026-09-29T20-29.md (P2-T3), and evidence/qa-gates/r1-full-suite-pester.2026-09-29T20-41.md (P2-T8); no new command run.
EXIT_CODE: 0
Output Summary:

| File | Baseline LinePercent (source) | P2-T8 LinePercent | P2-T3 LinePercent | P2-T8 changed lines vs BASE_SHA 43c9e95e |
| --- | --- | --- | --- | --- |
| .claude/lib/blast-radius/BlastRadiusGlob.psm1 | 100 (ORIGINAL-BASELINE P0-T12, 70/70) | 100 (77/77) | 100 (77/77) | ChangedLines=51, AnalyzedChangedLines=25, CoveredChangedLines=25, ChangedLinePercent=100 |
| .claude/lib/blast-radius/BlastRadiusConflict.psm1 | 97.67 (ORIGINAL-BASELINE P0-T12, 42/43) | 97.94 (95/97) | 97.94 (95/97) | ChangedLines=193, AnalyzedChangedLines=63, CoveredChangedLines=62, ChangedLinePercent=98.41 |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | 100 (this plan's P0-T10, 118/118) | 100 (116/116) | 100 (116/116) | ChangedLines=5, AnalyzedChangedLines=2, CoveredChangedLines=2, ChangedLinePercent=100 |

- All three files: P2-T8 LinePercent >= 85; AnalyzedChangedLines > 0; ChangedLinePercent >= 85.
- No file's line coverage decreased against its baseline.
- Result: PASS.
