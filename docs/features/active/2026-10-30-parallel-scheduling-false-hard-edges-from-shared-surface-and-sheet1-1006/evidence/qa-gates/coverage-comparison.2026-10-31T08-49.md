# Coverage Comparison (issue #1006)

Timestamp: 2026-10-31T08-49
Task: P8-T14
Command: none (comparison of baseline/python-tests, baseline/pester-full, baseline/typescript against qa-gates/python-tests, qa-gates/pester-full, qa-gates/ts-jest)
EXIT_CODE: 0
Output Summary: no changed production file lost line or branch coverage; every changed or new file meets 85 percent line and 75 percent branch (line only for PowerShell). No production file is excluded from measurement.

## Python (coverage.py JSON report, dotted `--cov=` modules)

| File | Baseline line | Post line | Baseline branch | Post branch |
|---|---|---|---|---|
| scripts/dev_tools/_blast_radius_token_shapes.py | 100.00% (27/27) | 100.00% (31/31) | 100.00% (10/10) | 100.00% (10/10) |
| scripts/dev_tools/_blast_radius_extraction.py | 100.00% (97/97) | 100.00% (97/97) | 100.00% (44/44) | 100.00% (44/44) |
| scripts/dev_tools/_blast_radius_write_intent.py | 97.98% (97/99) | 98.00% (98/100) | 95.24% (40/42) | 95.24% (40/42) |
| scripts/dev_tools/compute_blast_radius.py | 100.00% (80/80) | 100.00% (81/81) | 100.00% (14/14) | 100.00% (14/14) |
| scripts/dev_tools/push_down_claude_blast_radius_overlay.py | 100.00% (109/109) | 100.00% (135/135) | 100.00% (52/52) | 100.00% (64/64) |

The two uncovered lines in `_blast_radius_write_intent.py` are pre-existing heading-continue lines (baseline 345 and 351, now 349 and 355); every changed line is covered.

## PowerShell (Pester JaCoCo LINE counters; no branch gate)

| File | Baseline line | Post line |
|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 100.00% (33/33) | 100.00% (39/39) |
| .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 100.00% (80/80) | 100.00% (80/80) |
| .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 100.00% (51/51) | 100.00% (52/52) |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 100.00% (102/102) | 100.00% (103/103) |
| .claude/lib/blast-radius/BlastRadius.psm1 | 100.00% (107/107) | 100.00% (108/108) |

## TypeScript (Jest per-file text table)

| File | Baseline line | Post line | Baseline branch | Post branch |
|---|---|---|---|---|
| src/lib/push-down/claude-blast-radius-overlay.ts | 99.55% | 99.56% | 95.87% | 96.15% |
| src/lib/push-down/claude-blast-radius-overlay-demote.ts (new) | absent | 100% | absent | 100% |

New-file figures: `claude-blast-radius-overlay-demote.ts` 100 percent line and branch with its own `coverageThreshold` entry; the uncovered lines of `claude-blast-radius-overlay.ts` (371-372, baseline 353-354) are the pre-existing `relativeToPosix` equal-root branch and not changed lines.
