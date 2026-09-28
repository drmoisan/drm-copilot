# Baseline — line counts of every file this cycle may touch, and the stub digest

Timestamp: 2026-09-09T00-00

Task: [P0-T8]

Command: `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
EXIT_CODE: 0

Command: `md5sum tests/fixtures/cleanup_worktrees/stub-bin/git`
EXIT_CODE: 0

Both commands were run with absolute paths to the same files rather than repository-relative
paths, because this session's Bash permission layer refuses a `cd`-chained file-reading
command; the commands, their flags and their target files are unchanged.

## Per-file counts and headroom to the 500-line cap

| File | Lines | Headroom to 500 |
|---|---:|---:|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 481 | 19 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 4 |
| `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` | 452 | 48 |
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 380 | 120 |
| `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` | 230 | 270 |

`wc -l` reported a total of 2039 lines across the five files.

The cap is stated in `.claude/rules/shell.md`: no production, test, or reusable shell file may
exceed 500 lines.

`scripts/bash/cleanup_worktrees_lib.sh` at 496 lines has 4 lines of headroom and is **excluded
from modification** by this cycle. P2-T7 re-measures it and its count must still be 496.

`scripts/bash/cleanup_worktrees_dirt_lib.sh` at 481 lines has 19 lines of headroom. The plan's
D1 fix is budgeted at 14 lines, landing the file at 495, and P2-T7's acceptance threshold is
497. If the change does not fit within that threshold the executor stops and reports rather
than compressing the header paragraph or exceeding the cap.

## Stub digest

StubDigest: `a701f6cec32dc230b60d362f6266612b`

This is the `md5sum` of `tests/fixtures/cleanup_worktrees/stub-bin/git`. P5-T5 compares
against it to show that this cycle added no stub arm. The plan adds no git read of any new
shape, so no stub change is required and the digest is expected to be unchanged at the end of
the cycle.

Output Summary: `cleanup_worktrees_dirt_lib.sh` is 481 lines (19 of headroom),
`cleanup_worktrees_lib.sh` is 496 (4 of headroom, excluded from modification),
`test_cleanup_worktrees_dirt_guard_registry.bats` is 452 (48 of headroom),
`test_cleanup_worktrees_dirt_classify.bats` is 380 (120), and
`test_cleanup_worktrees_dirt_failclosed.bats` is 230 (270). No file is at or over the 500-line
cap. `StubDigest:` is present and non-empty.
