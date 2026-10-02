# AC-14 Non-Vacuity Baseline (#769, P0-T23)

Timestamp: 2026-09-29T14-39
Command: git grep -n -F -e "1-2" -e "1–2" -e ">2" -e "2 production" -e "up to 2" -e "2-production" -- .claude/skills/powershell-change-budget-router/SKILL.md .github/skills/powershell-change-budget-router/SKILL.md .claude/rules/powershell.md .claude/agents/powershell-typed-engineer.md .claude/skills/invoke-powershell-engineer/SKILL.md .github/agents/powershell-typed-engineer.agent.md .github/agents/powershell-orchestrator.agent.md .github/prompts/orchestrate-powershell-work.prompt.md
EXIT_CODE: 0
Output Summary:
Match lines per file:
- .claude/agents/powershell-typed-engineer.md: 4, 39, 49, 67
- .claude/rules/powershell.md: 39
- .claude/skills/invoke-powershell-engineer/SKILL.md: 3, 15
- .claude/skills/powershell-change-budget-router/SKILL.md: 21, 22, 39
- .github/agents/powershell-orchestrator.agent.md: 17, 101, 102, 126, 127, 131, 248
- .github/agents/powershell-typed-engineer.agent.md: 52, 53, 118, 119, 120, 130, 198
- .github/prompts/orchestrate-powershell-work.prompt.md: 24, 26
- .github/skills/powershell-change-budget-router/SKILL.md: 21, 22, 39

Acceptance: each of the eight files appears on at least one match line. Met.
