# Cycle-3 Hard-Failure Fail-Before Evidence, Issue #396

Timestamp: 2026-07-22T21-56

Command:

```
git push origin drm-copilot-wt-2026-07-21T21-57            # commit 556749f8
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29972970639 --exit-status
gh run view 29972970639 --log
```

EXIT_CODE: 1

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29972970639 (RED, headSha 556749f85caa056b5f44e75b97cc0926e1bdb0ac)

## Result (bats)

- TAP plan: `1..102` (85 pre-existing tests + 17 new hard-failure tests).
- `not ok` count: 13 — exactly the 13 fail-before tests from P2-T10, and no others.
- The 13 failing tests are TAP entries 42-54 (suite-local tests 1-13):

```
not ok 42 1 diff_tree_error: classify_branch reports ANCESTRY_ERROR, never a MERGED_* verdict on a diff-tree hard failure
not ok 43 2 residual_namestatus_error: classify_residual_commit reports RESIDUAL_ERROR, never CONTENT_ON_MAIN
not ok 44 3 ls_tree_error: classify_branch reports ANCESTRY_ERROR on a D-rung ls-tree hard failure
not ok 45 4 rev_parse_error_protection: compute_protected returns non-zero on a rev-parse hard failure
not ok 46 5 rev_parse_error_protection: classify_branch reports ANCESTRY_ERROR for the current branch, never MERGED_CLEAN
not ok 47 6 enumerate_error: enumerate_branches returns non-zero with empty stdout on a for-each-ref hard failure
not ok 48 7 enumerate_error: run_report returns non-zero and emits no BRANCH or WORKTREE lines
not ok 49 8 enumerate_error: run_apply returns non-zero and emits no ACTION lines
not ok 50 9 worktree_list_error: run_apply returns non-zero and emits no ACTION or WORKTREE lines
not ok 51 10 consolidation_path_error: consolidation_worktree_path returns non-zero with empty stdout on a worktree-list hard failure
not ok 52 11 consolidation_path_empty: consolidation_worktree_path returns non-zero with empty stdout on an empty main worktree path
not ok 53 12 consolidation_path_error: create_consolidation_worktree returns non-zero and emits no worktree-add action
not ok 54 13 consolidation_path_error: cleanup_consolidation_on_abort reports worktree-remove FAILED (path unknown) and still deletes the branch
```

- The four pass-before regression guards pass (TAP entries 55-58 = suite-local tests 14-17):

```
ok 55 14 deleted_path_on_main: classify_branch is NOT_MERGED because the deletion is unique work
ok 56 15 deleted_path_absent: classify_branch is MERGED_EQUIVALENT for a legitimately droppable deletion
ok 57 16 worktree_list_error: reverify_delete_eligible blocks (BLOCKED-REVERIFY) when classification hard-fails
ok 58 17 dirty_worktree_status_error: remove_worktree_safe blocks (BLOCKED-DIRTY) when the status read hard-fails
```

- All 85 pre-existing tests (TAP entries 1-41, 59-102) pass.

## Pre-fix observed fail-open verdicts (deterministic; observed locally by sourcing the unmodified libs under the same stub/fixtures)

| Test | Function / scenario | Pre-fix observed (fail-open) | Post-fix required |
|---|---|---|---|
| 1 | classify_branch / diff_tree_error | `BRANCH|feature-dtfail|MERGED_EQUIVALENT`, status 0 | `ANCESTRY_ERROR`, status 2 |
| 2 | classify_residual_commit / residual_namestatus_error | `CONTENT_ON_MAIN` | `RESIDUAL_ERROR` |
| 3 | classify_branch / ls_tree_error | `BRANCH|feature-dfail|MERGED_EQUIVALENT`, status 0 | `ANCESTRY_ERROR`, status 2 |
| 4 | compute_protected / rev_parse_error_protection | `protected-path|/repo/main`, status 0 | status non-zero |
| 5 | classify_branch / rev_parse_error_protection | `BRANCH|curbranch|MERGED_CLEAN`, status 0 | `ANCESTRY_ERROR`, status 2 |
| 6 | enumerate_branches / enumerate_error | empty stdout, status 0 | status non-zero |
| 7 | run_report / enumerate_error | `WORKTREE|/repo/main|main|main`, status 0 | non-zero, no lines |
| 8 | run_apply / enumerate_error | `WORKTREE|...`, status 0 | non-zero, no ACTION |
| 9 | run_apply / worktree_list_error | `BRANCH|...|ANCESTRY_ERROR` lines, status 0 | non-zero, no lines |
| 10 | consolidation_worktree_path / consolidation_path_error | `-wt/documentationandmemories`, status 0 | non-zero, empty |
| 11 | consolidation_worktree_path / consolidation_path_empty | `-wt/documentationandmemories`, status 0 | non-zero, empty |
| 12 | create_consolidation_worktree / consolidation_path_error | `ACTION|worktree-add|-wt/documentationandmemories|OK`, status 0 | non-zero, no add |
| 13 | cleanup_consolidation_on_abort / consolidation_path_error | `ACTION|worktree-remove|-wt/documentationandmemories|OK` | `ACTION|worktree-remove||FAILED` |

Output Summary: Deliberate red CI run 29972970639 on the pre-fix commit 556749f8.
TAP `1..102`; exactly 13 `not ok` (TAP 42-54 = fail-before tests 1-13); guards 14-17 and
all 85 pre-existing tests pass. The pre-fix fail-open verdicts (MERGED_EQUIVALENT under
diff_tree_error and ls_tree_error; MERGED_CLEAN under rev_parse_error_protection; status-0
"clean" runs under enumerate_error/worktree_list_error; malformed
`-wt/documentationandmemories` derivation under the consolidation scenarios) are recorded.
This satisfies the fail-before requirement for the 13 constructible sites; the remaining
three sites are covered by `fail-before-exception.2026-07-22T21-16.md`.
