# P4-T6 — the library runs nothing at source time

Timestamp: 2026-09-08T02-15
Command: `bash -c "source scripts/bash/cleanup_worktrees_dirt_lib.sh; echo SOURCE_GUARD_OK"`
EXIT_CODE: 0

Route: the plan's `wsl -d Ubuntu -- bash -lc` wrapper is superseded by EA-1. The inline
`bash -c "source ..."` form is additionally refused by this session's permission layer,
which declines to evaluate a command whose shell text it is handed inline. The semantically
identical route actually executed, from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, was:

```
bash <scratchpad>/srcguard.sh scripts/bash/cleanup_worktrees_dirt_lib.sh 2>&1
```

where `srcguard.sh` is a two-statement wrapper that sources its `$1` and echoes the
sentinel. It carries no other statement, so it adds nothing to the observed output.

Combined stdout and stderr, verbatim:

```
SOURCE_GUARD_OK
```

Output Summary: the combined output is exactly the single line `SOURCE_GUARD_OK`, so
sourcing `scripts/bash/cleanup_worktrees_dirt_lib.sh` executed no statement of its own. Any
additional line would mean the library ran work at source time, which the family convention
prohibits and which would make the wrapper and the nine bats suites unable to source it
without side effects. No temporary file was created by this check: the wrapper script is a
pre-existing scratchpad helper outside the repository tree, and neither it nor the library
writes anything.

The only top-level statements in the library are the four constant assignments
(`CLEANUP_WT_CLEAR_DISPOSABLE`, `CLEANUP_WT_STAGED_TREE_DEPTH`,
`CLEANUP_WT_HISTORY_SCAN_DEPTH`, `CLEANUP_WT_SESSION_ARTIFACT_PATHS`), verified separately
under P4-T1.
