# Acceptance-Criteria State Unchanged

Timestamp: 2026-09-07T16-30
Task: [P6-T15]

## Command 1 — checked-criterion count

Command: `git grep -h -c "^- \[x\] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
EXIT_CODE: 0

Output:

```
24
```

`-h` suppresses the file-path prefix that `git grep -c` otherwise emits, so the output is a bare
numeric count.

## Command 2 — criterion lines added or removed by this cycle

Command: `git diff 65a56cb94352c2a19c381acf4008837fa84aee69 -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md | awk '/^[-+]/ && /\[x\] AC/ {n++} END {print n+0}'`
EXIT_CODE: 0

Output:

```
0
```

## Why the diff is anchored at `65a56cb9` and not at the merge base

`65a56cb94352c2a19c381acf4008837fa84aee69` is the branch head at this remediation cycle's entry, so
it is the anchor that answers the question this task asks: what did **this cycle** do to `spec.md`.

The merge base `a36b6dca` would be the wrong anchor here. `spec.md` exists at `a36b6dca` but carries
all 24 criteria unchecked there; commit `65a56cb9` checked them off. A merge-base anchor would
therefore render all 24 checked-criterion lines as additions and the `awk` stage would print 24
regardless of any executor action, which is a condition that cannot fail. Measured against the
current tree, the merge-base anchor prints 24 and the `65a56cb9` anchor prints 0.

This is the deliberate second anchor recorded in the plan's Ordering Constraints item 9. [P6-T11]
and [P6-T12] anchor at the merge base because their question is what the whole branch did to files
that exist there; [P6-T15] anchors at `65a56cb9` because its question is narrower.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
- Work Mode: `full-bug`, so `spec.md` is the sole acceptance-criteria source and `user-story.md` is
  not required.
- Total AC items: 24
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none

## Only edit made to `spec.md` by this cycle

The only edit this cycle makes to `spec.md` is the L5 limitation entry added by [P5-T7] under
`## Known Limitations`. That entry records the `COMMIT|` blind spot for detached HEADs as a
follow-up candidate rather than a defect in this child. It adds no acceptance criterion, removes
none, rewords none, and re-marks none, which is what the `awk` result of 0 confirms.

Output Summary: the checked-criterion count is 24 and the `awk` stage printed 0, meaning no
acceptance-criterion line was added, removed, or reworded by this remediation cycle. The source file
is `spec.md`, with a total AC count of 24, a checked count of 24, and 0 remaining. The only edit this
cycle makes to `spec.md` is the L5 limitation added by [P5-T7]. AC1 through AC24 are preserved.
