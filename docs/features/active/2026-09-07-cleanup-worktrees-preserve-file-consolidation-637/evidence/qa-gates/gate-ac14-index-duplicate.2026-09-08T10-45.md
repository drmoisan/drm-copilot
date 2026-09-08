# Gate — AC-14, a duplicate index entry is skipped and does not change the exit code

Timestamp: 2026-09-08T10-45
Task: `[P5-T8]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f duplicate tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P5-T8]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`:

1. `a duplicate index entry is skipped and does not change the exit code`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``duplicate``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

Driven against the `index-duplicate/` fixture, whose consolidation index already carries
`- [Duplicate lesson](duplicate-lesson.md)` while the manifest offers the same entry again:

    PRESERVE|<wt>|agent-memory/atomic-executor/duplicate-lesson.md|GENUINELY_NEW
    ACTION|preserve-index|<cwt>/agent-memory/atomic-executor/MEMORY.md|SKIPPED-DUPLICATE
    rc=0  PRESERVE_EXIT=0

The duplicate is detected on the markdown link target — the text between `](` and `)` — compared
against the basename of `target_path`, not on the whole line. That makes the check independent of
the description text, which the operator may have reworded; the fixture's two descriptions differ
deliberately, so a whole-line comparison would miss the duplicate and the append would be planned.

Two assertions, and both were observed. The append is skipped, and the exit accumulator stays at
**0**: a duplicate does not affect the exit code, which is what makes the pass idempotent. That
idempotence is load-bearing rather than cosmetic, because both the host-token hard stop and the
partial-failure path end in the operator re-running the pass.

The `PRESERVE|` record is still emitted and the plan-stream entry is still created, so the file is
still copied and staged. Only the index append is suppressed.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
