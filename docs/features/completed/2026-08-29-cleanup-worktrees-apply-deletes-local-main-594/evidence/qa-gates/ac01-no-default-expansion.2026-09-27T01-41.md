# P5-T2 — AC-01 no environment-default expansion of the base constant

Timestamp: 2026-09-27T01-41
Task: [P5-T2]
Working directory: repository worktree root (HEAD `7e54e0e1`)
ExpectedExitCode: 1

Command: `grep -rn -F 'CLEANUP_WT_BASE_BRANCH:-' scripts/bash/`
EXIT_CODE: 1

Output Summary:
- No output; grep exited 1. No file under `scripts/bash/` reads the base branch through a `${CLEANUP_WT_BASE_BRANCH:-...}` default expansion, so the constant cannot be overridden from the environment.
- Result: PASS (observed exit 1 equals the expected exit 1).
