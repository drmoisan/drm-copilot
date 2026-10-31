# Pass-After Regression Record (Issue #1003)

Timestamp: 2026-10-31T13-09
Command: node run-jest.cjs test/claude-worktree-session.test.ts test/claude-worktree-session-command.test.ts -t "emits the runtime venv activation probe|creates one hidden terminal and never calls sendText" (in extensions/drm-copilot/)
EXIT_CODE: 0
Output Summary: the two fail-before regression tests now pass (Tests: 46 skipped, 2 passed, 48 total); the handler test files pass together (Tests: 55 passed, 55 total; no failed).

## Run 1: the [P1-T3] command after the fix

Command: node run-jest.cjs test/claude-worktree-session.test.ts test/claude-worktree-session-command.test.ts -t "emits the runtime venv activation probe|creates one hidden terminal and never calls sendText"
EXIT_CODE: 0

```
Tests:       46 skipped, 2 passed, 48 total
```

The fail-before record (`evidence/regression-testing/fail-before.2026-10-31T12-58.md`) showed the same command with `EXIT_CODE: 1` and `2 failed`.

## Run 2: handler test files

Command: node run-jest.cjs test/extension.workflow-commands.test.ts test/claude-worktree-session-command.test.ts test/codex-worktree-session-command.test.ts
EXIT_CODE: 0

```
Test Suites: 3 passed, 3 total
Tests:       55 passed, 55 total
```
