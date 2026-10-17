# Regression: AC-tracking replacement sentence present in all six copies ([P4-T9], AC-8)

Timestamp: 2026-10-09T21-21
Command: git grep -c -F -e "The one exception is a CI-dependent criterion" -- .claude/skills/acceptance-criteria-tracking/SKILL.md .agents/skills/acceptance-criteria-tracking/SKILL.md .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
EXIT_CODE: 0
Output Summary: six lines, each ending `:1`.

```
.agents/skills/acceptance-criteria-tracking/SKILL.md:1
.claude/skills/acceptance-criteria-tracking/SKILL.md:1
.github/skills/acceptance-criteria-tracking/SKILL.md:1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md:1
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md:1
extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md:1
```

## Block 2 (expected exit 1)

Command: git grep -n -F -e "check off AC items. Instead:" -- .claude/skills/acceptance-criteria-tracking/SKILL.md .agents/skills/acceptance-criteria-tracking/SKILL.md .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
Expected exit code for this block: 1
EXIT_CODE: 1
Output Summary: no output; the former sentence is absent from all six copies.

Supporting checks: `git diff --numstat 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a` printed `1	1` for each of the three edited sources ([P4-T3] to [P4-T5]); `cmp --` of each bundled mirror against its source exited 0 with no output ([P4-T6] to [P4-T8]). Merge-base substitution: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a used in place of e7d3779b398604af919678c16c877c8539a86cc0 as recorded in [P0-T4].

Acceptance (AC-8): first block exit 0 with six `:1` lines; second block exit 1 with no output. PASS.
