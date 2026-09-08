# Gate — AC-26, an absent or malformed host_token_scan refuses to stage the record

Timestamp: 2026-09-08T10-30
Task: `[P3-T11]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f malformed tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T11]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `an absent or malformed host_token_scan refuses to stage the record`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``malformed``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The test drives `preserve_validate_record`, created by `[P3-T4]` and extended by
`[P3-T5]`, once per sub-scenario of `tests/fixtures/cleanup_worktrees/preserve/scan-malformed/`.
All five sub-scenarios were driven directly in Git Bash and every one refused the record:

    absent                     rc=1  host_token_scan is null, expected an object
    not-an-object              rc=1  host_token_scan is string, expected an object
    missing-result             rc=1  host_token_scan.result is absent
    missing-pattern-set-id     rc=1  host_token_scan.pattern_set_id is absent
    result-out-of-vocabulary   rc=1  host_token_scan.result out of vocabulary: probably

Each printed `ACTION|preserve-stage|<target-path>|SKIPPED-INVALID` on stdout with the reason on
stderr. The test asserts a sub-scenario count of exactly 5 in addition to the per-case
assertions, because a glob that matched no directory would leave the loop body unexecuted and the
test would otherwise pass having checked nothing.

The gate is demonstrated able to fail by a positive control run in the same driver: the valid
`untracked` fixture record, whose `host_token_scan` is a complete object, returned rc=0 and
printed nothing.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: PENDING-CI ROUND.
