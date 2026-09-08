# Record — the duplicate record-type list in the library header is left stale by design

Timestamp: 2026-09-08T11-40
Task: `[P8-T6]`
Command: (decision record; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: three copies of the record-type list exist. Two were updated by this work and one
was deliberately not. The stale copy is the header comment of
`scripts/bash/cleanup_worktrees_lib.sh`.

## The three copies

| Location | Treated how |
| --- | --- |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `## Report Line Contract` | **Updated** by `[P8-T1]`, and mirrored into the push-down bundle by `[P8-T3]` |
| `scripts/bash/cleanup-worktrees.sh`, the `usage()` heredoc | **Updated** by `[P4-T8]` |
| `scripts/bash/cleanup_worktrees_lib.sh`, the library header comment | **Deliberately not updated** |

## Why the third copy is left stale

`scripts/bash/cleanup_worktrees_lib.sh` is the contended library. It stood at 479 of its 500-line
cap when the plan was written and at **490** when this work measured it, so its headroom is ten
lines rather than the twenty-one the plan assumed. Three serialized sibling children hold that file
open. Adding one comment line there, for a documentation-only change, would create a fan-in conflict
for no behavioral benefit and would consume a tenth of the remaining headroom.

The inconsistency is therefore recorded rather than silently accepted. It belongs to whichever
sibling next has that file open with spare headroom. Nothing in this work reads that comment: the
record-type vocabulary that governs behavior lives in the wrapper's `usage()` heredoc and in the
skill's contract section, both of which are current.

`[P9-T1]` verifies independently that this work introduces no diff to that file at all.
