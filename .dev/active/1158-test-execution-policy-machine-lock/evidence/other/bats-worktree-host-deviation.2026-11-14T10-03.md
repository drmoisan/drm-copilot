# Non-blocking Deviation: bats Gate Measured on a Copy of HEAD (P7-T7)

Timestamp: 2026-11-14T10-03
Command: `wsl -e sh -c 'git -C <item worktree, WSL path> status --porcelain -- scripts/bash/shell-qc.sh'`; the same probe on a checkout with a real `.git` directory
EXIT_CODE: 128
Output Summary: WSL git cannot read a linked Windows worktree, because the `.git` pointer file holds a Windows path. The probe printed `not a git repository` and exited 128; on a checkout with a real `.git` directory it exited 0. Two bats negative-control tests end with that `git status` read, so they fail in any linked worktree on this host. The P7-T7 gate result of record is therefore the run on a `git archive HEAD` copy of the same commit with a WSL-initialized `.git` directory: 803 tests, 0 failures, kcov 95.0%, `run-test-suite.sh` 100%.

## Disposition

- Not caused by this item: the item changes neither `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, nor the cleanup-worktrees scripts. The only bats file it changes is `tests/shell/test_run_test_suite.bats`, which runs after both failing files in bats file order.
- CI evidence of record: `shell-coverage / Shell Coverage (Bats + kcov)` on the pull-request head.
- Unrelated finding for the orchestrator: the two negative-control tests assume `REPO_ROOT` is readable by the bats host's git, which is false for a Windows linked worktree read from WSL.
