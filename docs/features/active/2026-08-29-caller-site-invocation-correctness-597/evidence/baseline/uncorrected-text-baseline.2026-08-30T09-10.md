# Uncorrected Text Baseline (P0-T3)

Timestamp: 2026-08-30T09-10

Command: fixed-string (`-F`) search for the literal token
`Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force`, restricted individually to each
of the six target files:
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' .claude/skills/parallel-plan/SKILL.md`
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' .claude/skills/parallel-add/SKILL.md`
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' .claude/agents/parallel-planner.md`
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
- `rg -F 'Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force' extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`

EXIT_CODE: 0

Output Summary: Exactly one match found in each of the six target files (six matches total):
- `.claude/skills/parallel-plan/SKILL.md`: 1 match
- `.claude/skills/parallel-add/SKILL.md`: 1 match
- `.claude/agents/parallel-planner.md`: 1 match
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`: 1 match
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`: 1 match
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`: 1 match

No coverage evidence applies — this is a fail-before literal-token baseline for a markdown-only
correction, not a coverage baseline.
