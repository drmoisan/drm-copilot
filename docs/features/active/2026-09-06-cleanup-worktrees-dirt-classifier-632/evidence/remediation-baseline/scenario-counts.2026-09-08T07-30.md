# Phase 0 baseline — scenario and record counts

Timestamp: 2026-09-08T07-30
Task: [P0-T9]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l
EXIT_CODE: 0

OnDiskScenarioCount: 25
AssertedRecordTotal: 30

## Where the two literals live

Both are read from `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, in the
membership test titled `every verdict emitted across the checked-in dirt scenarios is one
of the six defined tokens`, which begins at line 214:

- the explicit scenario list at lines **220-228**, naming 25 `dirt_*` directories;
- the on-disk count assertion `[ "$iterated" -eq "$on_disk" ]` at line **246**, which is
  what stops the written-out list falling silently behind the tree;
- the asserted record total `[ "$seen" -eq 30 ]` at line **250**;
- the explanatory comment at lines **247-249**, which states "twenty-five scenarios, of
  which five carry two status entries each".

## Derived end state for this cycle

| Point in the plan | Scenarios | Records | Two-entry scenarios |
|---|---:|---:|---:|
| Start (measured here) | 25 | 30 | 5 |
| After Phase 1 | 26 | 32 | 6 |
| After Phase 3 | 28 | 34 | 6 |

Phase 1 adds one two-entry scenario (`dirt_tracked_staged_only_blob`), taking scenarios to
26 and records to 32. Phase 3 adds two one-entry scenarios
(`dirt_tracked_probe_error_in_history`, `dirt_build_artifact_empty_diff`), taking scenarios
to 28 and records to 34. Each task that adds a directory updates the list, the literal, and
the comment in the same task, so the suite is never left failing on a count.

Output Summary: 25 `dirt_*` scenario directories on disk; the suite asserts a union of 30
`DIRTFILE|` records over them. Both figures match the plan's D4 start row exactly.
