# Final QC Stage 3 — Bats Suite

Timestamp: 2026-09-07T16-30
Task: [P6-T3]
Iteration: 1

Command: `npx --yes bats --tap tests/shell`
EXIT_CODE: 0

## TAP result

Plan line:

```
1..321
```

- TAP plan count: 321
- Lines beginning `ok`: 321
- Lines beginning `not ok`: 0

## Case-count reconciliation

321 = 308 + 13.

- 308 is the [P0-T6] remediation baseline recorded in
  `evidence/remediation-baseline/bats-suite.2026-09-07T15-00.md`.
- 13 is the number of cases this remediation cycle adds: six in Phase 2, six in Phase 4, and one in
  [P5-T6].

## The 13 case names added by this cycle

In `tests/shell/test_cleanup_worktrees_detached.bats` (12):

1. `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD` ([P2-T1])
2. `apply removes a content-neutral detached worktree without force` ([P2-T2])
3. `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD` ([P2-T3])
4. `apply removes a cherry-equivalent detached worktree without force` ([P2-T4])
5. `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD` ([P2-T5])
6. `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main` ([P2-T6])
7. `a protection-set hard failure fails closed as ANCESTRY_ERROR` ([P4-T1])
8. `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR` ([P4-T2])
9. `a cherry hard failure fails closed as ANCESTRY_ERROR` ([P4-T3])
10. `a diff-tree hard failure fails closed as ANCESTRY_ERROR` ([P4-T4])
11. `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR` ([P4-T5])
12. `reverify_detached_delete_eligible blocks on a classification hard failure` ([P4-T6])

In `tests/shell/test_cleanup_worktrees_cli.bats` (1):

13. `--help documents the apply-mode exit-code change for blocked detached removals` ([P5-T6])

Output Summary: `npx --yes bats --tap tests/shell` exited 0. The TAP plan count is 321, which is the
[P0-T6] baseline of 308 plus the 13 cases this cycle adds — six in Phase 2, six in Phase 4, and one
in [P5-T6] — and all 13 case names are enumerated above. No output line begins with `not ok`. Stage
3 passes; no restart of the loop at [P6-T1] is required.
