# Final QC: bats Suite (P7-T7)

Timestamp: 2026-11-14T10-03
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh bats --coverage. Run 1 used the item worktree (SCRATCH/issue-1158-launch.sh). Run 2 used a `git archive HEAD` copy of the same commit staged under SCRATCH, with a WSL-initialized `.git` directory (SCRATCH/issue-1158-bats-copy.sh, then SCRATCH/issue-1158-launch-copy.sh).
EXIT_CODE: 0
Output Summary: the P0-T7 deviation condition no longer holds. The repository suite command `bash scripts/bash/shell-qc.sh test` resolves `bash` to WSL, which has bats 1.13.0 and kcov 43, so the gate ran for real. Run 2 (copy of HEAD): 803 tests, 0 failures, launcher exit 0. kcov merged report: `Bash coverage (lines): 95.0%` (3460 of 3643 lines). `.claude/skills/test-execution-policy/scripts/run-test-suite.sh` has line-rate 1.000 (100%).

## Runs

| Run | Tree | Tests | Failures | Launcher exit | Coverage |
|---|---|---|---|---|---|
| 1 | item worktree | 803 | 2 | 1 | not produced (the coverage mode stops at the first failing directory) |
| 2 | `git archive HEAD` copy with a WSL-native `.git` | 803 | 0 | 0 | 95.0% repo bash lines; `run-test-suite.sh` 100% |

## Run 1 Failures (host-specific, not caused by this item)

- `not ok 434 dirt_typechange_delta: ... (negative control)` in `tests/shell/test_cleanup_worktrees_dirt_classify.bats`.
- `not ok 456 dirt_staged_tree_is_commit: ... (negative control)` in `tests/shell/test_cleanup_worktrees_dirt_clear.bats`.

Both tests end with `git -C "${REPO_ROOT}" status --porcelain -- <file>`. In a linked worktree, `.git` is a pointer file holding a Windows path, and WSL git cannot follow it. A probe of `git status` on the item worktree from WSL returned exit 128 with `not a git repository`. The same probe on a checkout with a real `.git` directory returned 0. This item changes neither test file nor the scripts they exercise. The `CI` workflow on `origin/main` at the merged commit concluded `success`. In Run 2, which has a real `.git` directory, both tests pass. The details are in `evidence/other/bats-worktree-host-deviation.2026-11-14T10-03.md`.
