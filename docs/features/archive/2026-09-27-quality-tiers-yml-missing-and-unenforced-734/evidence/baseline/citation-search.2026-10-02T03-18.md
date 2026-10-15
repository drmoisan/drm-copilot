# P0-T33 Baseline Citation Search

Timestamp: 2026-10-02T03-18
Command: git grep -n -F "ci.research.md" -- . ":(exclude)docs"
EXIT_CODE: 0
Output Summary: Exactly five lines, as expected:

- .agents/skills/quality-tiers/SKILL.md:12 (citation sentence)
- .claude/rules/quality-tiers.md:9 (citation sentence)
- extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md:9 (citation sentence)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md:12 (citation sentence)
- tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1:249 (fixture string: `shared_surfaces = @('config/orchestration-routing.json', 'docs/ci.research.md')`)

The four citation lines carry the identical sentence "The tier system source of truth is `docs/ci.research.md` section 1; the file `quality-tiers.yml` at the repository root maps every project to a tier."
