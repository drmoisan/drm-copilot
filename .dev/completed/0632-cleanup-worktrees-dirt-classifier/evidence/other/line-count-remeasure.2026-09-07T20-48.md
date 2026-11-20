# Line-Count Remeasure and File-Size Contingency Decision

Timestamp: 2026-09-07T20-48
Task: [P0-T7], and the contingency decision consumed by [P0-T8]
Issue: #632
Branch: bug/cleanup-worktrees-dirt-classifier-632-r2
Measured at HEAD: 4ffe680ebcebaabbba10faaa490e46a717686535 (the epic integration branch commit this branch is based on, after issue #631 merged)

## Command form actually used (execution amendment EA-1)

The plan's P0-T7 command block is written as a bare `wsl -d Ubuntu -- bash -lc 'cd /mnt/c/.../agent-a3944b95a7d58e712 && wc -l ...'`. That path names the preparation worktree rather than this one, and the bare-`wsl` form is forbidden by execution amendment EA-1. The plan's command string is therefore treated as naming the logical measurement, not as a literal command.

Command: `wc -l scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup-worktrees.sh tests/fixtures/cleanup_worktrees/stub-bin/git`
Invocation: run under Git Bash with the working directory set to this worktree root, `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`.
EXIT_CODE: 0

The orchestrator independently captured the same five counts in this same worktree at this same HEAD and supplied them ahead of execution. The executor's own run reproduced all five values exactly, so the measurement is corroborated by two independent runs rather than carried over from the plan's research figures.

## Measured counts

```
   490 scripts/bash/cleanup_worktrees_lib.sh
   417 scripts/bash/cleanup_worktrees_actions_lib.sh
   236 scripts/bash/cleanup_worktrees_enumerate_lib.sh
   128 scripts/bash/cleanup-worktrees.sh
   246 tests/fixtures/cleanup_worktrees/stub-bin/git
  1517 total
```

HEADROOM_CLEANUP_WORKTREES_LIB: 10

Derivation of the headroom: 500 (the file-size cap in `.claude/rules/shell.md` and `.claude/rules/general-code-change.md`) minus 490 (the measured count of `scripts/bash/cleanup_worktrees_lib.sh`) = 10.

## Threshold derivation

The plan's threshold is the exact line budget this plan spends in `scripts/bash/cleanup_worktrees_lib.sh`:

- 2 lines from [P5-T2] — the two report-line contract comment lines documenting `DIRTFILE|` and `DIRTSUM|`.
- 2 lines from [P5-T3] — one explanatory comment line and one guarded `classify_worktree_dirt` call line inside the `run_report` worktree loop.

Threshold = 2 + 2 = 4.

## Decision

10 >= 4, so the headroom exceeds the budget.

CONTINGENCY: NOT-REQUIRED

ContingencyDecision: CONTINGENCY: NOT-REQUIRED

[P0-T8] is explicitly authorized by its own task text to be skipped when this token is `CONTINGENCY: NOT-REQUIRED`, and is marked complete on that basis. `run_report` is not extracted from `scripts/bash/cleanup_worktrees_lib.sh`, no `scripts/bash/cleanup_worktrees_report_lib.sh` is created, and every subsequent plan task that names `scripts/bash/cleanup_worktrees_lib.sh` as a `run_report` edit target keeps that target unchanged.

## Additional measurement recorded for the implementation to respect

Two sibling libraries in the same family are close to the cap and are not edit targets of this plan:

- `scripts/bash/cleanup_worktrees_report_records_lib.sh` — 476 lines (headroom 24).
- `scripts/bash/cleanup_worktrees_detached_lib.sh` — 301 lines (headroom 199).

The classifier is delivered in the new file `scripts/bash/cleanup_worktrees_dirt_lib.sh`, as the acceptance criteria require. No existing file is grown toward the cap by this work beyond the four budgeted lines in `scripts/bash/cleanup_worktrees_lib.sh` and the header-comment insertion in `scripts/bash/cleanup_worktrees_actions_lib.sh`.

Output Summary: Five files measured. `scripts/bash/cleanup_worktrees_lib.sh` is 490 lines, giving 10 lines of headroom against the 500-line cap, which exceeds the 4-line budget this plan spends in that file. Decision token `CONTINGENCY: NOT-REQUIRED`; the `run_report` extraction contingency does not run.
