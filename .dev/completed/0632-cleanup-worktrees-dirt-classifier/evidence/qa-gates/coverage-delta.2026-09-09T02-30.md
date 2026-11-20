# Phase 5 — coverage delta against the cycle-3 Phase 0 baseline

Timestamp: 2026-09-09T02-30
Task: [P5-T10]
Performed by: orchestrator (EA-4 gate ownership).

Command: parse kcov-merged/cov.xml from artifact 10068076892 (run 34255859868, headSha 5ad0ef09)
  and compare against evidence/remediation-baseline/shell-coverage.2026-09-09T00-00.md
EXIT_CODE: 0

## Headline figures

BaselineRepoLineCoverage: 93.69
PostChangeRepoLineCoverage: 93.69
BaselineDirtLibLineCoverage: 94.12
PostChangeDirtLibLineCoverage: 94.22

Both ends were computed by the same method — counting `<line>` elements with non-zero `hits`
against the total per class — so the delta is like-for-like rather than a rounded attribute
compared against an exact count.

## Per-file table — the eight files matching `scripts/bash/cleanup[-_]worktrees*`

The same eight files named in the P0-T5 baseline.

| File | Baseline | Post-change | Fell below baseline |
|---|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 97.44% (38/39) | 97.44% (38/39) | no |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 94.08% (159/169) | 94.08% (159/169) | no |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 100.00% (103/103) | 100.00% (103/103) | no |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 94.12% (160/170) | 94.22% (163/173) | no |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.13% (82/89) | 92.13% (82/89) | no |
| `scripts/bash/cleanup_worktrees_lib.sh` | 95.41% (187/196) | 95.41% (187/196) | no |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 89.01% (162/182) | 89.01% (162/182) | no |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 86.79% (46/53) | 86.79% (46/53) | no |

Eight rows, all eight files named. No file's post-change percentage is below its baseline. Seven
of the eight are identical to baseline, which is the expected result: this cycle changed only the
classifier library, and the registry and suite edits touch test files that are not in the coverage
denominator.

The glob is written `cleanup[-_]worktrees*` rather than `cleanup_worktrees*` so that
`cleanup-worktrees.sh`, which uses a hyphen, is included.

## Changed lines

P2-T1 added three guard sites to `scripts/bash/cleanup_worktrees_dirt_lib.sh`:

1. The `bothloc` assignment, which sets the flag when both porcelain columns are content-bearing —
   that is, when content exists in the index AND in the working tree, so two distinct blobs exist.
2. The nested gate at rung 4's positive emission, which now declines to resolve `CONTENT_ON_MAIN`
   when `bothloc` is set, because rung 4 compares `main` against the working tree only.
3. The nested gate at rung 5's positive emission, which declines to resolve `CONTENT_IN_HISTORY`
   for the same reason, because rung 5 hashes the working-tree file only.

All three executable lines are covered: the classifier's denominator moved 170 to 173 and its
covered count moved 160 to 163.

The fixture that executes all three is **`dirt_index_and_worktree_delta`**. The four `@test` titles
from P1-T4 are the assertions that hold them:

- `dirt_index_and_worktree_delta: MM src/a.cs is UNIQUE` — the `MM` entry whose working-tree copy
  matches `main`, which resolved `CONTENT_ON_MAIN` before the fix
- `dirt_index_and_worktree_delta: MM src/b.cs is UNIQUE` — the rung-5 analogue, which resolved
  `CONTENT_IN_HISTORY` before the fix
- `dirt_index_and_worktree_delta: UU src/c.cs is UNIQUE` — the unmerged entry, which the reaudit's
  `M A R C` rule would not have closed and which the widened `[MARCTU]` class does
- `dirt_index_and_worktree_delta: M-space control still resolves its pre-fix verdict` — the
  negative direction, which is what distinguishes a fix from a suppression: a change that simply
  stopped emitting disposable verdicts would pass the first three and fail this one

The accounting gate added by P1-T5 named three unaccounted index locations before the fix and zero
after.

Output Summary: no coverage regression on any of the eight files. Repository-wide 93.69% to
93.69%; classifier library 94.12% to 94.22% with all three newly added executable lines covered.
