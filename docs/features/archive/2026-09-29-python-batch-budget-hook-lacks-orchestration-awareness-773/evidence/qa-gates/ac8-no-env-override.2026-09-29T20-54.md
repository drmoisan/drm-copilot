# AC-8 Source Check (P10-T12)

Timestamp: 2026-09-29T20-54
Command: git grep -c -F -e 'CLAUDE_PYTHON_BUDGET' -- .claude/hooks/enforce-python-batch-budget.ps1 .codex/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Exit 1 with no output. Baseline (ac22-ac8-nonvacuity.2026-09-29T19-14.md) found 6 occurrences in CPYHOOK and in its CB copy.
