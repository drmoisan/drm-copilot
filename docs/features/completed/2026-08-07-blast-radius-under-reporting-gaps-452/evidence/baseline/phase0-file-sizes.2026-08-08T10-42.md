# Phase 0 — Pre-Change File Sizes

Timestamp: 2026-08-08T10-42
Task: [P0-T12]

Command: `wc -l scripts/dev_tools/_blast_radius_extraction.py
scripts/dev_tools/_blast_radius_validation.py scripts/dev_tools/_blast_radius_conflicts.py
scripts/dev_tools/compute_blast_radius.py .claude/lib/blast-radius/BlastRadiusExtraction.psm1
.claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConfig.psm1
.claude/lib/blast-radius/BlastRadiusValidation.psm1 .claude/lib/blast-radius/BlastRadius.psm1`

EXIT_CODE: 0

## Output Summary — nine in-scope files with exact pre-change line counts

| File | Lines | Headroom to 500 |
| --- | ---: | ---: |
| `scripts/dev_tools/_blast_radius_extraction.py` | 494 | 6 |
| `scripts/dev_tools/_blast_radius_validation.py` | 497 | 3 |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 277 | 223 |
| `scripts/dev_tools/compute_blast_radius.py` | 321 | 179 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 485 | 15 |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 367 | 133 |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 438 | 62 |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 361 | 139 |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 373 | 127 |
| **Total** | **3613** | |

Three files confirm the spec's structural-relief premise: `_blast_radius_extraction.py` (494),
`_blast_radius_validation.py` (497), and `BlastRadiusExtraction.psm1` (485) cannot absorb their
Gap 1 change within the 500-line limit. This is the recorded justification for the authorized
pure-move relief in Phase 1 (Python) and Phase 2 (PowerShell).
