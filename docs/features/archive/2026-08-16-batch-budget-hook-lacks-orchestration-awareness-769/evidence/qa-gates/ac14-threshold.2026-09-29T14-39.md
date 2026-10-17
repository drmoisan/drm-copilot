# AC-14 Threshold Check (#769, P6-T11)

Timestamp: 2026-09-29T14-39
Command: git grep -n -F -e "1-2" -e "1–2" -e ">2" -e "2 production" -e "up to 2" -e "2-production" -- .claude/skills/powershell-change-budget-router/SKILL.md .github/skills/powershell-change-budget-router/SKILL.md .claude/rules/powershell.md .claude/agents/powershell-typed-engineer.md .claude/skills/invoke-powershell-engineer/SKILL.md .github/agents/powershell-typed-engineer.agent.md .github/agents/powershell-orchestrator.agent.md .github/prompts/orchestrate-powershell-work.prompt.md
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
Negative search: no output, exit 1.
Positive search (git grep -c -F -e "1-3" -- <same eight files>, exit 0):
.claude/agents/powershell-typed-engineer.md:3 (min 3)
.claude/rules/powershell.md:1 (min 1)
.claude/skills/invoke-powershell-engineer/SKILL.md:2 (min 2)
.claude/skills/powershell-change-budget-router/SKILL.md:2 (min 2)
.github/agents/powershell-orchestrator.agent.md:4 (min 4)
.github/agents/powershell-typed-engineer.agent.md:3 (min 3)
.github/prompts/orchestrate-powershell-work.prompt.md:1 (exactly 1)
.github/skills/powershell-change-budget-router/SKILL.md:2 (min 2)
Every minimum is met.

Per-file edit checks (P6-T1 to P6-T8), all as required:
- P6-T1 .claude/rules/powershell.md: 'split the work' exit 1; '`/orchestrate' count 1.
- P6-T2 .claude router skill: 'powershell-orchestrator' exit 1; '1-3' count 2.
- P6-T3 .claude typed-engineer agent: 'per-batch' exit 1; '`/orchestrate' count 2.
- P6-T4 .claude invoke skill: 'budget: prod=' exit 1; '`/orchestrate' count 1.
- P6-T5 .github router skill: '1-3' count 2; '>2' exit 1.
- P6-T6 .github typed-engineer agent: 'per-batch' exit 1; '1-3' count 3.
- P6-T7 .github orchestrator agent: '1-2' exit 1; '1-3' count 4.
- P6-T8 .github prompt: '1–2' exit 1; '1-3' count 1.
- P6-T9: pair-hashes over the four CB text pairs printed `PAIR-SUMMARY pairs=4 unequal=0`.
- P6-T10: pair-hashes over the four GB text pairs printed `PAIR-SUMMARY pairs=4 unequal=0`.
