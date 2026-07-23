# CR-1 Hard-Failure Regression — Fail-Before Evidence (Cycle 2), Issue #396

Timestamp: 2026-07-22T20-54

Command:

```
git commit (e09c0e92: split + fixtures + tests, no Phase 3 fix)
git push origin drm-copilot-wt-2026-07-21T21-57
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29970355445 --exit-status
gh run view 29970355445 --log-failed
```

EXIT_CODE: 1

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29970355445 (red, headSha e09c0e92f32c0a798df129862bdc7be74434e1c8)

## TAP result

- Plan line: `1..85` (80 pre-existing tests + 5 new hard-failure tests).
- Failing tests: exactly 5, all new. Every one of the 80 pre-existing tests passed, including the Phase 1 split (the four suites that now source `cleanup_worktrees_enumerate_lib.sh` before `cleanup_worktrees_lib.sh`).

Failing (`not ok`) lines:

```
not ok 9  worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict
not ok 10 worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines
not ok 11 cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure
not ok 12 rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record
not ok 41 parse_worktree_list returns non-zero and emits no records on a git worktree-list hard failure
```

## Pre-fix observed fail-open verdicts (local reproduction against the same fixtures)

| Scenario | Function | Fail-open (pre-fix) result | Required (post-fix) result |
|---|---|---|---|
| `worktree_list_error` | `parse_worktree_list` | status 0, no records (rc lost) | status != 0, no records |
| `worktree_list_error` | `classify_branch feature-x` | `BRANCH\|feature-x\|MERGED_EQUIVALENT`, status 0 | `BRANCH\|feature-x\|ANCESTRY_ERROR`, status 2 |
| `worktree_list_error` | `run_report` | emits `MERGED_EQUIVALENT`/`MERGED_CLEAN`, status 0 | status != 0, no `MERGED`/`WORKTREE\|` |
| `cherry_error` | `classify_branch feature-cherryfail` | `BRANCH\|feature-cherryfail\|MERGED_EQUIVALENT`, status 0 | `BRANCH\|feature-cherryfail\|ANCESTRY_ERROR`, status 2 |
| `rev_list_error` | `classify_branch feature-revfail` | `BRANCH\|feature-revfail\|HAS_UNIQUE_RESIDUALS`, status 0 | same line, status != 0 |

Output Summary: Red run confirms the fail-open defect. Exactly the 5 new tests fail (classification #9–#12, enumeration #41); all 80 pre-existing tests pass (`1..85` plan). The pre-fix path silently resolves git worktree-list / cherry / rev-list hard failures to delete-eligible or status-0 verdicts. Pass-after evidence is recorded in Phase 4 after the Phase 3 fix.
