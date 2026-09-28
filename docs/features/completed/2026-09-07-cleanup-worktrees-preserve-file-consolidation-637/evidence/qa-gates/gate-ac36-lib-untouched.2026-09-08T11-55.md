# Gate — AC-36, the contended library carries no diff

Timestamp: 2026-09-08T11-55
Task: `[P9-T1]`
Command: git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/cleanup_worktrees_lib.sh
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: both invocations printed nothing and both exited 0. The `diff --stat` invocation
exited 0 with empty output; the `git status --porcelain -- scripts/bash/cleanup_worktrees_lib.sh`
invocation exited 0 with empty output.

The ref `epic/cleanup-merged-worktrees-hardening-integration` exists as a local branch in this
repository and resolves to `fff743141463c32da3b57a4cedd1c05ba58c9f78`, so the comparison is against
a real commit rather than an unresolvable name that would make the diff vacuously empty. That
resolution was confirmed with `git rev-parse --verify --quiet` before the diff was taken.

Two invocations are run because each alone is blind in one state. The anchored diff is blind to a
change that has not been committed; porcelain status is blind to a change that has been. Both being
empty establishes the file is untouched in the working tree and in the branch's history.

All new production code for this work lands in `scripts/bash/cleanup_worktrees_preserve_lib.sh` and
`scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`, both new files, and in the wrapper's source
block, dispatch arm, and usage heredoc. The contended library was measured at **490** of its
500-line cap during this work, ten lines of headroom rather than the twenty-one the plan recorded,
which makes leaving it untouched more important rather than less. `[P8-T6]` records the one
documentation consequence: its header comment's copy of the record-type list is deliberately left
stale.

Verdict: PASS.
