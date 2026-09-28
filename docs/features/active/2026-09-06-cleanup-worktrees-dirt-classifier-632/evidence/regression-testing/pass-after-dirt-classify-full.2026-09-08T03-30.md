# P5-T3 — classify suite pass-after the report-mode call site

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-28Z. This feature's evidence set uses a nominal run-timestamp
scheme that runs ahead of the host clock; the nominal value is kept so artifacts sort in the
order the gates were run.
Run by: atomic-executor, directly (`npx --yes bats`, bats 1.13.0, matching the CI runner version).

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_classify.bats`
EXIT_CODE: 0

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
EXIT_CODE: 0

## Classify suite — 19 ok / 0 not ok

```
1..19
ok 1 dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT
ok 2 dirt_build_artifact: no find-object history walk runs for the classified project file
ok 3 dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE
ok 4 dirt_session_artifact: the session artifact is DISPOSABLE_SESSION_ARTIFACT
ok 5 dirt_session_artifact: no git invocation names the session artifact path
ok 6 dirt_content_on_main: an untracked blob equal to main's blob is CONTENT_ON_MAIN
ok 7 dirt_content_on_main: no find-object history walk runs
ok 8 dirt_content_in_history: the detail field carries the find-object commit sha
ok 9 dirt_staged_tree_is_commit: staged entries carry the matching commit sha
ok 10 dirt_staged_tree_is_commit: the aggregate detail field carries the same commit sha
ok 11 dirt_staged_tree_is_commit: the first rev-list entry is never probed
ok 12 dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths
ok 13 dirt_unique: an unmatched untracked file is UNIQUE and the worktree is HAS_UNIQUE
ok 14 dirt_classifier_read_error: a non-zero classifier read yields UNIQUE and HAS_UNIQUE
ok 15 every verdict emitted across the fifteen dirt scenarios is one of the six defined tokens
ok 16 dirt_mixed_unique_blocks: two entries emit two per-file records in porcelain order then one aggregate
ok 17 dirt_pipe_path: the file path is the last field and the detail field is empty
ok 18 dirt_quoted_path: a C-quoted path is UNIQUE and no unquoting is attempted
ok 19 dirt_mixed_unique_blocks: report mode emits the two per-file records and the aggregate immediately after that worktree's WORKTREE record
```

## Regression suite — 11 ok / 0 not ok

```
1..11
ok 1 report mode output for merged_with_worktree is byte-identical to the checked-in expected output
ok 2 report mode output for merged_no_worktree is byte-identical to the checked-in expected output
ok 3 report mode output for unmerged is byte-identical to the checked-in expected output
ok 4 report mode output for content_neutral is byte-identical to the checked-in expected output
ok 5 report mode output for residual_on_main is byte-identical to the checked-in expected output
ok 6 report mode output for residual_unique_doc is byte-identical to the checked-in expected output
ok 7 report mode output for current_exclusion is byte-identical to the checked-in expected output
ok 8 report mode output for main_divergence is byte-identical to the checked-in expected output
ok 9 apply mode without --clear-disposable over dirty_worktree is byte-identical
ok 10 apply mode without --clear-disposable over dirty_worktree_status_error is byte-identical
ok 11 report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM record
```

Output Summary: both gates pass. Test 19 of the classify suite is this task's subject: it is the
only test in that suite that observes the `run_report` call site, and it reported `not ok` at
P4-T4 before the call site existed. It now reports `ok`, and the eleven byte-identity tests still
pass, so adding the call site changed no pre-existing report or apply output.
