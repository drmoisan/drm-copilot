# Sibling check — Phase 2 (R1, rung-1 Y-column gate)

Timestamp: 2026-09-08T06-10

Task: [P2-T6] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
```

EXIT_CODE: 0

TAP plan line: `1..43`
Lines beginning `ok`: 43
Lines beginning `not ok`: 0

## Sibling region checked

The rung-1 edit changes which entries reach the rung at all, so the two pre-existing
scenarios that sit on either side of the new gate were re-run:

- `dirt_staged_tree_is_commit` — X column `M`, Y column a space, on both of its entries.
  The gate must not disturb it: both entries must remain `STAGED_TREE_IS_COMMIT|eeee7777`
  and the aggregate must remain `ALL_DISPOSABLE|eeee7777`. Four tests in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` read this scenario, plus the two
  non-mutation tests in `tests/shell/test_cleanup_worktrees_dirt_clear.bats`. All pass.
- `dirt_build_artifact` — X column a space, so rung 1 was already declined for it before
  this change and must still be. The build-artifact verdict must be unaffected. Both of its
  tests pass.

The clear-mode suite is included because an entry that stopped resolving
`STAGED_TREE_IS_COMMIT` would change its worktree's aggregate from `ALL_DISPOSABLE` to
`HAS_UNIQUE` and turn a clear into a `REFUSED-UNIQUE`. That failure would not surface in the
verdict suite alone.

The byte-identity regression suite is included because it pins report-mode and apply-mode
stdout against captures taken before the classifier existed; a rung-1 change that altered
any record for a scenario carrying no dirt would fail there.

Output Summary: All 43 tests in the three pre-existing dirt suites pass with exit code 0 and
0 `not ok` lines. The Y-column gate changed the verdict for the new `MM` fixture entry and
changed no verdict in any pre-existing scenario.
