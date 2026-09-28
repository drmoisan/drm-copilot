# Scope boundary — the dead consolidation functions remain out of scope

Timestamp: 2026-09-08T11-55
Task: `[P9-T6]`
Command: (scope statement; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: three of the four consolidation functions in
`scripts/bash/cleanup_worktrees_actions_lib.sh` still have no production call site after this work.
Restoring the full consolidation driver is a distinct defect and is recorded as a follow-up
candidate rather than absorbed here.

## The four functions and their reachability after this work

| Function | Line | Reached from production? |
| --- | --- | --- |
| `create_consolidation_worktree` | 70 | **No.** No call site. |
| `cherry_pick_candidates` | 103 | **No.** No call site. |
| `cleanup_consolidation_on_abort` | 165 | **No.** No call site. |
| `verify_consolidation_merged` | 198 | **Yes.** Called from `run_apply`, which gates deletion on the exact token `MERGED_CLEAN`. |

Only `verify_consolidation_merged` is reached from production. The other three were already
unreferenced before this work and remain unreferenced after it.

## Why this work does not restore them

The `preserve` arm consumes the consolidation worktree; it does not create one. Its fail-closed
precondition is that the resolved path must already be an existing directory, and when it is not the
arm emits `ACTION|preserve-stage||MISSING-WORKTREE` and returns 1 rather than creating anything.
That is a deliberate choice recorded in the specification: creating the worktree would hide an
operator mistake behind a directory that looks correct and holds nothing.

The same choice is what lets this child add no abort contract. The host-token refusal is
all-or-nothing and is evaluated before any write, so a blocked pass leaves the consolidation
worktree byte-unchanged and there is nothing to undo. The inability of
`cleanup_consolidation_on_abort` to undo staged files is therefore not a blocker for this work,
which is why it is recorded here rather than repaired here.

## The follow-up

Restoring the full consolidation driver — creating the worktree, cherry-picking the `UNIQUE` commit
candidates, and cleaning up on abort — is a distinct defect with its own blast radius in a file this
work deliberately does not touch. It belongs to a separate issue rather than being absorbed into
this child's scope. This record is the boundary statement, not the fix.
