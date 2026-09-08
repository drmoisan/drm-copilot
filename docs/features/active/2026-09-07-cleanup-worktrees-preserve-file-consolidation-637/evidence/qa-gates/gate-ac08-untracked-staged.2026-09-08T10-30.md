# Gate — AC-08, an untracked preserve record is staged and reported

Timestamp: 2026-09-08T10-30
Task: `[P4-T12]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f untracked tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P4-T12]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `an untracked preserve record is staged and reported`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``untracked``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

This is the test `[P2-T3]` recorded failing against the pre-change tree. It is expected to
turn green in this phase. Driven directly in Git Bash against the `untracked` fixture with
`CLEANUP_WT_CONSOLIDATION_PATH=/dev`:

    PRESERVE|tests/fixtures/cleanup_worktrees/preserve/untracked/wt|agent-memory/atomic-executor/lesson.md|GENUINELY_NEW
    stub-git: -C /dev check-ignore -q -- null
    stub-git: -C /dev add -- null
    ACTION|preserve-stage|null|OK
    rc=0

All three assertions the test makes are satisfied by that output: the `PRESERVE|` record with the
verdict, the `ACTION|preserve-stage|null|OK` result record, and the `add -- null` staging argv.
The exit code is 0, which is the clean-run code: nothing was skipped, no index was created, and no
token matched.

The byte copy wrote to `/dev/null` and no file was created anywhere. `mkdir -p /dev` against the
existing directory and the redirection into the null device were both exercised in this run, so
the writing phase's filesystem lines are covered without a temporary file.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
