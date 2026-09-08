# Phase 5 — coverage delta against the Phase 0 baseline

Timestamp: 2026-09-08T10-00
Task: [P5-T9]
Performed by: orchestrator (EA-4 gate ownership).

Command: parse kcov-merged/cov.xml from artifact 10057356590 (run 34229386300, headSha 7d7a661f)
  and compare against evidence/remediation-baseline/shell-coverage.2026-09-08T07-30.md
  (run 34194469882, headSha ea1baef8)
EXIT_CODE: 0

## Headline figures

BaselineRepoLineCoverage: 93.68
PostChangeRepoLineCoverage: 93.69
BaselineDirtLibLineCoverage: 94.05
PostChangeDirtLibLineCoverage: 94.12

Both ends of each comparison were computed by the same method — counting `<line>` elements
with non-zero `hits` against the total per class — so the delta is like-for-like rather than a
rounded attribute compared against an exact count.

## Per-file table — the eight files matching `scripts/bash/cleanup[-_]worktrees*`

The same eight files named in the P0-T6 baseline.

| File | Baseline | Post-change | Fell below baseline |
|---|---:|---:|---|
| `scripts/bash/cleanup-worktrees.sh` | 97.44% (38/39) | 97.44% (38/39) | no |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 94.08% (159/169) | 94.08% (159/169) | no |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 100.00% (103/103) | 100.00% (103/103) | no |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 94.05% (158/168) | 94.12% (160/170) | no |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.13% (82/89) | 92.13% (82/89) | no |
| `scripts/bash/cleanup_worktrees_lib.sh` | 95.41% (187/196) | 95.41% (187/196) | no |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 89.01% (162/182) | 89.01% (162/182) | no |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 86.79% (46/53) | 86.79% (46/53) | no |

Eight rows, all eight files named. No file's post-change percentage is below its baseline
percentage. Seven of the eight are byte-identical to baseline, which is the expected result:
this cycle changed only the classifier library, and the marker pass appended trailing comments
that add no executable lines.

The glob is written `cleanup[-_]worktrees*` rather than `cleanup_worktrees*` so that
`cleanup-worktrees.sh`, which uses a hyphen, is included. It is production bash inside kcov's
`--include-pattern` and it is the file that arms `--clear-disposable`.

## Changed lines

The region P1-T6 added is the narrowing of rung 4's `CONTENT_ON_MAIN` inference in
`scripts/bash/cleanup_worktrees_dirt_lib.sh`: a `git rev-parse --verify --quiet main:<path>`
probe and its `((erc == 0))` gate, which together establish that `main` actually contains the
path before an entry is treated as disposable. Before the fix, `git diff --quiet main -- <path>`
exit 0 was read as "the content is on main", but exit 0 also means the pathspec matched
nothing, so an `AD` entry whose content exists only as a staged blob resolved
`CONTENT_ON_MAIN`, aggregated `ALL_DISPOSABLE`, and was cleared — after which `reset --hard`
dropped the index entry and the blob became unreachable.

Both added lines are covered: the classifier library's denominator moved 168 to 170 and its
covered count moved 158 to 160.

The fixture that executes the new guard in **both** directions is
**`dirt_tracked_staged_only_blob`**. Its `AD` entry exercises the guard's true direction — the
path is absent from `main`, so the entry stays `UNIQUE` and is not cleared — while its tracked
entry exercises the false direction, where `main` does contain the path and `CONTENT_ON_MAIN`
is still reached. Pinning both directions is what distinguishes a fix from a suppression: a
change that simply stopped emitting `CONTENT_ON_MAIN` would pass the first and fail the second.

The fail-before/pass-after evidence for that fixture is recorded in
`evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md` and
`evidence/regression-testing/pass-after-rung4-path-in-main.2026-09-08T08-00.md`. The AD test
moves from `not ok 8` to `ok 8` while the tracked test reports `ok 9` in **both** runs, which
establishes that the fixture drives the ladder rather than merely failing to load.

Output Summary: no coverage regression on any of the eight files. Repository-wide 93.68% to
93.69%; classifier library 94.05% to 94.12% with both newly added executable lines covered.
