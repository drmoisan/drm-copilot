# No `PARALLEL_` Reason Prefix Introduced (P5-T8)

Timestamp: 2026-08-28T11-36

Task: [P5-T8]
Issue: #573
Acceptance criterion supported: AC-12 (first half)
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `git grep -F -n PARALLEL_ -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1`

EXIT_CODE: 1
ExpectedExitCode: 1

`git grep` exits 1 when it finds no match, so exit 1 is the passing outcome and is declared as the expectation.

## Result

**Zero matches.** The command produced no output line and exited 1.

The search is a fixed-string, case-sensitive search for the eight-character sequence `PARALLEL_`. It covers the whole file, including the rewritten `.DESCRIPTION`, both deny-reason construction sites, and the new predicate and read seam.

## Why the file contains none

Two gates emitting the same reason prefix would make transcript attribution ambiguous, and two gates emitting a prefix that names the other gate's surface would be worse. The sibling gate `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` owns its own prefix; this gate keeps `EPIC_WORKTREE_REMOVAL_BLOCKED` for **both** of its branches, exactly as `.claude/hooks/enforce-epic-merge-gate.ps1` emits `EPIC_MERGE_GATE_BLOCKED` for its own parallel branch.

The rewritten `.DESCRIPTION` refers to the sibling gate by **file name** rather than by its reason prefix, specifically so that this search stays at zero matches. The lowercase substring `parallel` appears in the file many times — in the path constant, the seam name, the predicate name, the `route_id` comparison, and the docstring — but none of those is the uppercase-plus-underscore sequence this search targets.

Output Summary: PASS (AC-12, first half). `git grep -F -n PARALLEL_` against `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` reports zero matches and exits 1, matching `ExpectedExitCode: 1`. No `PARALLEL_` reason prefix was introduced anywhere in the file, including in the rewritten `.DESCRIPTION`, which refers to the sibling gate by file name rather than by its reason prefix in order to preserve this property.
