# AC-18 Phrase Sweep Non-Vacuity Baseline (P0-T25)

Timestamp: 2026-09-29T19-13
Command: git grep -n -i -F -e 'per-batch' -e 'per batch' -e 'batch cap' -e 'smaller batches' -e 'split the work' -e 'new batch' -e 'three-test' -e 'in-flight batch' -e 'budget: prod=' -e 'budget override' -e 'seek an override' -- '.claude/*python*' '.agents/*python*' '.codex/*python*' '.github/agents/*python*' '.github/skills/*python*' '.github/prompts/*python*' 'extensions/drm-copilot/resources/claude-customizations/.claude/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/*python*' 'extensions/drm-copilot/resources/customizations/.github/agents/*python*' 'extensions/drm-copilot/resources/customizations/.github/skills/*python*' 'extensions/drm-copilot/resources/customizations/.github/prompts/*python*' ':(exclude).github/agents/python-execution-only-typed.agent.md' ':(exclude)extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md'
EXIT_CODE: 0
Output Summary:
96 match lines across 28 files. Per-file match counts:
- .agents/skills/invoke-python-engineer/SKILL.md: 2
- .agents/skills/python-change-budget-router/SKILL.md: 5
- .claude/agents/python-typed-engineer.md: 3
- .claude/hooks/enforce-python-batch-budget.ps1: 5
- .claude/skills/invoke-python-engineer/SKILL.md: 2
- .claude/skills/python-change-budget-router/SKILL.md: 5
- .codex/agents/python-typed-engineer.toml: 3 (and 3 each in the -c1, -c2, -c3, -c3-elevated, -c4 variants)
- .codex/hooks/enforce-python-batch-budget.ps1: 5
- .github/agents/python-typed-engineer.agent.md: 3
- Bundle mirrors of each of the above: same counts (13 mirror files)

All nine required files are named at least once: CPYHOOK, XPYHOOK, `.claude/skills/python-change-budget-router/SKILL.md`, `.agents/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, `.github/agents/python-typed-engineer.agent.md`.
No match line names a path containing `python-execution-only-typed` (the exclusion pathspecs work).
