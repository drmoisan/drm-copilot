# New Fixture Paths Present

Timestamp: 2026-09-07T16-30
Task: [P6-T10]

Two complementary spans are run because each alone is blind in one state. `git status --porcelain
--untracked-files=all` sees uncommitted and untracked paths but goes empty once a change is
committed; `git ls-files` sees tracked paths only and reports nothing for a file created but not yet
staged. Together they cover both states.

## Span 1 — porcelain status

Command: `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees tests/shell scripts/bash .claude/skills extensions/drm-copilot/resources`
EXIT_CODE: 0

Output: empty.

The output is empty because [P6-T4] committed every change made by Phases 1 through 5 as commit
`12cc5766775c4faf172023132b97a199415e9709`. With no uncommitted or untracked path remaining inside
those five spans, porcelain status reports nothing. Span 1 therefore covers **none** of the eight
new fixture directories, and its emptiness is a consequence of the commit rather than an absence of
the directories.

## Span 2 — tracked file listing

Command: `git ls-files tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error`
EXIT_CODE: 0

63 tracked paths were printed:

```
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/cherry.det00014.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/cherry.det00015.out
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/diff-quiet.det00014.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/diff-quiet.det00015.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/diff-tree.det00015.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/merge-base.det00014.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/merge-base.det00015.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/diff-quiet.det00008.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/merge-base.det00008.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/diff-quiet.det00013.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/merge-base.det00013.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/cherry.det00009.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/diff-quiet.det00009.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/merge-base.det00009.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/cherry.det00011.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/diff-quiet.det00011.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/diff-tree.det00011.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/merge-base.det00011.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/rev-parse.det00011_src_shared.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/rev-parse.main_src_shared.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/rev-parse.abbrev-ref-HEAD.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/cherry.det00016.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/diff-quiet.det00016.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/diff-tree.det00016.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/ls-tree.main_docs_old.md.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/merge-base.det00016.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/worktree-list.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/cherry.det00010.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/diff-quiet.det00010.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/diff-tree.det00010.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/for-each-ref.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/merge-base.det00010.rc
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/rev-parse.abbrev-ref-HEAD.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/rev-parse.det00010_src_app.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/rev-parse.main_src_app.py.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/rev-parse.show-toplevel.out
tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/worktree-list.out
```

## Which span covered each directory

| Fixture directory | Covered by | Files named | File count expected by plan |
|---|---|---|---|
| `detached_content_neutral` | Span 2 | 6 | 6 ([P1-T1]) |
| `detached_equivalent` | Span 2 | 7 | 7 ([P1-T2]) |
| `detached_unique_residuals` | Span 2 | 10 | 10 ([P1-T3]) |
| `detached_equivalent_residual` | Span 2 | 10 | 10 ([P1-T4]) |
| `detached_protection_error` | Span 2 | 4 | 4 ([P3-T1]) |
| `detached_content_neutral_error` | Span 2 | 6 | 6 ([P3-T2]) |
| `detached_cherry_error` | Span 2 | 11 | 11 ([P3-T3]) |
| `detached_residual_error` | Span 2 | 9 | 9 ([P3-T4]) |

All eight directories are covered by Span 2 and none by Span 1. The reason is stated above: commit
`12cc5766775c4faf172023132b97a199415e9709` made every path tracked, which moves every path out of
the porcelain span and into the `git ls-files` span. 6 + 7 + 10 + 10 + 4 + 6 + 11 + 9 = 63, matching
the printed path count.

Output Summary: Span 1 printed nothing and exited 0; Span 2 printed 63 tracked paths and exited 0.
Taken together the two listings name at least one file inside each of the eight new fixture
directories, and each directory's per-directory file count matches the count its Phase 1 or Phase 3
task specified. All eight directories were covered by Span 2 and none by Span 1, because [P6-T4]
committed the Phase 1 through Phase 5 changes before this task ran.
