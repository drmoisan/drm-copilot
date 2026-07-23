# Cycle-3 Hard-Failure Pass-After Evidence, Issue #396

Timestamp: 2026-07-22T22-19

Command:

```
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29973982957 --exit-status
gh run view 29973982957 --log
```

EXIT_CODE: 0

Pass-after run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29973982957 (GREEN, headSha a1b39a4d)
Fail-before run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29972970639 (RED, headSha 556749f8), recorded in `cycle3-hard-failure.fail-before.2026-07-22T21-16.md`.

## Fail-before / pass-after pairing per fixed site

Each of the 13 constructible fail-before tests was `not ok` in run 29972970639 (pre-fix)
and is `ok` in run 29973982957 (post-fix). TAP entry numbers are stable across both runs.

| TAP | Suite test | Fixed site (Phase 3 task) | Fail-before (29972970639) | Pass-after (29973982957) |
|---|---|---|---|---|
| 42 | 1 diff_tree_error | NEW-1 site 1, DIFF_TREE_ERROR (P3-T1/P3-T4) | not ok (MERGED_EQUIVALENT) | ok (ANCESTRY_ERROR, status 2) |
| 43 | 2 residual_namestatus_error | NEW-1 site 2, RESIDUAL_ERROR (P3-T2) | not ok (CONTENT_ON_MAIN) | ok (RESIDUAL_ERROR) |
| 44 | 3 ls_tree_error | D-rung ls-tree probe (P3-T3/P3-T4) | not ok (MERGED_EQUIVALENT) | ok (ANCESTRY_ERROR, status 2) |
| 45 | 4 rev_parse_error_protection | NEW-2 compute_protected (P3-T9) | not ok (status 0) | ok (non-zero status) |
| 46 | 5 rev_parse_error_protection | NEW-2 classify_branch map (P3-T9) | not ok (MERGED_CLEAN) | ok (ANCESTRY_ERROR, status 2) |
| 47 | 6 enumerate_error | enumerate pipeline (P3-T8) | not ok (status 0, empty) | ok (non-zero, empty stdout) |
| 48 | 7 enumerate_error | NEW-3 run_report (P3-T7) | not ok (WORKTREE line, status 0) | ok (non-zero, no lines) |
| 49 | 8 enumerate_error | NEW-3 run_apply (P3-T13) | not ok (status 0) | ok (non-zero, no ACTION) |
| 50 | 9 worktree_list_error | run_apply classification rc (P3-T13) | not ok (status 0) | ok (non-zero, no lines) |
| 51 | 10 consolidation_path_error | NEW-4 path derivation (P3-T10) | not ok (malformed path) | ok (non-zero, empty stdout) |
| 52 | 11 consolidation_path_empty | NEW-4 empty main path (P3-T10) | not ok (malformed path) | ok (non-zero, empty stdout) |
| 53 | 12 consolidation_path_error | NEW-4 consumer (P3-T11a) | not ok (worktree-add OK) | ok (non-zero, no worktree-add) |
| 54 | 13 consolidation_path_error | NEW-4 consumer (P3-T11b) | not ok (worktree-remove OK) | ok (worktree-remove FAILED, branch deleted) |

## Structurally-unfailable sites (exception dossier)

Three fixed sites have no constructible pre-fix failing run; they are covered by
`fail-before-exception.2026-07-22T21-16.md` and pinned by pass-after regression guards:

- `classify_branch` minus-present cherry re-invocation removal (P3-T6): the stub keys both
  `git cherry main <branch>` invocations identically, so a hard-failure fixture fails the
  first (guarded) invocation before the second is reached. Post-fix the second invocation
  is structurally removed; guards NOT_MERGED / HAS_UNIQUE_RESIDUALS semantics hold (all 85
  pre-existing tests pass in run 29973982957).
- `reverify_delete_eligible` conversion (P3-T12a): fail-closed before and after; guard 16
  (TAP 57 `ok`) pins BLOCKED-REVERIFY on a classification hard failure.
- `remove_worktree_safe` status-read conversion (P3-T12b): diagnostic-only, fail-closed
  before and after; guard 17 (TAP 58 `ok`) pins BLOCKED-DIRTY on a status-read hard failure.

Output Summary: Every fixed site has one fail-before observation (red run 29972970639, or
the P2-T11 exception dossier for the three structurally-unfailable sites) paired with one
pass-after observation (green run 29973982957). All 13 constructible fail-before tests pass
post-fix; all 4 guards and all 85 pre-existing tests pass; 102/102 ok, 0 not ok.
