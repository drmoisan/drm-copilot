# P6-T40 — AC-23 (CI `_shell-coverage.yml` job for the pull request)

Timestamp: 2026-09-27T02-20
Task: [P6-T40]
Working directory: repository worktree root
Branch taken: (b) — no pull request exists.

AC-23: DEFERRED TO PR CI GATE

The AC-23 item in `spec.md` is left unchecked and handed to the orchestrator's CI gate, which evaluates the `Shell Coverage (Bats + kcov)` check once the pull request is opened.

Supporting evidence (same workflow, same default-depth checkout): the P6-T10/P6-T11 dispatch run 36287146354 of `_shell-coverage.yml` on `ubuntu-latest` at headSha `e29ad95d70cce6641c1817f3ac36f319d2a10b59` concluded `success` with TAP `1..473`, 0 `not ok`, and `Bash coverage (lines): 93.3%` (recorded in `evidence/qa-gates/ci-shell-coverage.2026-09-27T02-00.md`).

ExpectedExitCode: 1

Command: `gh pr checks bug/cleanup-worktrees-apply-deletes-local-main-594`
EXIT_CODE: 1
Output (verbatim):

```
no pull requests found for branch "bug/cleanup-worktrees-apply-deletes-local-main-594"
```

Output Summary:
- `gh pr checks` exited 1 and printed `no pull requests found`: branch (b).
- AC-23 left unchecked; deferred to the PR CI gate.
- The item state (unchecked) matches branch (b).
