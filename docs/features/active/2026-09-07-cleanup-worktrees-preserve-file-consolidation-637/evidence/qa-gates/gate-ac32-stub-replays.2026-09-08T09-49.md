# Gate — AC-32, the git stub replays `add` and `check-ignore` scenario responses

Timestamp: 2026-09-08T09-49
Task: [P1-T9]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND

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
- This executor holds no `Bash(gh *)` grant. The orchestrator dispatches the run and supplies the
  values. **`[P1-T9]` stays unchecked in the plan until then.**

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

Verdict: PENDING-CI ROUND.
