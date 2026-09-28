# Final QA — file-size limit

Timestamp: 2026-09-09T02-30
Task: [P5-T4]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

Command: `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`

EXIT_CODE: 0

## Per-file counts

| File | Lines | Headroom to 500 |
|---|---:|---:|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 495 | 5 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 4 |
| `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` | 437 | 63 |
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 382 | 118 |
| `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` | 283 | 217 |
| `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats` | 208 | 292 |

Every count is at or below the 500-line cap. The classifier library is at 495, which is at
or below the plan's 497 threshold, so the extraction fallback is not taken.

## Classifier library growth

P0-T8 recorded `scripts/bash/cleanup_worktrees_dirt_lib.sh` at **481** lines at cycle
start. It is now **495**, a growth of **+14** lines, exactly the total the plan's
File-size derivation table predicts: 6 for the `INDEX AND WORKING TREE ARE TWO LOCATIONS.`
header paragraph and its blank separator, 3 for the `bothloc` block, 2 for the nested
`if`/`fi` at rung 4's positive, 2 for the nested `if`/`fi` at rung 5's positive, and 1 for
the rewrap of the rung-1 comment block. Adding `bothloc=0` to the existing `local`
declaration added no line.

## The excluded file

`scripts/bash/cleanup_worktrees_lib.sh` is recorded at **496**, unchanged from the 496 that
P0-T8 recorded. That is the observation that this cycle did not touch the file the plan
excludes from modification.

## Note on the registry suite

`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` moved from 452 lines at
P0-T8 to 437 now. Phase 3's deletions — the `EXEMPT` arm of Obligation 5, Obligation 6 in
full, the `sibling_mutation` helper and the `EXEMPT_SIBLING_DIFFERED` accumulator —
outweigh the additions of Invariant 8 and the rewritten pin floor.

## Output Summary

All six files under the 500-line cap. Classifier library 495 (+14 from 481, 5 lines of
headroom, 2 below the plan's 497 threshold). Excluded file unchanged at 496.
