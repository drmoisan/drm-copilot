# Fail-Before Regression Record (Issue #1003)

Timestamp: 2026-10-31T12-58
Command: node run-jest.cjs test/claude-worktree-session.test.ts test/claude-worktree-session-command.test.ts -t "emits the runtime venv activation probe|creates one hidden terminal and never calls sendText" (in extensions/drm-copilot/, pre-change production tree)
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Tests: 2 failed, 32 skipped, 34 total. Both regression tests fail on the pre-change production tree for the expected reasons.

## Failures

1. `newClaudeWorktreeSession › newClaudeWorktreeSession creates one hidden terminal and never calls sendText`
   - `expect(options.hideFromUser).toBe(true)`: Expected `true`, Received `undefined` (`hideFromUser` not `true`; the pre-change handler passes `shellArgs: ["-NoLogo"]` and sends commands through `sendText`).

2. `buildWorktreeSessionCommands › emits the runtime venv activation probe for Windows and Linux layouts when usePoetry is true`
   - `expect(commands.activate).toContain("./.venv/bin/Activate.ps1")`: Expected substring `./.venv/bin/Activate.ps1`, Received string `& './.venv/Scripts/Activate.ps1'` (missing `./.venv/bin/Activate.ps1`).

## Tests line

```
Tests:       2 failed, 32 skipped, 34 total
```
