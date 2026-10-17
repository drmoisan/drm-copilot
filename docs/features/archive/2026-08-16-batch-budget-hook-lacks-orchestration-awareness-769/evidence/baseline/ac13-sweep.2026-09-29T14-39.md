# AC-13 Non-Vacuity Baseline (#769, P0-T22)

Timestamp: 2026-09-29T14-39
Command: git grep -n -i -F -e "per-batch" -e "batch cap" -e "smaller batches" -e "split the work" -e "new batch" -e "three-test" -- ".claude/*powershell*" ".agents/*powershell*" ".codex/*powershell*" ".github/agents/*powershell*" ".github/skills/*powershell*" ".github/prompts/*powershell*" "extensions/drm-copilot/resources/claude-customizations/.claude/*powershell*" "extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/*powershell*" "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/*powershell*" "extensions/drm-copilot/resources/customizations/.github/agents/*powershell*" "extensions/drm-copilot/resources/customizations/.github/skills/*powershell*" "extensions/drm-copilot/resources/customizations/.github/prompts/*powershell*"
EXIT_CODE: 0
Output Summary:
Matches found in (primary files; each has a byte-identical bundle mirror that also matches):
- .agents/skills/invoke-powershell-engineer/SKILL.md:3
- .agents/skills/powershell/SKILL.md:37, 38
- .claude/agents/powershell-typed-engineer.md:4, 39, 68
- .claude/hooks/enforce-powershell-batch-budget.ps1:3, 9, 296
- .claude/rules/powershell.md:40, 41
- .claude/skills/invoke-powershell-engineer/SKILL.md:3
- .codex/agents/powershell-typed-engineer.toml:32, 67, 96 (and the five -c1, -c2, -c3, -c3-elevated, -c4 variants at the same lines)
- .codex/hooks/enforce-powershell-batch-budget.ps1:4, 10, 139
- .github/agents/powershell-typed-engineer.agent.md:132, 133, 134

Acceptance: at least one match in each of .claude/rules/powershell.md, .agents/skills/powershell/SKILL.md, .github/agents/powershell-typed-engineer.agent.md, and .codex/agents/powershell-typed-engineer.toml. Met.
