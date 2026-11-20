# Baseline — push-down claude-resource contract suite

Timestamp: 2026-09-08T09-49
Task: [P0-T6]
Command: cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5'; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q"`
- Substitute actually run:
  `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- Reason: the `pwsh` wrapper is refused unconditionally in this worktree. `poetry` itself is not
  routed through `pwsh` and is not refused, so the same command runs directly in Git Bash. The
  working directory is stated explicitly on the command line rather than relied on as ambient, which
  preserves the intent of the plan's `Set-Location` span.

Output Summary:

Verbatim summary line printed by the run:

    11 passed in 0.18s

- passed: 11
- failed: 0 (not printed) — a fully passing `-q` run prints no failed count.
- exit code: 0

This suite is run without a coverage argument, per the rationale recorded in the plan's
`## Toolchain invocation shape` section: this work changes no Python production file, the only
Python artifact in scope is this contract suite, and the coverage language actually in scope is
bash, whose baseline is `[P0-T5]`.

`.claude/rules/python.md` line 16 makes `poetry run pytest` the repository-canonical spelling of the
`python -m pytest` invocation AC-35 names.

Verdict: PASS. The push-down mirror contract is green on the pre-change tree.
