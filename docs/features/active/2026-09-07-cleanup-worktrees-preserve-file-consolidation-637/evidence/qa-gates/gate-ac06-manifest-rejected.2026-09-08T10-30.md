# Gate — AC-06, a manifest with a wrong tool or schema_version is rejected and stages nothing

Timestamp: 2026-09-08T10-30
Task: `[P3-T10]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f schema_version tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T10]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `a manifest with a wrong tool or schema_version is rejected and stages nothing`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``schema_version``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The test drives `preserve_read_manifest`, created by `[P3-T3]` in this phase, once per
fixture group. Driven directly in Git Bash against both fixtures:

    bad-tool     rc=1
    ACTION|preserve-manifest|<PRES>/bad-tool/manifest.json|REJECTED
    cleanup-worktrees: manifest rejected (jq rc=5): <PRES>/bad-tool/manifest.json

    bad-schema   rc=1
    ACTION|preserve-manifest|<PRES>/bad-schema/manifest.json|REJECTED
    cleanup-worktrees: manifest rejected (jq rc=5): <PRES>/bad-schema/manifest.json

The production filter raises on a failed top-level check, which makes jq itself exit non-zero;
the `jq` stub reproduces that by replaying an empty stdout together with a `jq.rc` of `5` from
each scenario directory. A parse failure and a failed top-level check are therefore the same
observable outcome, which is what the specification requires.

Nothing was staged: the only stub invocation logged on either run is a `stub-jq:` line, and no
`stub-git:` line appears at all. The same driver confirmed the happy path still reads: the
`untracked` fixture returned rc=0 with a record of exactly 14 tab-separated columns, so the
rejection is a property of the two bad manifests and not of the reader.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
