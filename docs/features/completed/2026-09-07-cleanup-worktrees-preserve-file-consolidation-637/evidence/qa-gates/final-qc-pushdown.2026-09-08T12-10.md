# Final QC — `[P10-T8]`, the push-down contract suite as the last gate

Timestamp: 2026-09-08T12-10
Task: `[P10-T8]`
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: `11 passed in 0.13s`. The summary line contains the word `passed` and prints **no
failed count**, which for a `-q` run is the fully-passing shape. Failed: 0 (not printed).

## Route

Run on the Windows side in Git Bash from the worktree root. The plan's span is
`pwsh -NoProfile -Command "Set-Location -LiteralPath 'RESOLVED-WINDOWS-ROOT'; poetry run pytest ..."`;
the `pwsh` wrapper is refused in this agent-isolated worktree, so the same command was run directly
with the working directory set to the resolved Windows root:

    cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5
    poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q

`.claude/rules/python.md` line 16 makes `poetry run pytest` the repository-canonical spelling of the
`python -m pytest` invocation AC-35 names. No coverage argument is passed, for the reason the plan's
`## Toolchain invocation shape` section records: this work changes no Python production file, the
only Python artifact in scope is this contract suite itself, and the coverage language actually in
scope is bash.

## Output

    ...........                                                              [100%]
    11 passed in 0.13s

## Comparison against the two earlier runs of the same suite

| Task | Timestamp | Result |
| --- | --- | --- |
| `[P0-T6]` baseline | 2026-09-08T09-49 | 11 passed |
| `[P8-T5]` | 2026-09-08T11-40 | 11 passed |
| `[P10-T8]` this run | 2026-09-08T12-10 | 11 passed |

The count is unchanged and no test regressed. This is the last gate because Phase 8 edited a
`.claude/**` file and later phases could have touched the bundle; the suite confirms the resource
mirror pair is still byte-identical after every change this plan made, including the
coverage-remediation pass, which touched only `tests/` and therefore could not have disturbed it.
