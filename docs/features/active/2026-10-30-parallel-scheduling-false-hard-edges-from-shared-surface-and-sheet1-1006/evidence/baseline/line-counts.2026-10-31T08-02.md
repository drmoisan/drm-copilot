# Baseline Physical Line Counts (issue #1006)

Timestamp: 2026-10-31T08-02
Task: P0-T3
Command: sh SCRATCH/issue-1006-linecounts.sh (runs `wc -l` per file)
EXIT_CODE: 0
Output Summary: 33 existing inventory files counted; new files (items 17, 27, 28, 31, 34) are absent before the change. The largest non-Markdown file is `extensions/drm-copilot/jest.config.cjs` at 535 lines; every existing file is below 700 lines.

| Item | File | Lines |
|---|---|---|
| 1 | scripts/dev_tools/_blast_radius_token_shapes.py | 225 |
| 2 | scripts/dev_tools/_blast_radius_extraction.py | 468 |
| 3 | scripts/dev_tools/_blast_radius_write_intent.py | 421 |
| 4 | scripts/dev_tools/compute_blast_radius.py | 473 |
| 5 | scripts/dev_tools/push_down_claude_blast_radius_overlay.py | 286 |
| 6 | .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 269 |
| 7 | .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 464 |
| 8 | .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 297 |
| 9 | .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 446 |
| 10 | .claude/lib/blast-radius/BlastRadius.psm1 | 475 |
| 11 | BUNDLE/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 269 |
| 12 | BUNDLE/.claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 464 |
| 13 | BUNDLE/.claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 297 |
| 14 | BUNDLE/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 446 |
| 15 | BUNDLE/.claude/lib/blast-radius/BlastRadius.psm1 | 475 |
| 16 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts | 447 |
| 18 | extensions/drm-copilot/jest.config.cjs | 535 |
| 19 | config/blast-radius.json | 81 |
| 20 | BUNDLE/config/blast-radius.json | 49 |
| 21 | .claude/rules/parallel-orchestration.md | 690 |
| 22 | BUNDLE/.claude/rules/parallel-orchestration.md | 690 |
| 23 | tests/scripts/dev_tools/blast_radius_parity_test_support.py | 277 |
| 24 | tests/scripts/dev_tools/test_blast_radius_config_parity.py | 499 |
| 25 | tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py | 153 |
| 26 | tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py | 90 |
| 29 | tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | 391 |
| 30 | tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | 291 |
| 32 | extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts | 270 |
| 33 | extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts | 69 |
| 38 | tests/scripts/dev_tools/test_blast_radius_mandate_reads.py | 232 |
| 39 | tests/scripts/dev_tools/test_blast_radius_extraction.py | 466 |
| 40 | tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | 460 |

BUNDLE = `extensions/drm-copilot/resources/claude-customizations`.
