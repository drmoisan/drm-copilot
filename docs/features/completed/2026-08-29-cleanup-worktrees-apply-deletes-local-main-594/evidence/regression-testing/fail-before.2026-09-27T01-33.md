# P1-T20 — Fail-before run (three edited suites, unfixed libraries) [expect-fail]

Timestamp: 2026-09-27T01-33
Task: [P1-T20]
Working directory: repository worktree root
HEAD at run time: `3e12620b482c12b27f473a936bb58dd160a34387` (Phase 0 commit; production libraries unchanged from effective BASE_SHA `92d78897371cc5c4f301c8cc2238adeb3fff2fea`, the rebased counterpart of plan literal `0658f6945aa833c6960dc5bf8a43635fc346991f` per DEV-1). Working tree carries only the uncommitted Phase 1 fixtures and test additions.
Tool: bats-core 1.13.0 via `npx --yes bats`
Run window (UTC): 2026-09-27T01-31-45 to 2026-09-27T01-33-47
ExpectedExitCode: 1

## TAP plan and counts

- TAP plan: `1..52` (P0-T10 per-file `@test` total 12 + 19 + 11 = 42, plus 10 new tests).
- `ok` lines: 43. `not ok` lines: 9.
- Every pre-existing test (TAP 1-12, 16-34, 37-47) reports `ok`.
- T3 (`compute_protected emits exactly one protected-branch main when the current branch is main`, TAP 15) reports `ok`, as expected: it pins the no-duplicate property and passes before the fix.

## Failures (verbatim `not ok` line and first failed assertion printed by bats)

| Test | TAP line | Location | First failed assertion |
|---|---|---|---|
| T1 | `not ok 13 compute_protected emits protected-branch main when the primary worktree is on another branch` | `tests/shell/test_cleanup_worktrees_enumeration.bats`, line 121 | `[[ "$output" == *"protected-branch\|main"* ]]` |
| T2 | `not ok 14 compute_protected emits protected-branch main under current_exclusion` | `tests/shell/test_cleanup_worktrees_enumeration.bats`, line 132 | `[[ "$output" == *"protected-branch\|main"* ]]` |
| T4 | `not ok 35 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch` | `tests/shell/test_cleanup_worktrees_classification.bats`, line 265 | `[ "$output" = "BRANCH\|main\|PROTECTED_CURRENT" ]` |
| T5 | `not ok 36 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree` | `tests/shell/test_cleanup_worktrees_classification.bats`, line 272 | `[ "$output" = "BRANCH\|main\|PROTECTED_CURRENT" ]` |
| T6 | `not ok 48 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` | `tests/shell/test_cleanup_worktrees_deletion.bats`, line 159 | `[[ "$output" == *"BRANCH\|main\|PROTECTED_CURRENT"* ]]` |
| T7 | `not ok 49 run_apply does not delete main when the primary worktree is on another branch` | `tests/shell/test_cleanup_worktrees_deletion.bats`, line 165 | `[[ "$output" == *"BRANCH\|main\|PROTECTED_CURRENT"* ]]` |
| T8 | `not ok 50 run_apply neither removes nor deletes main checked out in a linked worktree` | `tests/shell/test_cleanup_worktrees_deletion.bats`, line 176 | `[[ "$output" == *"BRANCH\|main\|PROTECTED_CURRENT"* ]]` |
| T9 | `not ok 51 delete_candidate refuses the base branch before re-verification` | `tests/shell/test_cleanup_worktrees_deletion.bats`, line 186 | `[ "$status" -eq 1 ]` |
| T10 | `not ok 52 delete_candidate refuses the base branch before removing its linked worktree` | `tests/shell/test_cleanup_worktrees_deletion.bats`, line 196 | `[ "$status" -eq 1 ]` |

(The `\|` in the table escapes the Markdown column separator; bats printed a plain `|`.)

Every first failed line is an assertion about `main` (`protected-branch|main`, `BRANCH|main|PROTECTED_CURRENT`, or, for T9 and T10, `[ "$status" -eq 1 ]`). No failure is caused by a missing fixture or a syntax error.

## Full TAP output (verbatim)

```
1..52
ok 1 enumerate_branches emits name/sha pairs in LC_ALL=C order
ok 2 parse_worktree_list parses a branch stanza and marks the first as main
ok 3 parse_worktree_list parses a detached and locked stanza
ok 4 parse_worktree_list parses a prunable stanza
ok 5 cleanup_wt_git honors an executable CLEANUP_WT_GIT_BIN override
ok 6 cleanup_wt_git falls back to PATH git when the override is empty
ok 7 cleanup_wt_git falls back to PATH git when the override does not exist
ok 8 compute_protected protects the current branch (dual-check: branch match)
ok 9 compute_protected protects the current worktree path and always the main worktree
ok 10 check_main_freshness emits WARN on main/origin divergence and returns 0
ok 11 check_main_freshness emits nothing when main matches origin/main
ok 12 parse_worktree_list returns non-zero and emits no records on a git worktree-list hard failure
not ok 13 compute_protected emits protected-branch main when the primary worktree is on another branch
# (in test file tests/shell/test_cleanup_worktrees_enumeration.bats, line 121)
#   `[[ "$output" == *"protected-branch|main"* ]]' failed
not ok 14 compute_protected emits protected-branch main under current_exclusion
# (in test file tests/shell/test_cleanup_worktrees_enumeration.bats, line 132)
#   `[[ "$output" == *"protected-branch|main"* ]]' failed
ok 15 compute_protected emits exactly one protected-branch main when the current branch is main
ok 16 merged_no_worktree: MERGED_CLEAN and no worktree record for the branch
ok 17 merged_with_worktree: MERGED_CLEAN plus its WORKTREE record
ok 18 unmerged: NOT_MERGED (excluded from destructive action)
ok 19 ancestry_error: run fails with ANCESTRY_ERROR, not classified as unmerged
ok 20 content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit
ok 21 residual_on_main: MERGED_EQUIVALENT with no cherry-pick candidates
ok 22 residual_unique_doc: HAS_UNIQUE_RESIDUALS with a UNIQUE COMMIT record
ok 23 current_exclusion: PROTECTED_CURRENT and never delete-eligible
ok 24 worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict
ok 25 worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines
ok 26 cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure
ok 27 rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record
ok 28 child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict
ok 29 child_of_merged_equivalent: no CHILD_OF is emitted when the ancestor is not NOT_MERGED
ok 30 child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR
ok 31 child_of_not_merged: the driver's BRANCH line equals the ladder's own for the same branch
ok 32 child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported
ok 33 child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported
ok 34 child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported
not ok 35 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch
# (in test file tests/shell/test_cleanup_worktrees_classification.bats, line 265)
#   `[ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]' failed
not ok 36 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree
# (in test file tests/shell/test_cleanup_worktrees_classification.bats, line 272)
#   `[ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]' failed
ok 37 a dirty worktree blocks removal, reports DIRTY lines, and never forces
ok 38 a candidate whose re-verification flips is blocked before any branch delete
ok 39 worktree removal is invoked strictly before branch deletion
ok 40 a merged branch with no worktree gets only a branch delete
ok 41 non-eligible states produce no destructive argv
ok 42 consolidated-content branch deletion is gated on the merge check
ok 43 a zero-commit consolidation branch is never deleted
ok 44 verify_consolidation_merged returns NOT_ANCESTOR on tip equality
ok 45 verify_consolidation_merged fails closed on an empty rev-parse
ok 46 apply mode emits no deletion for a NOT_MERGED branch carrying a CHILD_OF record
ok 47 apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch
not ok 48 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch
# (in test file tests/shell/test_cleanup_worktrees_deletion.bats, line 159)
#   `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]' failed
not ok 49 run_apply does not delete main when the primary worktree is on another branch
# (in test file tests/shell/test_cleanup_worktrees_deletion.bats, line 165)
#   `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]' failed
not ok 50 run_apply neither removes nor deletes main checked out in a linked worktree
# (in test file tests/shell/test_cleanup_worktrees_deletion.bats, line 176)
#   `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]' failed
not ok 51 delete_candidate refuses the base branch before re-verification
# (in test file tests/shell/test_cleanup_worktrees_deletion.bats, line 186)
#   `[ "$status" -eq 1 ]' failed
not ok 52 delete_candidate refuses the base branch before removing its linked worktree
# (in test file tests/shell/test_cleanup_worktrees_deletion.bats, line 196)
#   `[ "$status" -eq 1 ]' failed
```

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 1

Output Summary:
- TAP `1..52`; 43 `ok`, 9 `not ok`.
- `not ok` set is exactly T1, T2, T4, T5, T6, T7, T8, T9, T10; T3 `ok`; all 42 pre-existing tests `ok`.
- Each failure's first failed line is a `main` assertion (see table); no fixture or syntax failure.
- Result: PASS for this [expect-fail] task (observed exit 1 equals the expected exit 1).
