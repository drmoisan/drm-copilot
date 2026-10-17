# QC Pass 2: Full-Run Failures and Per-File Coverage ([P10-T6])

Timestamp: 2026-10-08T23-19
Command: sh <SCRATCHPAD>/s-full-parse.sh
EXIT_CODE: 0
Output Summary:
JUNIT_TESTS: 7223
JUNIT_FAILURES: 2
JUNIT_ERRORS: 0
FAILED_TEST: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED_TEST: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
COVERAGE .claude/hooks/hook-command-scanner.ps1 covered=149 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-heredoc.ps1 covered=42 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-payload.ps1 covered=186 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-payload-powershell.ps1 covered=71 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-invocation.ps1 covered=147 missed=0 pct=100.00
COVERAGE .claude/hooks/hook-command-invocation-operands.ps1 covered=40 missed=0 pct=100.00
COVERAGE .claude/hooks/enforce-promotion-mcp-only.ps1 covered=56 missed=4 pct=93.33
COVERAGE .claude/hooks/enforce-epic-worktree-removal-gate.ps1 covered=107 missed=4 pct=96.40
COVERAGE .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 covered=103 missed=6 pct=94.50
COVERAGE .claude/hooks/enforce-pr-author-skill-helpers.ps1 covered=112 missed=3 pct=97.39
COVERAGE .claude/hooks/enforce-pr-author-command-allowlist.ps1 covered=75 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-scanner.ps1 covered=149 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-heredoc.ps1 covered=42 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-payload.ps1 covered=186 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-payload-powershell.ps1 covered=71 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-invocation.ps1 covered=147 missed=0 pct=100.00
COVERAGE .codex/hooks/hook-command-invocation-operands.ps1 covered=40 missed=0 pct=100.00
COVERAGE .codex/hooks/enforce-promotion-mcp-only.ps1 covered=65 missed=0 pct=100.00
COVERAGE .codex/hooks/enforce-epic-worktree-removal-gate.ps1 covered=71 missed=1 pct=98.61
COVERAGE_BELOW_85: NONE

## Gate evaluation

- Failing set: both `FAILED_TEST:` names are members of `B_FULL` (baseline `pester-full-coverage.2026-10-08T17-32.md` lists exactly these two names). Neither belongs to a file created by this plan.
- Coverage: a numeric `COVERAGE ... pct=` line for each of the 19 production files; all are at or above 85.00; `COVERAGE_BELOW_85: NONE`.
- Set-`A` suites (validate-bash, preimplementation gate, epic merge gate, parallel abandon gate, promotion, worktree gates, pr-author skill, payload contract, Codex counterparts, no-Python guard): no failure outside `B_FULL`.
- Existing signature pin rows in `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` (used by AC-13) are not in the failing set, so they passed.

Result: PASS.
