# Final QC — `[P10-T4]`, the full bats suite

Timestamp: 2026-09-08T12-10
Task: `[P10-T4]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's test step runs `bash scripts/bash/shell-qc.sh test`, which invokes bats with no formatter flag and therefore emits TAP)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND. `bats` is not installed on this host, so the local run of this
stage returns 0 without executing a single test and is not a discharge. The final CI round is the
gate. **`[P10-T4]` stays unchecked until the orchestrator supplies that round's result.**

## Why this stage cannot be discharged locally

The local run was executed and its output recorded, so the unavailability is observed rather than
asserted:

    cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5
    bash scripts/bash/shell-qc.sh test

    bats not installed; skipping shell tests.
    TEST_EXIT=0

`run_bats` at `scripts/bash/shell_qc_lib.sh` lines 239-241 prints exactly that marker and returns 0
when `resolve_tool bats` fails. **That exit code 0 is a false pass and is deliberately not recorded
as the gate result.** Recording it would satisfy the plan's acceptance condition without a single
test having run, which is the class of unfailable gate the plan's own acceptance-authoring rules
prohibit.

The plan's `pwsh`-wrapped WSL form, which would reach a `bats` installation, is refused
unconditionally in this agent-isolated worktree by the harness-level isolation guard, and a bare
`wsl` invocation is prohibited. `shfmt` and `shellcheck` are on the Git Bash PATH and `bats` and
`kcov` are not, which is why `[P10-T1]`, `[P10-T2]`, and `[P10-T3]` were discharged locally and this
task and `[P10-T6]` cannot be.

## Assertion to be discharged from the final CI run log

- Exit code 0.
- Zero failures: the run carries no `not ok` line.
- The TAP plan line is `1..386`. The preceding round, run 34219866134, printed `1..375`; the
  coverage-remediation pass added exactly eleven tests, all in the new suite file
  `tests/shell/test_cleanup_worktrees_preserve_failures.bats`, and removed none.
- The eleven added tests each carry an `ok` line, by name:
  1. `a dot dot segment in source_path or target_path skips the record and reports`
  2. `a record carrying fewer than fourteen columns is skipped and reports its count`
  3. `a memory_index_line that is neither a string nor null is skipped and reported`
  4. `an upstream tokens_present result blocks the pass without a local scan`
  5. `a rejected manifest is re-emitted by the driver and stops the pass`
  6. `a destination directory that cannot be created is reported as FAILED`
  7. `a failed verbatim byte copy is reported as FAILED`
  8. `a failed index append is reported as FAILED`
  9. `a failed staging call is reported as FAILED`
  10. `a failed index staging call is reported as FAILED`
  11. `a host token carried by the index line refuses the record`
- No test that passed in run 34219866134 regressed.

## Local pre-verification of the suite under test

`bats` is unavailable, so the three suite files were executed under a minimal local emulation of
`setup`, `@test`, and `run` — enough of the framework to run each test body with the same `run`
capture semantics and the same per-test `setup`. Every test passed:

    tests/shell/test_cleanup_worktrees_preserve.bats           1..26  failures=0
    tests/shell/test_cleanup_worktrees_preserve_eol.bats       1..6   failures=0
    tests/shell/test_cleanup_worktrees_preserve_failures.bats  1..11  failures=0

The emulation is not bats and this is not a discharge of the gate. It is evidence that the eleven
new tests are expected to be green and that the thirty-two tests this feature previously contributed
are unaffected by the additions. The gate is the CI bats run.

Verdict: PENDING-CI ROUND.
