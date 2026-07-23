# Final QA — Shell Coverage via CI (Cycle 2 / CR-1), Issue #396

Timestamp: 2026-07-22T21-08

Command:

```
git push origin drm-copilot-wt-2026-07-21T21-57
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29970805348 --exit-status
gh run view 29970805348 --log
```

EXIT_CODE: 0

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29970805348 (green, headSha 8ba4fb79e03f85163587c400cbfd881ea9642630)

## Test result (bats)

- TAP plan: `1..85` (80 pre-existing tests + 5 new hard-failure tests).
- Failures: 0 (`not ok` count = 0).
- The five new hard-failure tests all pass:

```
ok 9  worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict
ok 10 worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines
ok 11 cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure
ok 12 rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record
ok 41 parse_worktree_list returns non-zero and emits no records on a git worktree-list hard failure
```

## Coverage

- `Bash coverage (lines): 90.4%` (kcov line coverage; branch coverage is not applicable for bash per `.claude/rules/shell.md`).

Output Summary: Green run on the fix commit. 85/85 bats tests pass (0 failures), including the five CR-1 hard-failure tests that were red in the fail-before run (29970355445). Overall bash line coverage is 90.4% (>= 85% threshold; >= 89.0% baseline). Per-file line rates are verified in `coverage-delta.2026-07-23T00-30.md` (P4-T5).
