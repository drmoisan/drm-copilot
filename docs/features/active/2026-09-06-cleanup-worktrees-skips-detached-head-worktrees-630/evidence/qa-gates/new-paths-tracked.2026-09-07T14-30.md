# QA Gate — New Test and Fixture Paths Present (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P7-T8]

Command: `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees tests/shell scripts/bash` followed by `git ls-files <the ten named paths>`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

None for the invocation form. [P7-T8] names no `wsl -d Ubuntu -- bash -lc '...'` wrapper;
both commands run natively. The plan's stale worktree path `agent-a06652a3fd875c703` does
not appear in this task's commands; both ran in the real worktree
`agent-adf4f49cbc48904be`.

## Span 1 — Porcelain Status

Command: `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees tests/shell scripts/bash`

EXIT_CODE: 0

```
```

The listing is **empty**. Every path under those three pathspecs is committed, so nothing is
reported as untracked or as modified in the working tree.

## Span 2 — Tracked File Listing

Command:

```
git ls-files tests/shell/test_cleanup_worktrees_detached.bats tests/fixtures/cleanup_worktrees/scenarios/detached_merged tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty tests/fixtures/cleanup_worktrees/scenarios/detached_locked tests/fixtures/cleanup_worktrees/scenarios/detached_current tests/fixtures/cleanup_worktrees/scenarios/detached_prunable tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit scripts/bash/cleanup_worktrees_detached_lib.sh
```

EXIT_CODE: 0

The command reported **52 tracked paths**. The eight directory arguments expand to the files
they contain; the two file arguments report themselves.

```
scripts/bash/cleanup_worktrees_detached_lib.sh
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/for-each-ref.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/merge-base.documentationandmemories.rc
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.documentationandmemories.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.main.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.verify.refs_heads_documentationandmemories.out
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/rev-parse.verify.refs_heads_documentationandmemories.rc
tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/merge-base.det00006.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_current/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_current/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_current/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_current/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_locked/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_locked/merge-base.det00004.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_locked/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_locked/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_locked/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged/merge-base.det00001.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_merged/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/merge-base.det00003.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/status._repo-wt_det.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/worktree-remove.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/merge-base.det00007.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/cherry.det00002.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/diff-quiet.det00002.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/diff-tree.det00002.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/merge-base.det00002.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/rev-parse.det00002_src_app.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/rev-parse.main_src_app.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/worktree-list.out
tests/shell/test_cleanup_worktrees_detached.bats
```

## Which Span Covered Each of the Ten Named Paths

The task's own text states that a path already committed will not appear in the porcelain
listing, and that in that case `git ls-files` must name it instead. Every one of the ten
paths is in that state. The per-path counts below are derived by grouping the 52-entry
listing reproduced above by its leading directory; each entry falls under exactly one of the
ten named paths, so the grouping is unambiguous and a reader can reproduce it from the
listing without running a further command.

| # | Named path | Porcelain span | `git ls-files` span |
|---|---|---|---|
| 1 | `tests/shell/test_cleanup_worktrees_detached.bats` | not covered (committed) | covered, 1 file |
| 2 | `tests/fixtures/cleanup_worktrees/scenarios/detached_merged` | not covered (committed) | covered, 5 files |
| 3 | `tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged` | not covered (committed) | covered, 10 files |
| 4 | `tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty` | not covered (committed) | covered, 7 files |
| 5 | `tests/fixtures/cleanup_worktrees/scenarios/detached_locked` | not covered (committed) | covered, 5 files |
| 6 | `tests/fixtures/cleanup_worktrees/scenarios/detached_current` | not covered (committed) | covered, 4 files |
| 7 | `tests/fixtures/cleanup_worktrees/scenarios/detached_prunable` | not covered (committed) | covered, 5 files |
| 8 | `tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error` | not covered (committed) | covered, 5 files |
| 9 | `tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit` | not covered (committed) | covered, 9 files |
| 10 | `scripts/bash/cleanup_worktrees_detached_lib.sh` | not covered (committed) | covered, 1 file |

The eight fixture-directory counts sum to 50; adding the two single files gives **52**, which
matches the total the `git ls-files` span reported. Each per-directory count also matches the
file count its Phase 1 task specified: five for `detached_merged` ([P1-T1]), ten for
`detached_unmerged` ([P1-T2]), seven for `detached_merged_dirty` ([P1-T3]), five for
`detached_locked` ([P1-T4]), four for `detached_current` ([P1-T5]), five for
`detached_prunable` ([P1-T6]), five for `detached_ancestry_error` ([P1-T7]), and nine for
`consolidated_zero_commit` ([P1-T8]).

The two spans are complementary and each alone is wrong in one state: `git ls-files` sees
tracked paths only and would report nothing for a file created but not yet staged, while
porcelain status goes empty once the change is committed. Here the tree is in the committed
state, so the porcelain span is empty and the `git ls-files` span carries the whole
observation. A staging command was deliberately not used, per the task text.

Output Summary: The porcelain span produced an **empty listing** and **covered none** of the
ten named paths, because all of them are already committed. The `git ls-files` span
**covered all ten**, expanding the eight fixture directories to their contained files for a
total of **52 tracked entries**. Every one of the eight new fixture directories is
represented by at least one tracked file, and both
`tests/shell/test_cleanup_worktrees_detached.bats` and
`scripts/bash/cleanup_worktrees_detached_lib.sh` are named directly. This is the evidence for
AC19 and AC23.
