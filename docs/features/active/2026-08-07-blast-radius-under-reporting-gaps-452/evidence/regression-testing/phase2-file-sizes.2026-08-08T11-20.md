# Phase 2 — PowerShell File Sizes After the Structural Relief

Timestamp: 2026-08-08T11-20
Task: [P2-T7]

Command: `wc -l .claude/lib/blast-radius/BlastRadiusExtraction.psm1
.claude/lib/blast-radius/BlastRadiusGlob.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1`

EXIT_CODE: 0

## Output Summary — four paths, all at or below 500 lines

| File | Pre-move (P0-T12) | Post-move | Delta | At or below 500 |
| --- | ---: | ---: | ---: | --- |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 485 | 455 | -30 | yes |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 367 | 405 | +38 | yes |
| `extensions/.../claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 485 | 455 | -30 | yes |
| `extensions/.../claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 367 | 405 | +38 | yes |
| **Total** | 1704 | 1720 | +16 | |

Each repo file and its bundled mirror have identical line counts, consistent with the byte
identity verified at [P2-T3] and [P2-T6].

`BlastRadiusExtraction.psm1` moves from 15 lines of headroom to 45, which is the headroom the Gap
1 `-RootSurface` change consumes in Phase 4. The +16 net across both files is the seven-line
`Import-Module` comment block and statement added to the Extraction module plus the one-line
export-list extension in the Glob module; the moved function body itself is byte-identical and
contributes zero net lines.
