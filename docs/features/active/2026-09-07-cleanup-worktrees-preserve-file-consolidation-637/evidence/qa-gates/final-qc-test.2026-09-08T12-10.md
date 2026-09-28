# Final QC — `[P10-T4]`, the full bats suite

Timestamp: 2026-09-08T12-10
DischargedAt: 2026-09-08T12-03 (UTC; the final CI round result was supplied by the orchestrator after
this artifact was first written in its PENDING-CI form)
Task: `[P10-T4]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: DISCHARGED. Run 34223163823 on head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0`
concluded `success`. The TAP plan line printed is `1..386`. 386 tests passed and the output carries
**zero `not ok` lines**, so the run reports zero failures. Every assertion this gate was waiting on
is satisfied.

## The discharging run

| Field | Value |
| --- | --- |
| Run ID | 34223163823 |
| URL | `https://github.com/drmoisan/drm-copilot/actions/runs/34223163823` |
| Head SHA | `c58ac6e58dd4831530509806143f4e32212bfeb0` |
| Conclusion | `success` |
| Exit code recorded for this stage | 0 |
| TAP plan line | `1..386` |
| Passing | 386 |
| `not ok` lines | 0 |

## Assertions discharged, each against the run above

- **Exit code 0.** The run concluded `success`; the test step ran to completion.
- **Zero failures.** The run output carries no `not ok` line. This is the discriminating
  observation, not the exit code: the plan's `## How targeted test gates are asserted` paragraph
  records that a bats invocation which selects nothing also exits 0, so a passing exit code alone is
  not sufficient. The absence of `not ok` together with the plan line below establishes that tests
  actually ran and all of them passed.
- **The TAP plan line is `1..386`.** This is the count predicted in the PENDING-CI form of this
  artifact: the preceding round, run 34219866134, printed `1..375`, and the coverage-remediation
  pass added exactly eleven tests in `tests/shell/test_cleanup_worktrees_preserve_failures.bats` and
  removed none. 375 + 11 = 386. The predicted and observed counts agree, which confirms that no test
  was silently dropped and none was silently added.
- **The eleven added tests are green.** They are inside the 386 passing tests and outside the zero
  `not ok` lines, so each of them passed.
- **No previously passing test regressed.** 375 tests passed in run 34219866134; 386 pass here, and
  none failed. A regression would have produced a `not ok` line.

## Why this stage could not be discharged locally

Recorded here for audit continuity rather than as an open item. `bats` is not installed on this
host: the local run of this stage prints `bats not installed; skipping shell tests.` and returns 0
without executing a single test, from `run_bats` at `scripts/bash/shell_qc_lib.sh` lines 239-241.
That exit code 0 is a false pass and was deliberately never recorded as the gate result. The plan's
`pwsh`-wrapped WSL form, which would reach a `bats` installation, is refused unconditionally in this
agent-isolated worktree by the harness-level isolation guard, and a bare `wsl` invocation is
prohibited. `shfmt` and `shellcheck` are on the Git Bash PATH and `bats` and `kcov` are not, which
is why `[P10-T1]`, `[P10-T2]`, and `[P10-T3]` were discharged locally and this task and `[P10-T6]`
were discharged from CI.

The local emulation recorded in the PENDING-CI form of this artifact — a minimal stand-in for
`setup`, `@test`, and `run` that executed all three suite files with 43 tests green — was evidence
for the prediction, not the gate. The gate is the CI bats run above, and it agrees with the
prediction.

Verdict: PASS. Exit code 0, plan line `1..386`, 386 passing, zero `not ok`.
