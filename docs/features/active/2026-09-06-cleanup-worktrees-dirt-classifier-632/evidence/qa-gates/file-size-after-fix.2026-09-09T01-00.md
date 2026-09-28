# QA gate — file size after the N3 library fix

Timestamp: 2026-09-09T01-00

Task: [P2-T7]

Command: `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh`
EXIT_CODE: 0

Run with absolute paths to the same two files rather than repository-relative paths, because
this session's Bash permission layer refuses a `cd`-chained file-reading command; the command,
its flag and its targets are unchanged. Measured after the write-mode `shfmt` pass that
[P2-T2]'s toolchain loop applied, so the count is the post-format count and not a pre-format
one that formatting could still change.

## Counts

| File | Lines | Headroom to 500 |
|---|---:|---:|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 495 | 5 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 4 |

## Delta on the classifier library

Delta: **+14** lines. [P0-T8] recorded `scripts/bash/cleanup_worktrees_dirt_lib.sh` at 481
lines; it is now 495. 495 - 481 = 14.

That is exactly the budget the plan's File-size derivation states, and it decomposes the same
way:

| Insertion | Lines |
|---|---:|
| The `INDEX AND WORKING TREE ARE TWO LOCATIONS.` header paragraph plus its `#` separator | 6 |
| The `bothloc` block of D1 part one (two comment lines and one code line) | 3 |
| The nested `if`/`fi` at rung 4's positive emission | 2 |
| The nested `if`/`fi` at rung 5's positive emission | 2 |
| One line of rewrap in the rung-1 comment block, whose sentence about falling through to the working-tree rungs now points at the new header paragraph | 1 |
| **Total** | **14** |

Adding `bothloc=0` to the existing `local` declaration added no line, as the plan states.

495 is **at or below the 497 acceptance threshold** and below the 500-line cap in
`.claude/rules/shell.md`. Five lines of headroom remain. The header paragraph was not
compressed and the named extraction target
(`scripts/bash/cleanup_worktrees_dirt_ladder_lib.sh`) was not taken; neither was needed.

## The excluded file is unchanged

`scripts/bash/cleanup_worktrees_lib.sh` is recorded at **496** lines, the same value [P0-T8]
recorded. This cycle did not touch the file the plan excludes from modification. Its 4 lines
of headroom are unconsumed.

Output Summary: the classifier library is 495 lines, a delta of +14 from the 481 recorded at
baseline, five lines below the 500-line cap and two below the 497 acceptance threshold. The
excluded `cleanup_worktrees_lib.sh` is unchanged at 496.
