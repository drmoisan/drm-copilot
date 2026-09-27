# P5-T1 — Pass-after run (three edited suites, fixed libraries)

Timestamp: 2026-09-27T01-40
Task: [P5-T1]
Working directory: repository worktree root
HEAD at run time: `7e54e0e1` (implementation committed at IMPL_SHA `fd4d2656709d53a8fd76f595552ff53bd37d3f0e`; working tree clean for the implementation scope)
Tool: bats-core 1.13.0 via `npx --yes bats`
Run window (UTC): 2026-09-27T01-38-53 to 2026-09-27T01-40-38

## T1-T10 `ok` lines (verbatim)

| Test | TAP line |
|---|---|
| T1 | `ok 13 compute_protected emits protected-branch main when the primary worktree is on another branch` |
| T2 | `ok 14 compute_protected emits protected-branch main under current_exclusion` |
| T3 | `ok 15 compute_protected emits exactly one protected-branch main when the current branch is main` |
| T4 | `ok 35 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch` |
| T5 | `ok 36 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree` |
| T6 | `ok 48 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` |
| T7 | `ok 49 run_apply does not delete main when the primary worktree is on another branch` |
| T8 | `ok 50 run_apply neither removes nor deletes main checked out in a linked worktree` |
| T9 | `ok 51 delete_candidate refuses the base branch before re-verification` |
| T10 | `ok 52 delete_candidate refuses the base branch before removing its linked worktree` |

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
ok 13 compute_protected emits protected-branch main when the primary worktree is on another branch
ok 14 compute_protected emits protected-branch main under current_exclusion
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
ok 35 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch
ok 36 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree
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
ok 48 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch
ok 49 run_apply does not delete main when the primary worktree is on another branch
ok 50 run_apply neither removes nor deletes main checked out in a linked worktree
ok 51 delete_candidate refuses the base branch before re-verification
ok 52 delete_candidate refuses the base branch before removing its linked worktree
```

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 0

Output Summary:
- TAP `1..52` (equals the P1-T20 plan).
- 52 `ok`, 0 `not ok`.
- T1 through T10 each report `ok` (listed by exact name above); the nine fail-before failures now pass and T3 still passes.
- Result: PASS.
