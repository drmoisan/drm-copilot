# Fail-before — untracked preserve record is not staged (AC-08)

Timestamp: 2026-09-08T09-49
Task: [P2-T3] [expect-fail]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
ExpectedExitCode: 1
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f untracked tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. `pwsh` is refused unconditionally in this worktree and `bats` is not on
  the Git Bash PATH. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and supplies the values. **`[P2-T3]` stays unchecked in the plan until then.**

## Assertion to be discharged from the CI run log

The test below must appear as a **`not ok N <test name>`** line. A failing result is the expected
and required outcome for this task. Test name, verbatim from its `@test` declaration in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

- `an untracked preserve record is staged and reported`

## Why the test fails, stated so the failure reason is auditable

The test sources `scripts/bash/cleanup_worktrees_preserve_lib.sh` and calls `run_preserve`. That
library does not exist in the tree at this point; its absence was confirmed directly:

    $ ls .../scripts/bash/cleanup_worktrees_preserve_lib.sh
    ls: cannot access '...': No such file or directory

The three sibling libraries the test also sources — `cleanup_worktrees_enumerate_lib.sh`,
`cleanup_worktrees_lib.sh`, and `cleanup_worktrees_actions_lib.sh` — all exist, so the `&&` chain
reaches the missing library and stops there with a non-zero status. The test's first assertion
`[ "$status" -eq 0 ]` therefore fails.

**The failure is the absent behavior, not a defect in the test.** The supporting material is
complete and was verified independently of the missing library:

- The fixture manifest `tests/fixtures/cleanup_worktrees/preserve/untracked/manifest.json` exists
  and carries `tool: cleanup-merged-worktrees`, `schema_version: 1`, and one `preserved_files[]`
  record with all ten required fields.
- The canned `jq` stub output `tests/fixtures/cleanup_worktrees/preserve/untracked/jq.out` carries
  one record of 14 tab-separated columns in the D3 column order. The `jq` stub replayed it
  correctly when driven directly, exiting 0.
- The source file
  `tests/fixtures/cleanup_worktrees/preserve/untracked/wt/agent-memory/atomic-executor/lesson.md`
  exists and carries no host token.
- `check-ignore.null.rc` contains `1`, and the git stub returned 1 for
  `check-ignore -q -- null` under that scenario, so the destination is reported as not ignored.
  The `add.null` key is deliberately absent, so the stub's `add` arm exits 0.
- The bats file passes a bash syntax check (each `@test` header rewritten to a function header,
  then `bash -n`, exit 0).
- `bash scripts/bash/shell-qc.sh check` exits 0 with no output after these edits.

The record's `memory_index_line` is JSON null, so the pass performs no index work and this test
needs nothing from the Phase 5 index implementation. The destination is `/dev/null`
(`CLEANUP_WT_CONSOLIDATION_PATH=/dev` with `target_path` of `null`), so no file is created anywhere.

Together with `[P2-T4]` and `[P2-T5]` this contributes to **AC-42**.

Verdict: PENDING-CI ROUND. The expected outcome is a recorded failure.
