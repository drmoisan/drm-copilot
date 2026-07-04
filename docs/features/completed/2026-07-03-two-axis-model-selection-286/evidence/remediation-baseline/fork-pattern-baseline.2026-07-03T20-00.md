# `context:\s*fork` Pattern Baseline (Pre-Fix) — Issue #286 (CI-1)

- Timestamp: 2026-07-03T20-00
- Command: `pwsh -NoProfile -Command "$f=@('.claude/skills/orchestrate/SKILL.md','.claude/skills/epic-orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md'); Select-String -Path $f -Pattern 'context:\s*fork'"`
- EXIT_CODE: 0

## Output Summary

Four pre-fix matches found, one per file:

- `.claude/skills/orchestrate/SKILL.md:86` — "**`fork` caveat.** A skill invoked via `context: fork` inherits the parent model ..."
- `.claude/skills/epic-orchestrate/SKILL.md:123` — "agents, skills, and MCP tools. A skill invoked via `context: fork` inherits the parent model and ..."
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md:86` — bundled mirror of the orchestrate caveat.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md:123` — bundled mirror of the epic-orchestrate caveat.

These are the four locations to be reworded in Phase 1 so the `context:`-then-`fork` adjacency no longer occurs.
