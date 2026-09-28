# Gate — AC-38, the 500-line cap per file, re-measured after the coverage-remediation pass

Timestamp: 2026-09-08T12-10
Task: `[P9-T3]` (re-run)
Command: git diff --name-only epic/cleanup-merged-worktrees-hardening-integration
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 216 distinct entries in the combined changed-file set; **118 non-Markdown entries
measured**; **0 entries over the 500-line cap**; **0 entries present only on the ref and therefore
not measured**. The largest measured file is `scripts/bash/cleanup_worktrees_preserve_lib.sh` at
**492** lines, eight below the cap. Exit codes: `git status --porcelain` 0, `git diff --name-only` 0.

## Why this task was re-run

The gate of record was
`evidence/qa-gates/gate-ac38-line-caps.2026-09-08T11-55.md`, measured before the
coverage-remediation pass. That pass added one suite file and nine fixture files, so the earlier
per-file table no longer enumerates the tree it claims to describe. The Phase 10 preamble requires a
fresh measurement whenever the file list this gate walks has changed. This artifact supersedes the
11-55 one; that one remains valid for the tree it measured.

## Route substitution for the `git add -A` span, recorded rather than silently taken

The plan's first span is `git add -A`, present because an anchored name-listing diff enumerates
tracked changes only and would not otherwise see the files this work creates. **This execution is
prohibited by its delegation from running `git add`, `git commit`, or `git push`.** The substitute is
`git status --porcelain`, which is the companion the plan's own wrap-tolerant-authoring rules name as
the alternative to a staging span for exactly this purpose: it reports untracked paths, which is the
gap the `git add -A` closes. Untracked directory entries were expanded to their contained files with
`find`, because porcelain reports a wholly-untracked directory as one entry.

The two mechanisms are complementary and each alone is incomplete: the anchored diff is blind to
untracked files and porcelain is blind to already-committed changes. Both were run and their outputs
unioned.

## The three spans

    1. git status --porcelain                                                   -> exit 0, 32 entries
    2. git diff --name-only epic/cleanup-merged-worktrees-hardening-integration  -> exit 0, 189 entries
    3. wc -l on each non-Markdown entry of the union that exists in the working tree

Union after de-duplication and directory expansion: **216** entries.

## The measurement

Every non-Markdown entry that exists in the working tree was measured. Entries present only on the
ref would be recorded as `ref-only, not measured`; there are **none** in this measurement.

Top of the table, ordered by line count:

    492 scripts/bash/cleanup_worktrees_preserve_lib.sh
    471 tests/shell/test_cleanup_worktrees_preserve.bats
    275 tests/fixtures/cleanup_worktrees/stub-bin/git
    264 tests/shell/test_cleanup_worktrees_preserve_failures.bats
    212 scripts/bash/cleanup_worktrees_preserve_eol_lib.sh
    175 tests/shell/test_cleanup_worktrees_preserve_eol.bats
    163 scripts/bash/cleanup-worktrees.sh
     97 tests/fixtures/cleanup_worktrees/preserve/ht-patterns/manifest.json
     79 tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq
     37 tests/fixtures/cleanup_worktrees/preserve/order/manifest.json
     37 tests/fixtures/cleanup_worktrees/preserve/exit-codes/skipped/manifest.json
     22 tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/manifest.json

Every remaining measured entry is a fixture file of 22 lines or fewer.

The entries the coverage-remediation pass added, in full:

    264 tests/shell/test_cleanup_worktrees_preserve_failures.bats
     22 tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/manifest.json
      1 tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/jq.out
      1 tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/check-ignore.null.rc
      1 tests/fixtures/cleanup_worktrees/preserve/commit-failures/index-line-with-token.txt
      1 tests/fixtures/cleanup_worktrees/preserve/commit-failures/stage-fails/add.null.rc
      1 tests/fixtures/cleanup_worktrees/preserve/commit-failures/stage-fails/check-ignore.null.rc
      1 tests/fixtures/cleanup_worktrees/preserve/commit-failures/index-stage-fails/add._dev_null.rc
      1 tests/fixtures/cleanup_worktrees/preserve/commit-failures/index-stage-fails/check-ignore.null.rc

Two Markdown fixture files were also added and are exempt from the cap:
`tests/fixtures/cleanup_worktrees/preserve/commit-failures/wt/agent-memory/atomic-executor/commit-lesson.md`
and
`tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/wt/agent-memory/atomic-executor/upstream-flagged-lesson.md`.

## Verdict

Every measured non-Markdown entry reports 500 or fewer lines. No pre-authorized split was triggered
by this measurement: the two files nearest the cap are `cleanup_worktrees_preserve_lib.sh` at 492 and
`test_cleanup_worktrees_preserve.bats` at 471, and the eleven new tests were placed in a third suite
file rather than in either of them precisely so that neither would be pushed over. That placement
decision is recorded in `evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`.

Satisfies **AC-38**.
