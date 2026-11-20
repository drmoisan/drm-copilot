# R1 Detached Suite Run (after Phase 2)

Timestamp: 2026-09-07T15-00
Task: [P2-T7]

Command: `npx --yes bats --tap tests/shell/test_cleanup_worktrees_detached.bats`
EXIT_CODE: 0

## Output (verbatim)

```
1..20
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
```

## The six cases added by [P2-T1] through [P2-T6]

| Task | Case name | TAP line |
|---|---|---|
| [P2-T1] | `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD` | `ok 15` |
| [P2-T2] | `apply removes a content-neutral detached worktree without force` | `ok 16` |
| [P2-T3] | `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD` | `ok 17` |
| [P2-T4] | `apply removes a cherry-equivalent detached worktree without force` | `ok 18` |
| [P2-T5] | `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD` | `ok 19` |
| [P2-T6] | `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main` | `ok 20` |

Output Summary: the TAP plan count is 20, which is the pre-cycle detached-suite count of 14 plus the
six cases added by [P2-T1] through [P2-T6]. No output line begins with `not ok`, and all six new case
names appear in the `ok` lines above. The destructive `git worktree remove` path is now exercised from
the `MERGED_CONTENT_NEUTRAL` verdict (`ok 16`) and from the `MERGED_EQUIVALENT` verdict (`ok 18`), and
the non-eligible `HAS_UNIQUE_RESIDUALS` terminal is proven to block it (`ok 19`).
