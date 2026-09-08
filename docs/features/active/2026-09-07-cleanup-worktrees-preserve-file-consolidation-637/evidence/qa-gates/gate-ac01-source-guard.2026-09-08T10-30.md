# Gate — AC-01, the preserve library defines functions only and runs no work at source time

Timestamp: 2026-09-08T10-30
Task: `[P3-T8]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
Output Summary: DISCHARGED by CI round C, run 34219866134, conclusion success. TAP plan line `1..375`; 375 passing; the run carried zero `not ok` lines. Superseded as the gate of record by gate-ac01-source-guard.2026-09-08T10-45.md, which asserts both split libraries; discharged here for completeness.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bats -t -f defines tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute: the CI route. The plan's `pwsh`-wrapped WSL form is refused unconditionally in
  this worktree by the harness-level isolation guard, a bare `wsl` invocation is prohibited by
  binding amendment EA-1, and `bats` is not on the Git Bash PATH, so no targeted `bats` run is
  possible locally. This executor holds no `Bash(gh *)` grant, so the orchestrator dispatches the
  run and reads the TAP lines named below. **`[P3-T8]` stays unchecked in the plan until then.**
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

The property was exercised directly in Git Bash by sourcing the four-library chain in a
fresh subshell and observing both the exit status and the output:

    $ bash -c "source <ELIB> && source <LIB> && source <ALIB> && source <PLIB>"
    (no output)
    STATUS=0

`scripts/bash/cleanup_worktrees_preserve_lib.sh` carries no top-level statement other than
function definitions and comments. That was confirmed mechanically by listing every column-zero
line that does not begin with `#` or whitespace. The listing holds exactly two kinds of line:

- the five `<name>() {` openers and their matching `}` closers, and
- lines 113, 115, and 125, which are continuation lines of the single-quoted jq filter string
  assigned inside `preserve_read_manifest`. They sit at column zero because the filter is written
  as a multi-line literal for readability; they are inside a string inside a function body and are
  not statements at any level.

No assignment, no invocation, and no conditional exists outside a function. The pattern-set
identifier `cleanup-wt-host-tokens-v1` is deliberately held as a function-local value rather than
as a top-level constant, precisely so this property holds; the sibling
`cleanup_worktrees_actions_lib.sh` takes the other choice for its own branch constant, which is
why this is recorded rather than assumed. 

This is pre-verification of the behavior, not a discharge of the gate. The gate is the bats run.

Verdict: DISCHARGED. The named test(s) each carry an `ok` line in run 34219866134 and no `not ok` line names any of them.

## Discharge — CI round C

Timestamp: 2026-09-08T12-10
Task: `[P3-T8]`
Run: 34219866134
URL: https://github.com/drmoisan/drm-copilot/actions/runs/34219866134
Head SHA: 62c7332923cab355e2bcf7f64b658a1e1ca07511
Conclusion: success
EXIT_CODE: 0
TAP plan line: `1..375`
Passing: 375. Failing: 0. **The run carried zero `not ok` lines.**

The suite grew from the 343-test baseline to 375 and no pre-existing test regressed.
Verbatim TAP `ok` line for each test this gate names, read from the run log:

    ok 290 preserve library defines functions only and runs no work at source time

The three-part assertion the plan states is satisfied in its full-suite substitute
form: the run exited 0, the plan line `1..375` was printed, and no `not ok` line
appears anywhere in the run, so none names any of the 1 test(s) above.
