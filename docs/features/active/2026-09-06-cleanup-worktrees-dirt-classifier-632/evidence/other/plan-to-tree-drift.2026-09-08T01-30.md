# Plan-to-tree drift, and one defect found and closed inside this work

Timestamp: 2026-09-08T01-30
Command: `grep -n` and `wc -l` against the tracked tree at `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
EXIT_CODE: 0

Purpose: this plan was authored before issue 631 landed on the epic branch. Several of its
locators and counts describe the tree as it stood at authoring time and no longer match. A
reviewer comparing plan text against the tree will see those differences and must be able
to tell drift from deviation. Each item below is a locator or count correction with the
measured current value; none of them changes the plan's design, its acceptance conditions,
or its scope. All six were reviewed and accepted by the orchestrator before Phase 4.

## 1. The dirt library's variable name in the bats suites is `DIRTLIB`, not `DLIB`

The plan says the new library is bound to a `DLIB` variable in each suite's `setup`. That
name is already taken: `DLIB` denotes `scripts/bash/cleanup_worktrees_detached_lib.sh` in
eight suites (`test_cleanup_worktrees_classification.bats:13`, `deletion.bats:16`,
`detached.bats:23`, `hard_failures.bats:18`, `report_records.bats:15`, and the three new
dirt suites). Reusing it would silently rebind the detached library and break the suites
that source it.

Resolution: the new library is bound to `DIRTLIB` in every suite. `DLIB` keeps its existing
meaning. This applies to P5-T1 as well, whose `setup` edit must define `DIRTLIB`.

## 2. The CLI suite carries seven pre-existing tests and eleven total, not five and nine

The plan cites five pre-existing declarations at
`tests/shell/test_cleanup_worktrees_cli.bats:16`, `:22`, `:28`, `:41`, and `:53`, and a
post-addition total of nine.

Measured: seven pre-existing declarations at `:18`, `:24`, `:30`, `:47`, `:60`, `:72`, and
`:83`; eleven total after P3-T6's four additions. The two extra tests
(`--help documents the detached worktree record` and
`--help documents the apply-mode exit-code change for blocked detached removals`) were
added by issue 631.

Resolution: the constraint the plan enforces is unchanged and is applied to all seven —
no pre-existing test is edited, and the anchored diff shows added lines only. Measured
`git diff --numstat 4ffe680e..aa0d619d -- tests/shell/test_cleanup_worktrees_cli.bats` is
`58 0`, and the count of deleted lines is 0. P5-T11's pass-after count is therefore eleven
rather than nine.

## 3. The wrapper has five existing `source` statements becoming six, not three becoming four

The plan's P5-T6 says `scripts/bash/cleanup-worktrees.sh` contains three
`source "$SCRIPT_DIR/` statements and that the new block makes four.

Measured: five, at `:18`, `:23`, `:26`, `:29`, and `:32`, naming
`cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_report_records_lib.sh`,
`cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, and
`cleanup_worktrees_detached_lib.sh`. The report-records and detached libraries were added
by issues 631 and 630.

Resolution: P5-T6 appends a sixth block after the detached-lib block rather than a fourth
after the actions-lib block, and its acceptance count is six.

## 4. The P2-T16 and P2-T17 capture commands need the two additional libraries and the scan seam

The plan's capture commands source three libraries and set only `CLEANUP_WT_GIT_BIN`.
`run_report` now calls `run_report_scans` (defined in
`scripts/bash/cleanup_worktrees_report_records_lib.sh`) and `report_detached_worktrees`
(defined in `scripts/bash/cleanup_worktrees_detached_lib.sh`), and `run_report_scans`
reaches the filesystem through the `CLEANUP_WT_SCAN_BIN` seam.

Resolution: the executed capture commands additionally source
`cleanup_worktrees_report_records_lib.sh` and `cleanup_worktrees_detached_lib.sh` and set
`CLEANUP_WT_SCAN_BIN` to `tests/fixtures/cleanup_worktrees/stub-bin/scan`. Without the
scan seam the capture would read the real filesystem and the expected files would not be
reproducible. The same source list and seam are used by every test that drives
`run_report`, which is what makes the checked-in expected files and the live assertions
comparable.

## 5. Shifted line citations in the two production libraries

| Plan citation | Subject | Measured location |
|---|---|---|
| `cleanup_worktrees_lib.sh:64` | `classify_ancestry` redirects both streams of `merge-base --is-ancestor` | `:69` |
| `cleanup_worktrees_lib.sh:89` | `classify_content_neutral` redirects both streams of `diff --quiet` | `:94` |
| `cleanup_worktrees_lib.sh:131` | `classify_cherry_equivalent` captures stdout only | `:136` |
| `cleanup_worktrees_lib.sh:465-469` | the `run_report` worktree loop | `:476-482` |
| `cleanup_worktrees_lib.sh:45` | the `DIRTY|` report-line contract line | `:45` (unchanged) |
| `cleanup_worktrees_actions_lib.sh:206` | `verify_consolidation_merged` redirects both streams | `:226` |
| `cleanup_worktrees_actions_lib.sh:227-249` | `reverify_delete_eligible` | `:238-270` |
| `cleanup_worktrees_actions_lib.sh:252-279` | `remove_worktree_safe` | `:272-300` |
| `cleanup_worktrees_actions_lib.sh:263` | the `worktree remove` inside `remove_worktree_safe` | `:283` |
| `cleanup_worktrees_actions_lib.sh:270` | the unqualified `status --porcelain` read | `:290` |
| `cleanup_worktrees_actions_lib.sh:309` | the pre-removal `reverify_delete_eligible` call | `:329` |
| `cleanup_worktrees_actions_lib.sh:310-312` | the `delete_candidate` body P5-T5 replaces | `:329-333` |

Every observability fact the plan derives from these citations is unchanged: the ancestry
and content-neutral probes still redirect both streams and are still unobservable in the
stub argv log; the cherry probe still leaves stderr attached and is still the first
observable ladder rung; and `remove_worktree_safe` still issues `worktree remove` before it
reads status, so the second occurrence in the log remains the retry.

## 6. Suite count for P5-T1

The plan says nine suites: six existing plus three new. The tree carries ten existing
`tests/shell/test_cleanup_worktrees_*.bats` files. The four not named by the plan are
`detached.bats`, `report_records.bats`, `scan_helper.bats`, and `scan_seam.bats`.

Resolution: P5-T1 wires the nine suites the plan names, which are the nine that drive
`run_report`, `delete_candidate`, or the wrapper and therefore reach the new call sites.
Any additional suite that reaches a call site and fails without the source is wired as a
micro-action of the task that reveals it, and the P5-T1 acceptance grep is run over the
nine the plan names.

## Defect found and closed inside this work: stderr redirection in the classifier probes

Recorded here because a reviewer reading the finished library will see git probes whose
stderr is not redirected and may read that as an oversight rather than a deliberate choice.

An initial draft of the classifier wrote each probe as `... 2>/dev/null` or `... 2>&1`, by
analogy with the existing ladder's probes. That is wrong here and was removed. The test
seam is a stub git that writes its own `stub-git: <argv>` invocation log to stderr
(`tests/fixtures/cleanup_worktrees/stub-bin/git:74`). Redirecting stderr at the call site
discards that log line before it reaches the bats `run` capture, so the invocation becomes
invisible to every argv assertion.

Had the redirection stayed, the argv log for the classifier's own probes would have been
empty, and AC-09, AC-10, AC-11, AC-12 and AC-29 — every criterion whose evidence is an
assertion over that log — would have passed regardless of what the classifier actually did.
Those are exactly the rung-ordering and non-mutation criteria, so the redirection would have
disabled the evidence for the safety properties rather than for a cosmetic one.

The classifier therefore captures stdout only and leaves stderr attached, matching
`classify_cherry_equivalent` (`scripts/bash/cleanup_worktrees_lib.sh:136`) rather than
`classify_ancestry` (`:69`). Exit codes are still captured with `|| rc=$?` at the
function-body level, which is what the family's guarded-read invariant requires; only the
stream redirection differs.
