# Baseline Mirror Parity (#841, P0-T8)

Timestamp: 2026-10-10T09-11
Command: git hash-object .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1 .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: PAIR-SUMMARY pairs=4 unequal=0

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 <G1 paths>` was replaced by the A4 substitute `git hash-object` over the eight Appendix G1 paths in order (git blob hashes, not SHA-256).

## Pairs (primary, mirror)

1. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` = 912a7fc869d23c7e0a9668fa16093d588873df04; `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` = 912a7fc869d23c7e0a9668fa16093d588873df04; EQUAL
2. `.claude/skills/orchestrate/SKILL.md` = 4b46098b6d36079c8aeaa369e8ff8271a74f30f8; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` = 4b46098b6d36079c8aeaa369e8ff8271a74f30f8; EQUAL
3. `.claude/skills/feature-review-workflow/SKILL.md` = c45110dd26eede0eddd1394b33ef48138798d6bf; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` = c45110dd26eede0eddd1394b33ef48138798d6bf; EQUAL
4. `.agents/skills/feature-review-workflow/SKILL.md` = dac770f3170fd18b924c54705fd3e2d869fba872; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` = dac770f3170fd18b924c54705fd3e2d869fba872; EQUAL

PAIR-SUMMARY pairs=4 unequal=0
