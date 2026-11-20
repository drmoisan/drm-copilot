# P0-T4 — File-Size Inventory (growth targets, Design Determination 1)

Timestamp: 2026-08-18T09-07
Command: `wc -l` over each growth-target file named in Design Determination 1
EXIT_CODE: 0
Output Summary: all 13 measured counts match Design Determination 1 exactly. The 500-line limit binds production, test, and reusable script files.

| File | Lines | Headroom to 500 |
| --- | ---: | ---: |
| `scripts/dev_tools/_blast_radius_extraction.py` | 419 | 81 |
| `scripts/dev_tools/_blast_radius_validation.py` | 484 | 16 |
| `scripts/dev_tools/compute_blast_radius.py` | 333 | 167 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 490 | 10 |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 491 | 9 |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 379 | 121 |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 366 | 134 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | 464 | 36 |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 499 | 1 |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | 455 | 45 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 440 | 60 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 474 | 26 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 396 | 104 |
