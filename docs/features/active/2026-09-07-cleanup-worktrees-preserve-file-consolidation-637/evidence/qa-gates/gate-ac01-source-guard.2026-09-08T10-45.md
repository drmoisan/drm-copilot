# Gate — AC-01, the source-time guard, re-run after the pre-authorized library split

Timestamp: 2026-09-08T10-45
Task: `[P3-T8]` (re-run, required by `[P5-T9]`)
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f defines tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T8]` (re-run, required by `[P5-T9]`) stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `preserve library defines functions only and runs no work at source time`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``defines``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

`[P5-T9]` requires this gate to be re-run and a fresh artifact written once the library
split is taken, because the split creates a second file that is subject to the same source-time
guard. The test now carries two cases and both were driven directly in Git Bash:

    CASE_ONE (enumerate, classification, actions, line-ending library)   rc=0  output_length=0
    CASE_TWO (the full chain, adding the preserve library)               rc=0  output_length=0

Both sourced clean and printed nothing.

`scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` carries no top-level statement other than
function definitions and comments. Every column-zero line that does not begin with `#` or
whitespace was listed:

    20:preserve_index_has_entry() {
    42:}
    44:preserve_render_index_append() {
    64:}

Two function openers and their matching closers, and nothing else. The earlier artifact
`evidence/qa-gates/gate-ac01-source-guard.2026-09-08T10-30.md` records the same listing for
`scripts/bash/cleanup_worktrees_preserve_lib.sh` and remains valid for that file; this artifact
supersedes it as the gate of record because the test it gates now asserts both libraries.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
