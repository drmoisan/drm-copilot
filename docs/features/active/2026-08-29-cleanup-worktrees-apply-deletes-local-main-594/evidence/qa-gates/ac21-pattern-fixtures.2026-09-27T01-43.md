# P5-T8 — AC-21 portability pattern search over the new fixtures

Timestamp: 2026-09-27T01-43
Task: [P5-T8]
Working directory: repository worktree root (HEAD `7e54e0e1`)
ExpectedExitCode: 1

Command: `grep -rnE 'origin/|/mnt/|[A-Za-z]:[\\/]|mktemp|artifacts/' tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`
EXIT_CODE: 1

Output Summary:
- No output; grep exited 1. The eight fixture files contain no remote ref, no WSL or Windows host path, no `mktemp`, and no `artifacts/` path (they use only the synthetic `/repo/main` and `/repo-wt/base` paths).
- Result: PASS (observed exit 1 equals the expected exit 1).
