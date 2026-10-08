# AC-22 and AC-8 Non-Vacuity Baseline (P0-T28)

Timestamp: 2026-09-29T19-14
Command: git grep -c -F -e 'budget: prod=' -- .claude/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-powershell-engineer/SKILL.md; git grep -c -F -e 'CLAUDE_PYTHON_BUDGET' -- .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
EXIT_CODE: 0
Output Summary:
First search (three path:count lines):
.agents/skills/invoke-powershell-engineer/SKILL.md:1
.agents/skills/invoke-python-engineer/SKILL.md:1
.claude/skills/invoke-python-engineer/SKILL.md:1
Second search (two path:count lines):
.claude/hooks/enforce-python-batch-budget.ps1:6
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:6
