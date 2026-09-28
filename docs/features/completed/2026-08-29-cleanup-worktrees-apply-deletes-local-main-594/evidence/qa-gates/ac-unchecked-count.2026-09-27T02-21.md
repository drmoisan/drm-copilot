# P6-T41 — AC unchecked count

Timestamp: 2026-09-27T02-21
Task: [P6-T41]
Working directory: repository worktree root

The printed count is `1`, so this artifact carries no expectation field (grep exits 0 when a line matches).

The one unchecked item is AC-23 ("The CI `_shell-coverage.yml` job for the pull request passes on `ubuntu-latest` with the default checkout depth."), left unchecked by the P6-T40 deferral branch (b): `AC-23: DEFERRED TO PR CI GATE`.

Command: `grep -c -e '^- \[ \] ' docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`
EXIT_CODE: 0

Output Summary:
- Printed count: `1` (AC-23).
- Expected under the P6-T40 deferral branch: 1 unchecked. Matches; no expectation field, exit 0.
