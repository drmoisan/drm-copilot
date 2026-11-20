# P5-T13 — removal call-site invariant across the production shell tree

Timestamp: 2026-09-08T02-45
Task: [P5-T13]
Command: grep -rn "cleanup_wt_git worktree remove" scripts/bash/
EXIT_CODE: 0

## Output Summary

Exactly two matching lines, both in `scripts/bash/cleanup_worktrees_actions_lib.sh`, neither
carrying the token `--force`:

```
scripts/bash/cleanup_worktrees_actions_lib.sh:191:		cleanup_wt_git worktree remove "$path" >/dev/null || wrc=$?
scripts/bash/cleanup_worktrees_actions_lib.sh:292:	cleanup_wt_git worktree remove "$path" >/dev/null || rc=$?
```

Line 191 is the consolidation abort cleanup (`cleanup_consolidation_on_abort`). Line 292 is the
single call inside `remove_worktree_safe`. This is the same pair that existed before the change: the
clear-and-retry block added by [P5-T5] calls `remove_worktree_safe` a second time rather than
issuing its own removal, so no third call site was introduced.

## Supplementary scan for alternative spellings

A wider `grep -rn "worktree remove" scripts/bash/` returns four further matches, all of which are
comment text and none of which is an executable statement:

```
scripts/bash/cleanup_worktrees_actions_lib.sh:283  (remove_worktree_safe header comment)
scripts/bash/cleanup_worktrees_detached_lib.sh:237 (comment; the detached path routes through
                                                    remove_worktree_safe)
scripts/bash/cleanup_worktrees_dirt_lib.sh:389     (comment stating the clearing function never
                                                    invokes a removal)
scripts/bash/cleanup_worktrees_report_records_lib.sh:195 (comment)
```

The supplementary scan is recorded because the primary grep is anchored on the `cleanup_wt_git`
wrapper and would not see a removal issued through some other spelling. No such spelling exists.

## Never-force invariant

Neither executable line carries `--force`. `clear_disposable_dirt` issues `reset --hard` and
`clean -fd` only; the flags `-x`, `-X`, and `-ff` appear nowhere in the clearing sequence. The retry
is the same unforced removal, which is why the flag is documented as not being force-removal.
