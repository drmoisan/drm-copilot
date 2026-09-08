# Gate — AC-29, AC-30, AC-31 — missing source, ignored target, and the exit-code contract

Timestamp: 2026-09-08T10-30
Task: `[P4-T15]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f MISSING-SOURCE tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f ignored tests/shell/test_cleanup_worktrees_preserve.bats'"`
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f distinguish tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P4-T15]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `a missing source file is reported as MISSING-SOURCE`
2. `an ignored target path is refused without a force flag`
3. `the preserve exit codes distinguish clean, skipped, and blocked runs`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`, `1..1`, `1..1`` for the filter
``MISSING-SOURCE`, `ignored`, `distinguish``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

**MISSING-SOURCE.** Driven against the `missing-source/` fixture, whose worktree directory
exists while the file the manifest names does not:

    PRESERVE|<wt>|agent-memory/atomic-executor/never-written.md|GENUINELY_NEW
    ACTION|preserve-stage|null|MISSING-SOURCE
    rc=1

Skip and report, contributing to exit 1; never a hard stop. No `OK` record is emitted for that
record.

**IGNORED-TARGET.** The `ignored-target/` fixture carries `check-ignore.null.rc` containing `0`,
which is the answer meaning the path IS ignored:

    stub-git: -C /dev check-ignore -q -- null
    ACTION|preserve-stage|null|IGNORED-TARGET
    cleanup-worktrees: destination is ignored, refusing to force: null
    rc=1

No `add` invocation appears at all. The test asserts that absence with the extended regular
expression `stub-git: .*[[:space:]]add[[:space:]]`, which is the substitution the plan prescribes
for AC-30's literal. A search for the literal `stub-git: add` would match nothing whether or not
the add ran, because the stub logs its whole argv and the production call always passes
`-C <worktree>` first. The source-level half of the prohibition is discharged separately by
`evidence/qa-gates/gate-no-force-flag.2026-09-08T10-30.md`.

**The exit-code contract.** The three `exit-codes/` sub-scenarios were driven in the same run:

    exit-codes/clean     rc=0   one valid record staged, nothing skipped
    exit-codes/skipped   rc=1   one valid record staged, one skipped for an invalid verdict
    exit-codes/blocked   rc=0 at this phase; rc=3 once the host-token pre-pass lands in Phase 7

**The third case is deliberately not yet green, and this is why the gate is deferred rather than
recorded as failing.** The `blocked` sub-scenario carries a source file whose bytes hold a
fabricated Windows user-profile path. The refusal that turns that into exit 3 is
`preserve_scan_host_tokens`, which Phase 7 creates. Because every bats gate in Phases 3 through 7
is discharged from one CI round that the orchestrator dispatches after Phase 9, this gate is read
against a tree in which Phase 7 has already landed, and the assertion is satisfiable at the moment
it is actually evaluated. The local observation above is recorded as the pre-Phase-7 state so the
progression is auditable rather than silent.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
