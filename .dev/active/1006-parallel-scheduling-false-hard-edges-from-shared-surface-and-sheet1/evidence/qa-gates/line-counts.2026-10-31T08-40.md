# Post-Change Physical Line Counts (issue #1006)

Timestamp: 2026-10-31T08-40
Task: P8-T16
Command: sh SCRATCH/issue-1006-linecounts.sh (runs `wc -l` per file)
EXIT_CODE: 0
Output Summary: every non-Markdown file is below 700 lines (largest: `extensions/drm-copilot/jest.config.cjs` at 540); every new file is at most 500 lines (largest new: `test_push_down_claude_blast_radius_overlay_demote.py` at 320). The two Markdown copies of the rule are 727 lines each and are exempt from the size tiers under `.claude/rules/general-code-change.md`.

| Item | File | P0-T3 | Now | Change |
|---|---|---|---|---|
| 1 | scripts/dev_tools/_blast_radius_token_shapes.py | 225 | 280 | +55 |
| 2 | scripts/dev_tools/_blast_radius_extraction.py | 468 | 475 | +7 |
| 3 | scripts/dev_tools/_blast_radius_write_intent.py | 421 | 427 | +6 |
| 4 | scripts/dev_tools/compute_blast_radius.py | 473 | 478 | +5 |
| 5 | scripts/dev_tools/push_down_claude_blast_radius_overlay.py | 286 | 378 | +92 |
| 6 | .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 269 | 324 | +55 |
| 7 | .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 464 | 465 | +1 |
| 8 | .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 297 | 299 | +2 |
| 9 | .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 446 | 449 | +3 |
| 10 | .claude/lib/blast-radius/BlastRadius.psm1 | 475 | 479 | +4 |
| 11 | BUNDLE/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 269 | 324 | +55 |
| 12 | BUNDLE/.claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 464 | 465 | +1 |
| 13 | BUNDLE/.claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 297 | 299 | +2 |
| 14 | BUNDLE/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 446 | 449 | +3 |
| 15 | BUNDLE/.claude/lib/blast-radius/BlastRadius.psm1 | 475 | 479 | +4 |
| 16 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts | 447 | 465 | +18 |
| 17 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts (new) | absent | 126 | new |
| 18 | extensions/drm-copilot/jest.config.cjs | 535 | 540 | +5 |
| 19 | config/blast-radius.json | 81 | 81 | 0 |
| 20 | BUNDLE/config/blast-radius.json | 49 | 49 | 0 |
| 21 | .claude/rules/parallel-orchestration.md (Markdown, exempt) | 690 | 727 | +37 |
| 22 | BUNDLE/.claude/rules/parallel-orchestration.md (Markdown, exempt) | 690 | 727 | +37 |
| 23 | tests/scripts/dev_tools/blast_radius_parity_test_support.py | 277 | 280 | +3 |
| 24 | tests/scripts/dev_tools/test_blast_radius_config_parity.py | 499 | 511 | +12 |
| 25 | tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py | 153 | 159 | +6 |
| 26 | tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py | 90 | 123 | +33 |
| 27 | tests/scripts/dev_tools/test_blast_radius_generic_contracts.py (new) | absent | 265 | new |
| 28 | tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py (new) | absent | 320 | new |
| 29 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | 391 | 396 | +5 |
| 30 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | 291 | 301 | +10 |
| 31 | tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 (new) | absent | 235 | new |
| 32 | extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts | 270 | 272 | +2 |
| 33 | extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts | 69 | 87 | +18 |
| 34 | extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts (new) | absent | 254 | new |
| 38 | tests/scripts/dev_tools/test_blast_radius_mandate_reads.py | 232 | 241 | +9 |
| 39 | tests/scripts/dev_tools/test_blast_radius_extraction.py | 466 | 468 | +2 |
| 40 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | 460 | 461 | +1 |

BUNDLE = `extensions/drm-copilot/resources/claude-customizations`.
