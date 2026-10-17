# AC-19 Routing-Text Check (P10-T2)

Timestamp: 2026-09-29T20-50
Command: git grep -c -F -e '<literal>' -- .claude/skills/python-change-budget-router/SKILL.md .agents/skills/python-change-budget-router/SKILL.md .claude/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .claude/agents/python-typed-engineer.md .codex/agents/python-typed-engineer.toml .github/agents/python-typed-engineer.agent.md, for each literal `1-3`, `more than 3`, `no production-file cap`, `not counted toward the routing threshold`
EXIT_CODE: 0
Output Summary:
Each of the four searches printed exactly seven path:count lines, one per file, each count at least 1.
- `1-3`: 2 in each of the seven files.
- `more than 3`: .agents invoke 1, .agents router 2, .claude agent 1, .claude invoke 1, .claude router 2, .codex toml 1, .github agent 2.
- `no production-file cap`: 1 in six files, 2 in .github/agents/python-typed-engineer.agent.md.
- `not counted toward the routing threshold`: 1 in each of the seven files.
