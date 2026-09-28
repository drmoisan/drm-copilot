# P4-T4 — classify_worktree_dirt pass-after gate (18 of 19)

Timestamp: 2026-09-08T02-30
Task: [P4-T4]
Command: npx --yes bats tests/shell/test_cleanup_worktrees_dirt_classify.bats
EXIT_CODE: 1
ExpectedExitCode: 1

## Command form note

The plan states the gate as
`wsl -d Ubuntu -- bash -lc 'cd /mnt/c/.../agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_dirt_classify.bats'`.
It was executed by the orchestrator as `npx --yes bats <suite>` from the Windows worktree
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`. bats 1.13.0 via
npx is the same runner version CI uses. The bats invocation, the suite under test, and the tree under
test are unchanged; only the shell that launches bats differs.

## Output Summary

18 `ok`, 1 `not ok`, exit 1. The single failure is test 19:

```
not ok 19 dirt_mixed_unique_blocks: report mode emits the two per-file records and the aggregate immediately after that worktree's WORKTREE record
```

This is exactly the outcome the task's acceptance clause requires: tests 1 through 18 report `ok`
and exactly one `not ok` line appears, naming test 19.

## Why test 19 is the expected failure

Test 19 is the only test in the suite that drives `run_report` rather than calling
`classify_worktree_dirt` directly. It asserts the placement of the two `DIRTFILE|` records and the
`DIRTSUM|` aggregate immediately after the `WORKTREE|/repo-wt/dirt|` line, and that placement is
produced by the report-mode call site, which does not exist until [P5-T3]. The remaining eighteen
tests exercise `classify_dirt_entry` and `classify_worktree_dirt` through the
`CLEANUP_WT_GIT_BIN` plus `CLEANUP_WT_STUB_SCENARIO` seam and are reachable without that call site.

The full-pass gate for this suite, with all nineteen tests passing and `EXIT_CODE: 0`, is [P5-T3]
and is recorded in `pass-after-dirt-classify-full.<run-timestamp>.md`.

## Pre-run prediction (recorded before the gate ran)

Predicted: EXIT 1, 18 ok, 1 not ok, the failing test being test 19. Observed: identical.
