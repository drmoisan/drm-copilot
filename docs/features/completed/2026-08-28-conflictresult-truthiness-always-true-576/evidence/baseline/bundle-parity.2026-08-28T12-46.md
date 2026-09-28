# Source-and-Bundled SHA-256 Parity Baseline — [P0-T9]

Timestamp: 2026-08-28T12-46

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 -Path '.claude/lib/blast-radius/BlastRadius.psm1','extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1','.claude/skills/parallel-add/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md','.claude/skills/parallel-plan/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md' | Format-List Path,Hash"`

EXIT_CODE: 0

## Six Digests

| # | Path | SHA-256 |
| --- | --- | --- |
| 1 | `.claude/lib/blast-radius/BlastRadius.psm1` | `FEF4F8A65FE23F28A0952CB11FEFC8DEA037BA7608FF1314F61847DD82DACEAC` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` | `FEF4F8A65FE23F28A0952CB11FEFC8DEA037BA7608FF1314F61847DD82DACEAC` |
| 3 | `.claude/skills/parallel-add/SKILL.md` | `FDC531B85BD693FD198D28906FCCAE2E2991F9BAFD12D8797E450A62D4CA9E44` |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` | `FDC531B85BD693FD198D28906FCCAE2E2991F9BAFD12D8797E450A62D4CA9E44` |
| 5 | `.claude/skills/parallel-plan/SKILL.md` | `81167F87F5569A858A7909192CAEE1FC837F9CDAD9E65458EA9CF79E193E588E` |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | `81167F87F5569A858A7909192CAEE1FC837F9CDAD9E65458EA9CF79E193E588E` |

## Pair Comparison

| Pair | Source digest | Bundled digest | Match |
| --- | --- | --- | --- |
| `BlastRadius.psm1` | `FEF4F8A6...DACEAC` | `FEF4F8A6...DACEAC` | matches |
| `parallel-add/SKILL.md` | `FDC531B8...CA9E44` | `FDC531B8...CA9E44` | matches |
| `parallel-plan/SKILL.md` | `81167F87...3E588E` | `81167F87...3E588E` | matches |

Output Summary: `EXIT_CODE: 0`. Six SHA-256 digests were computed. Each of the three source-and-bundled
pairs matches exactly at baseline: the module pair both read
`FEF4F8A65FE23F28A0952CB11FEFC8DEA037BA7608FF1314F61847DD82DACEAC`, the parallel-add pair both read
`FDC531B85BD693FD198D28906FCCAE2E2991F9BAFD12D8797E450A62D4CA9E44`, and the parallel-plan pair both
read `81167F87F5569A858A7909192CAEE1FC837F9CDAD9E65458EA9CF79E193E588E`. All three pairs are
byte-identical before this change, so every `.claude/` edit in this plan must land with its bundled
mirror. These six values are the baseline against which [P5-T9] compares the post-change digests.
