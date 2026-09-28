# Final QC Stage 3 Coverage — CI-measured

Timestamp: 2026-09-07T16-30
Task: [P6-T4]

`kcov` has no local route in this worktree, so the post-change coverage figure is produced by
dispatching `.github/workflows/_shell-coverage.yml`. That workflow's test step runs
`bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest`, where bats and kcov are
installed. This is the same script, the same argument, and the same instrument that produced the
[P0-T7] baseline, so the two figures are directly comparable.

## Commit and push preconditions

The workflow dispatch resolves `--ref` against the remote, so an uncommitted worktree change is
invisible to it. Every change made by Phases 1 through 5 was therefore committed and pushed before
dispatch.

- Commit created for this cycle: `12cc5766775c4faf172023132b97a199415e9709`
- Commit subject: `test(630): cover the untested delete-eligible verdicts and fail-closed guards`
- Pushed to: `origin/bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`

Command: `git rev-parse HEAD`
EXIT_CODE: 0

```
12cc5766775c4faf172023132b97a199415e9709
```

Command: `git rev-parse origin/bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
EXIT_CODE: 0

```
12cc5766775c4faf172023132b97a199415e9709
```

The two shas are equal, so the dispatch proceeded. Both `git rev-parse` invocations resolved and
printed a sha, which is the exit-0 outcome for that command.

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
EXIT_CODE: 0

The run was then waited on to completion and its `shell-coverage` artifact was downloaded to a
scratch directory outside the repository. The numeric values recorded below were read from that
downloaded artifact and from the completed run's log.

## Run identity

- Run ID: `34142466852`
- Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34142466852>
- Run conclusion: `success`
- Head sha the run tested: `12cc5766775c4faf172023132b97a199415e9709`

## Head-sha discrimination against the baseline

The [P0-T7] baseline run tested head sha `65a56cb94352c2a19c381acf4008837fa84aee69`. The head sha
this run tested, `12cc5766775c4faf172023132b97a199415e9709`, **differs** from it. This run therefore
measured this cycle's changes rather than re-measuring the inherited tree. A run whose head sha
equalled the [P0-T7] head sha would have reported the baseline per-file rate of 0.806 regardless of
the work done and would have failed this task.

## Values read from the run

Aggregate headline printed by the run's coverage step:

```
Bash coverage (lines): 94.2%
```

TAP plan reported by the run:

```
1..321
```

Count of run output lines beginning `not ok`: 0.

Per-file line rate from the uploaded `shell-coverage/cov.xml`, entry with
`filename="scripts/bash/cleanup_worktrees_detached_lib.sh"`:

```
line-rate="1.000"
```

- Aggregate line coverage: **94.2%** (measured)
- Per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh`: **1.000** (measured)

No branch-coverage value is recorded. kcov does not measure branch coverage for bash; the
`branch-rate="1.0"` attribute carried by that `cov.xml` entry is a fixed placeholder and reporting a
number from it would be fabrication.

Output Summary: run `34142466852` concluded `success` against head sha
`12cc5766775c4faf172023132b97a199415e9709`, which differs from the [P0-T7] baseline head sha
`65a56cb94352c2a19c381acf4008837fa84aee69`. The run reports aggregate line coverage of **94.2%**, a
TAP plan count of **321**, and no line beginning `not ok`. The per-file line rate for
`scripts/bash/cleanup_worktrees_detached_lib.sh` read from the uploaded `cov.xml` is **1.000**. Both
numbers are measured values, not placeholders.
