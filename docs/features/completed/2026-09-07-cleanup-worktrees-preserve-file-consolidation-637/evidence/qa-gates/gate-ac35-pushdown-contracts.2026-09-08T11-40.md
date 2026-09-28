# Gate — AC-35, the push-down contract suite passes

Timestamp: 2026-09-08T11-40
Task: `[P8-T5]`
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: `11 passed in 0.17s`. The summary line contains the word `passed` and prints no
failed count, which for a `-q` run is what a fully passing run looks like.

RouteSubstitution:
- Plan command (the `pwsh` wrapper is denied in this worktree):
  `pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5'; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q"`
- Substitute actually run: the identical `poetry run pytest` invocation executed locally from the
  worktree root without the `pwsh` wrapper. Only the wrapper is dropped; the working directory, the
  tool, the test path, and the flag are the same.
- Reason: `pwsh` is refused unconditionally in this worktree by the harness-level isolation guard.
  The delegation governing this execution records this substitute as verified.

## Why this suite is the right gate for the mirrored edit

The suite holds the repository copy of every `.claude/**` resource text-equal to its bundle mirror
under `extensions/drm-copilot/resources/claude-customizations/`. Phase 8 edited a `.claude/**` file,
so a mirrored edit that was merely equivalent rather than identical, or that was applied to only one
of the pair, would fail here rather than pass silently. The run was made after both files were
edited and after `[P8-T4]` confirmed byte identity, so it observes the post-edit tree.

The command is run without a coverage argument. The rationale is recorded in the plan's toolchain
section: this work changes no Python production file, the only Python artifact in scope is this
contract suite itself, and it runs as a contract check over a Markdown mirror pair rather than as
coverage-bearing exercise of Python production code. The coverage language actually in scope is
bash.

Verdict: PASS.
