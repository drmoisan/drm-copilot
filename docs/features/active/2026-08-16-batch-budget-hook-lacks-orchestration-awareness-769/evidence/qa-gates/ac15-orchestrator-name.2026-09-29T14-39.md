# AC-15 Orchestrator Name Check (#769, P6-T12)

Timestamp: 2026-09-29T14-39
Command: git grep -n -F -e "powershell-orchestrator" -- .claude/skills/powershell-change-budget-router/SKILL.md .claude/rules/powershell.md .claude/agents/powershell-typed-engineer.md .claude/skills/invoke-powershell-engineer/SKILL.md
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
Negative search: no output, exit 1.
Positive search (git grep -c -F -e '`/orchestrate' -- <same four files>, exit 0), exactly four path:count lines:
.claude/agents/powershell-typed-engineer.md:2
.claude/rules/powershell.md:1
.claude/skills/invoke-powershell-engineer/SKILL.md:1
.claude/skills/powershell-change-budget-router/SKILL.md:4
