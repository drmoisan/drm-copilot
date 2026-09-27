# P1-T9 — Fixture carriage-return search

Timestamp: 2026-09-27T01-30
Task: [P1-T9]
Working directory: repository worktree root
ExpectedExitCode: 1

Command: `grep -rlU $'\r' tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`
EXIT_CODE: 1

Output Summary:
- No output; grep exited 1 (no file in either new scenario directory contains a carriage return).
- Result: PASS (observed exit 1 equals the expected exit 1).
