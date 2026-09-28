# Baseline — push-down mirror contract tests (plan task P0-T6)

Timestamp: 2026-09-08T00-55
Tree state: branch `bug/cleanup-worktrees-dirt-classifier-632-r2` at HEAD
`4ffe680ebcebaabbba10faaa490e46a717686535`, working tree clean.

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
EXIT_CODE: 0

The plan's P0-T6 command text was runnable verbatim and was run verbatim; unlike
P0-T2 through P0-T5 and P0-T7 it carries no `wsl` form and no preparation-worktree
path, so no EA-1 or EA-4 deviation applies.

## Output Summary

`11 passed in 0.19s`

Passed-test count: 11. Failures: 0. Errors: 0.

This suite is the gate that fails when `.claude/skills/cleanup-merged-worktrees/SKILL.md`
and its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**`
diverge. Capturing it green before any SKILL.md edit is what makes a later failure
attributable to this change rather than to pre-existing drift.

## Verdict

Push-down mirror contract baseline is GREEN at 11 passed.
