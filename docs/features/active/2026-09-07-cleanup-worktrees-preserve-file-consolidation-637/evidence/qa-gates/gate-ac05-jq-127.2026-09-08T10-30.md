# Gate — AC-05, an unresolvable jq returns 127 and stages nothing

Timestamp: 2026-09-08T10-30
Task: `[P3-T9]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. The test asserted both the 127 status and the presence of the `no jq binary resolved` diagnostic token on stderr.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f unresolvable tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T9]` stays unchecked in the plan until then.**
- The plan preamble's claim that the CI route "produces no per-test TAP output" is refuted by
  direct observation: run 34213641449 emitted the plan line `1..349` and a per-test `ok N <name>`
  line for every test. The plan's targeted assertions therefore remain satisfiable; they are
  satisfied one round later, against the full-suite plan line rather than the targeted `1..N`.

## Assertion to be discharged from the CI run log

Each test below must appear as an `ok N <test name>` line, and no `not ok` line may name any of
them. Test names, verbatim from their `@test` declarations in
`tests/shell/test_cleanup_worktrees_preserve.bats`:

1. `an unresolvable jq returns 127 and stages nothing`

The plan's targeted form expects exit code 0 and the TAP plan line ``1..1`` for the filter
``unresolvable``. Under the full-suite CI substitute the plan line is the whole-suite count instead, so
the equivalent three-part assertion is: every `ok` line above present, no `not ok` line naming any
of them, and the tests' own exit status 0 (bats emits an `ok` line only for a test whose body
exited 0).

## Local pre-verification of the behavior under test

The test drives `preserve_resolve_jq`, created by `[P3-T2]` in this phase, and asserts
**two** things: that the status is 127, and that stderr carries the single-line token
`no jq binary resolved`. The second assertion is load-bearing. Bash returns 127 for
`command not found`, so a failed source, a misspelled function name, or a not-yet-existing
function would each produce 127 and would pass a status-only assertion without the resolution
logic having run at all. A bash `command not found` 127 prints `command not found` rather than
this diagnostic, so the two sources of 127 are distinguishable and the assertion can fail.

Driven directly in Git Bash with `CLEANUP_WT_JQ_BIN` pointing at a non-executable path and `PATH`
pointing at the checked-in `tests/fixtures/cleanup_worktrees/preserve/no-jq` directory, which
contains no `jq`:

    rc=127
    cleanup-worktrees: no jq binary resolved (CLEANUP_WT_JQ_BIN=<PRES>/no-jq/jq)

The observed exit code is 127 and the diagnostic token is present. No git invocation was made, so
nothing was staged; the test asserts that as the absence of any `stub-git:` line.

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P3-T9]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 291 an unresolvable jq returns 127 and stages nothing

The three-part assertion the plan states is satisfied in its full-suite substitute
form: the run exited 0, the plan line `1..375` was printed, and no `not ok` line
appears anywhere in the run, so none names any of the 1 test(s) above.
