# R2 Detached Suite Run (after Phase 4)

Timestamp: 2026-09-07T15-00
Task: [P4-T7]

Command: `npx --yes bats --tap tests/shell/test_cleanup_worktrees_detached.bats`
EXIT_CODE: 0

## Output (verbatim)

```
1..26
ok 1 report emits one detached record with MERGED_CLEAN
ok 2 report emits NOT_MERGED for an unmerged detached HEAD
ok 3 is_detached_candidate flag matrix
ok 4 branch-backed worktree records keep the four-field shape
ok 5 apply removes a merged detached worktree without force
ok 6 apply never touches an unmerged detached worktree
ok 7 dirty detached worktree blocks with DIRTY lines
ok 8 locked detached worktree yields BLOCKED-LOCKED and invokes no removal
ok 9 prunable detached worktree is report-only
ok 10 the caller's own detached worktree is PROTECTED_CURRENT
ok 11 a hard git failure maps to ANCESTRY_ERROR with no removal
ok 12 classify_detached_head returns MERGED_CLEAN for an ancestor HEAD
ok 13 classify_detached_head returns 2 on a hard failure
ok 14 reverify_detached_delete_eligible blocks on a flipped verdict
ok 15 report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD
ok 16 apply removes a content-neutral detached worktree without force
ok 17 report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD
ok 18 apply removes a cherry-equivalent detached worktree without force
ok 19 report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD
ok 20 classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main
ok 21 a protection-set hard failure fails closed as ANCESTRY_ERROR
ok 22 a content-neutral probe hard failure fails closed as ANCESTRY_ERROR
ok 23 a cherry hard failure fails closed as ANCESTRY_ERROR
ok 24 a diff-tree hard failure fails closed as ANCESTRY_ERROR
ok 25 a residual ls-tree hard failure fails closed as ANCESTRY_ERROR
ok 26 reverify_detached_delete_eligible blocks on a classification hard failure
```

## The six cases added by [P4-T1] through [P4-T6]

| Task | Case name | TAP line | Guard covered |
|---|---|---|---|
| [P4-T1] | `a protection-set hard failure fails closed as ANCESTRY_ERROR` | `ok 21` | `compute_protected` non-zero |
| [P4-T2] | `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR` | `ok 22` | `CONTENT_NEUTRAL_ERROR` |
| [P4-T3] | `a cherry hard failure fails closed as ANCESTRY_ERROR` | `ok 23` | `CHERRY_ERROR` |
| [P4-T4] | `a diff-tree hard failure fails closed as ANCESTRY_ERROR` | `ok 24` | `DIFF_TREE_ERROR` |
| [P4-T5] | `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR` | `ok 25` | `RESIDUAL_ERROR` |
| [P4-T6] | `reverify_detached_delete_eligible blocks on a classification hard failure` | `ok 26` | `((crc != 0))` in `reverify_detached_delete_eligible` |

Output Summary: the TAP plan count is 26, which is the post-Phase-2 count of 20 plus the six cases
added by [P4-T1] through [P4-T6]. No output line begins with `not ok`, and all six new case names
appear in the `ok` lines above. Each of the five fail-closed branches named in R2 is now asserted by
at least one case; the third R2 row covers two distinct tokens (`CHERRY_ERROR` and
`DIFF_TREE_ERROR`), which [P4-T3] and [P4-T4] assert separately.
