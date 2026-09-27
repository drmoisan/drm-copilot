# Bug: cleanup-worktrees-bats-vacuous-t9-and-stale-citation

- Issue: #715
- Type: bug
- Work Mode: full-bug
- Source: GitHub issue #715 body (the promoted lifecycle record is not present on this branch)

## Summary

The review of issue #594 (PR #705) found two test-quality defects in the cleanup-worktrees bats suites. T9 carries a negative assertion that cannot fail, and a comment cites a stale production line number.

## Environment

- OS/version: any
- Python version: n/a (bats)
- Command/flags used: `npx bats tests/shell`
- Data source or fixture: `tests/fixtures/cleanup_worktrees/` stub git

## Steps to Reproduce

1. In `tests/shell/test_cleanup_worktrees_deletion.bats`, T9 asserts `[[ "$output" != *"merge-base"* ]]`.
2. `classify_ancestry` runs `merge-base --is-ancestor` with `>/dev/null 2>&1`, so the stub's `stub-git:` stderr line is always discarded, and the assertion passes whether or not merge-base ran.
3. `tests/shell/test_cleanup_worktrees_dirt_clear.bats:14` cites `scripts/bash/cleanup-worktrees.sh:145` for the flag pre-pass; that line is `:197` on current main.

## Expected Behavior

T9's negative assertion can observe the call it forbids, and the comments reference code by a stable anchor.

## Actual Behavior

T9's merge-base check is vacuous. The guard ordering is still pinned indirectly, because a guard placed after re-verification would emit `BLOCKED-REVERIFY`, not `BLOCKED-PROTECTED-BASE`. The line-14 citation is stale and grows staler with each edit.

## Logs / Screenshots

- Snippet: #594 `code-review.2026-09-27T02-18.md`, rows 35-36.

## Impact / Severity

- Low

## Acceptance Criteria

- [ ] T9 in `tests/shell/test_cleanup_worktrees_deletion.bats` replaces the vacuous `merge-base` negative assertion with a negative assertion over a re-verification call that reaches the stub's observable argv output when it occurs, so the assertion fails if the protected-base guard is moved after re-verification.
- [ ] The citation of `scripts/bash/cleanup-worktrees.sh:145` in `tests/shell/test_cleanup_worktrees_dirt_clear.bats` is replaced by a stable, non-line-number anchor that identifies the flag pre-pass.
- [ ] The full bats suite under `tests/shell` passes in CI with no production-code change required.

## Source

From: docs/features/potential/2026-09-26-cleanup-worktrees-bats-vacuous-t9-and-stale-citation.md (GitHub issue #715; the issue body declares minor-audit, and this run's operator directive selects full-bug).
