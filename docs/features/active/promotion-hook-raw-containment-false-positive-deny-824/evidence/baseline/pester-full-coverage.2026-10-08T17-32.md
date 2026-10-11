# Baseline: Full-Run JUnit and Per-File Line Coverage

Timestamp: 2026-10-08T17-32
Command: sh <SCRATCHPAD>/s-full-parse.sh baseline
EXIT_CODE: 0
Output Summary:
JUNIT_TESTS: 6534
JUNIT_FAILURES: 2
JUNIT_ERRORS: 0
FAILED_TEST: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED_TEST: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
COVERAGE .claude/hooks/hook-command-scanner.ps1 covered=183 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-heredoc.ps1 NEW_FILE
COVERAGE .claude/hooks/hook-command-payload.ps1 NEW_FILE
COVERAGE .claude/hooks/hook-command-payload-powershell.ps1 NEW_FILE
COVERAGE .claude/hooks/hook-command-invocation.ps1 covered=123 missed=1 pct=99.19
COVERAGE .claude/hooks/hook-command-invocation-operands.ps1 NEW_FILE
COVERAGE .claude/hooks/enforce-promotion-mcp-only.ps1 covered=56 missed=4 pct=93.33
COVERAGE .claude/hooks/enforce-epic-worktree-removal-gate.ps1 covered=104 missed=5 pct=95.41
COVERAGE .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 covered=100 missed=7 pct=93.46
COVERAGE .claude/hooks/enforce-pr-author-skill-helpers.ps1 covered=97 missed=3 pct=97.00
COVERAGE .claude/hooks/enforce-pr-author-command-allowlist.ps1 NEW_FILE
COVERAGE .codex/hooks/hook-command-scanner.ps1 covered=183 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-heredoc.ps1 NEW_FILE
COVERAGE .codex/hooks/hook-command-payload.ps1 NEW_FILE
COVERAGE .codex/hooks/hook-command-payload-powershell.ps1 NEW_FILE
COVERAGE .codex/hooks/hook-command-invocation.ps1 covered=121 missed=3 pct=97.58
COVERAGE .codex/hooks/hook-command-invocation-operands.ps1 NEW_FILE
COVERAGE .codex/hooks/enforce-promotion-mcp-only.ps1 covered=65 missed=0 pct=100.00
COVERAGE .codex/hooks/enforce-epic-worktree-removal-gate.ps1 covered=67 missed=1 pct=98.53
COVERAGE_BELOW_85: NONE

B_FULL (pre-existing failing tests in the full suite):
- enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
- Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits

Observed cause of the second B_FULL member (recorded for the audit; not changed by this plan): the Codex enforce-epic-wave-barrier.ps1 handler denies with EPIC_WAVE_BARRIER_BLOCKED for item '824', because the live epic checkpoint in this checkout records unmet depends_on edges. The test reads ambient orchestration state.

All ten existing production files carry a numeric baseline percentage; the nine new files are NEW_FILE.
