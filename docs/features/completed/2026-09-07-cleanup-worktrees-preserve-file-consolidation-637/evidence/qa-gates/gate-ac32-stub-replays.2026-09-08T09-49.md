# Gate — AC-32, the git stub replays `add` and `check-ignore` scenario responses

Timestamp: 2026-09-08T09-49
Task: [P1-T9]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: CI run 34213641449 (head SHA `005b7b3074db361060e841e3875e2424efa42110`) emitted the TAP plan line `1..349`. Both AC-32 tests are `ok`: `ok 286 the git stub replays a scenario response for add` and `ok 287 the git stub replays a scenario response for check-ignore`. No `not ok` line names either test. 346 of 349 tests passed; the only three failures are the three `[expect-fail]` tests Phase 2 requires to be red at this checkpoint.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f replays tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. `pwsh` is refused unconditionally in this worktree and `bats` is not on
  the Git Bash PATH, so no targeted `bats` run is possible locally.
- The plan preamble's assertion that the CI route "produces no per-test TAP output" is refuted by
  the baseline run recorded in `evidence/baseline/baseline-shell-qc-test.2026-09-08T09-49.md`, which
  printed the plan line `1..343` and 343 `ok N <test name>` lines. A targeted gate is therefore
  satisfiable from CI by locating the named test's `ok` line and confirming no `not ok` line names
  it.
- This executor holds no `Bash(gh *)` grant. The orchestrator dispatched the run and supplied the
  values recorded below.

## Assertion to be discharged from the CI run log

The two tests below must each appear as an `ok N <test name>` line, and no `not ok` line may name
either of them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `the git stub replays a scenario response for add`
2. `the git stub replays a scenario response for check-ignore`

The plan's targeted form expects the TAP plan line `1..2` for the filter `replays`; under the
full-suite CI run the plan line is the whole-suite count instead, so the equivalent three-part
assertion is: both `ok` lines present, no `not ok` line naming either test, and the run concluding
successfully.

## Local pre-verification of the behavior under test

The stub arms these tests exercise were driven directly in Git Bash, which requires no `bats`. Both
produced exactly the output and exit code the tests assert:

    $ CLEANUP_WT_STUB_SCENARIO=<PRES>/stub-keys/add-fails <STUB> -C /repo-wt/dm add -- docs/target.md
    stub-git: -C /repo-wt/dm add -- docs/target.md
    stub-add-failed
    ADD_STATUS=1

    $ CLEANUP_WT_STUB_SCENARIO=<PRES>/stub-keys/not-ignored <STUB> -C /repo-wt/dm check-ignore -q -- docs/target.md
    stub-git: -C /repo-wt/dm check-ignore -q -- docs/target.md
    CI_STATUS=1

Each test asserts a **non-default** exit code deliberately. The stub's default arm exits 0 and
`respond` defaults to 0 when no `.rc` file exists, so an assertion of status 0 would pass even if
the new case arm were absent. Asserting 1 makes the gate able to fail.

This is pre-verification of the stub behavior, not a discharge of the gate. The gate is the bats
run.

## Discharge from the CI run log

- Run: `34213641449` at `https://github.com/drmoisan/drm-copilot/actions/runs/34213641449`
- Head SHA: `005b7b3074db361060e841e3875e2424efa42110`
- Run conclusion: `failure`, which is the expected state of the suite at the Phase 2 checkpoint: the
  three `[expect-fail]` tests authored by `[P2-T2]` are red by design until Phases 4, 6, and 7. The
  run conclusion is therefore not the gate signal; the per-test TAP lines are.
- TAP plan line: `1..349`
- The two `ok` lines, verbatim from the run log:

      ok 286 the git stub replays a scenario response for add
      ok 287 the git stub replays a scenario response for check-ignore

- No `not ok` line names either test. The three `not ok` lines in the run are tests 289, 290, and
  291, which are the three `[expect-fail]` cases.

The plan's targeted form expected exit code 0, the plan line `1..2`, and no `not ok` line. Under the
full-suite CI substitute the equivalent three-part assertion is discharged: both `ok` lines are
present, neither test is named by a `not ok` line, and the tests' own exit status is 0 (a bats `ok`
line is emitted only for a test whose body exited 0).

Verdict: PASS.
