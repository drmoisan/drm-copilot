# P5-T6 — dirt library added to the wrapper source chain

Timestamp: 2026-09-08T02-45
Task: [P5-T6]
Command: grep -n 'source "$SCRIPT_DIR/' scripts/bash/cleanup-worktrees.sh
EXIT_CODE: 0
Command: bash scripts/bash/cleanup-worktrees.sh --help
EXIT_CODE: 0

## Output Summary

`scripts/bash/cleanup-worktrees.sh` now carries six `source "$SCRIPT_DIR/` statements, the sixth
naming the new library:

```
18:source "$SCRIPT_DIR/cleanup_worktrees_enumerate_lib.sh"
23:source "$SCRIPT_DIR/cleanup_worktrees_report_records_lib.sh"
26:source "$SCRIPT_DIR/cleanup_worktrees_lib.sh"
29:source "$SCRIPT_DIR/cleanup_worktrees_actions_lib.sh"
32:source "$SCRIPT_DIR/cleanup_worktrees_detached_lib.sh"
37:source "$SCRIPT_DIR/cleanup_worktrees_dirt_lib.sh"
```

The new block carries the same directive pair the five existing blocks use:

```
# shellcheck source=scripts/bash/cleanup_worktrees_dirt_lib.sh
# shellcheck disable=SC1091
```

`bash scripts/bash/cleanup-worktrees.sh --help` exits 0, and the wrapper's report, apply, and
usage-error dispatch are unchanged (verified by driving the wrapper under the
`merged_with_worktree` scenario: default report exits 0 emitting `WORKTREE|` records, `--apply`
exits 0 emitting `ACTION|worktree-remove|/repo-wt/feat|OK`, and an unrecognised word exits 2).

## Placement

The block is appended after the detached-lib block, which is the resolution recorded in
`evidence/other/plan-to-tree-drift.2026-09-08T01-30.md` item 3 and accepted by the orchestrator
before Phase 4. Position is behaviorally neutral here — no library in this family executes a
statement at source time and every function is resolved at call time — so the placement follows the
accepted record rather than the plan's superseded "after the actions-lib block" wording.

## Acceptance-text discrepancy

The task's acceptance clause reads "the file contains four `source "$SCRIPT_DIR/` statements, the
fourth names `cleanup_worktrees_dirt_lib.sh`", and locates the actions-lib block at `:22-24`. Both
describe a tree that predates issues 630 and 631, which added
`cleanup_worktrees_detached_lib.sh` and `cleanup_worktrees_report_records_lib.sh`. The measured
pre-change count was five, not three.

The count of four is therefore unsatisfiable as literal text and is not a requirement on this work:
reaching it would mean deleting two sibling source blocks, which is out of scope and would break
`run_report`. The substantive requirement — that the wrapper sources
`scripts/bash/cleanup_worktrees_dirt_lib.sh` with the same directive pair, and that `--help` still
exits 0 — is satisfied, and the corrected count of six is the one recorded in the drift artifact.
