# Gate — AC-02, AC-03, AC-04 — the dispatch arm, the unchanged unknown-argument arm, and the manifest override

Timestamp: 2026-09-08T10-30
Task: `[P4-T13]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f dispatches tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f unknown tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f CLEANUP_WT_MANIFEST_PATH tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P4-T13]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `preserve subcommand dispatches to the preserve driver`
2. `an unknown subcommand still prints usage to stderr and returns 2`
3. `the manifest path is taken from CLEANUP_WT_MANIFEST_PATH`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`, `1..1`` for the filter
``dispatches`, `unknown`, `CLEANUP_WT_MANIFEST_PATH``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The wrapper now carries a `preserve | --preserve)` case arm that calls `run_preserve` and
captures its return code into `exit_code` exactly as the existing arms do. The arm takes no
operand; `main` still reads only `${1:-}` and still has no `shift` and no option loop.

The `*)` arm is byte-unchanged and still contains `usage >&2` and `return 2`. That was confirmed
by reading the arm directly after the edit.

The source-level half of AC-04 is already discharged by
`evidence/qa-gates/gate-ac04-usage-manifest-override.2026-09-08T10-30.md`, which records the
printed count `3` for the literal `CLEANUP_WT_MANIFEST_PATH` in the wrapper and exit code 0. The
count was `0` before `[P4-T8]` ran, so that assertion discriminates. AC-04's remaining half is the
named test, which is gated here.

The manifest-override test asserts both directions in one body, so it can fail either way: an
override naming a path that does not exist is echoed verbatim in the
`ACTION|preserve-manifest|<path>|MISSING` record, and an override naming a manifest that does
exist is the one actually read, evidenced by that manifest's own record appearing in the output.
The precondition path was driven locally and produced

    ACTION|preserve-stage||MISSING-WORKTREE

for a nonexistent worktree and the equivalent `|MISSING` record for a nonexistent manifest, in
both cases with no `stub-git:` line at all, which is the "stages nothing" half.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
