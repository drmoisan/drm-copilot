# QC: Structural Frontmatter Validation

- **Timestamp:** 2026-04-12T00:05Z
- **Command:** `Get-ChildItem '.claude' -Recurse -Filter '*.md'` with frontmatter regex validation + field checks + JSON validation of `settings.json`
- **EXIT_CODE:** 0
- **Output Summary:**

All 13 markdown files have valid YAML frontmatter (`---...---` block present).
`.claude/settings.json` is valid JSON.

### Rules files (paths: field present)

- `.claude/rules/csharp.md` — paths: 1
- `.claude/rules/powershell.md` — paths: 1
- `.claude/rules/python.md` — paths: 1
- `.claude/rules/typescript.md` — paths: 1

### Skills files (name: and description: fields present)

- `.claude/skills/commit-message/SKILL.md` — name: 1, description: 1
- `.claude/skills/orchestrate/SKILL.md` — name: 1, description: 1
- `.claude/skills/pr-author/SKILL.md` — name: 1, description: 1
- `.claude/skills/research-issue/SKILL.md` — name: 1, description: 1

### Agent files (name: and tools: fields present)

- `.claude/agents/atomic-executor.md` — name: 1, tools: 1
- `.claude/agents/atomic-planner.md` — name: 1, tools: 1
- `.claude/agents/feature-review.md` — name: 1, tools: 1
- `.claude/agents/orchestrator.md` — name: 1, tools: 1
- `.claude/agents/task-researcher.md` — name: 1, tools: 1
