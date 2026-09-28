# Final QC — `[P10-T5]`, the single clean pass required by AC-39

Timestamp: 2026-09-08T12-10
DischargedAt: 2026-09-08T12-03 (UTC; the third stage's result was supplied by the orchestrator after
this artifact was first written in its PENDING-CI form)
Task: `[P10-T5]`
Command: (derivation only; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: DISCHARGED. All three stages of the loop exited 0 within one uninterrupted iteration
against the same tree state: format `[P10-T2]` exit 0, check `[P10-T3]` exit 0, full bats suite
`[P10-T4]` exit 0 with plan line `1..386` and zero `not ok` lines. The format stage rewrote no file:
the `[P10-T1]` pre-format `shfmt -d` observation printed no diff hunk, and the two porcelain
listings `[P10-T2]` captured are byte-identical. AC-39 is satisfied.

## The three stages, all now observed on the same tree state

| Stage | Task | Result | Evidence |
| --- | --- | --- | --- |
| Format | `[P10-T2]` | EXIT_CODE 0, both porcelain captures byte-identical | `evidence/qa-gates/final-qc-format.2026-09-08T12-10.md` |
| Lint and format-diff | `[P10-T3]` | EXIT_CODE 0, zero bytes of output | `evidence/qa-gates/final-qc-check.2026-09-08T12-10.md` |
| Full bats suite | `[P10-T4]` | EXIT_CODE 0, plan line `1..386`, zero `not ok` | `evidence/qa-gates/final-qc-test.2026-09-08T12-10.md` |

The three stages ran in the plan's order — format, then check, then test — within one iteration. No
stage failed, no stage rewrote a file, and the loop was not restarted at any point. No stage is
recorded as `SKIPPED`.

## The no-rewrite claim and its evidence

The format stage rewrote no file. The primary evidence is the `[P10-T1]` pre-format `shfmt -d`
observation: that run printed **no diff hunk** across all twenty-four discovered scripts, which
establishes that the `shfmt -w` that followed it had nothing to rewrite. This is the discriminating
observation, because `shfmt -w` prints nothing and exits 0 on both a clean run and a repairing run,
so neither its stdout nor its exit code separates the two cases.

The corroborating tracked-file observation is the pair of porcelain listings `[P10-T2]` recorded.
Both are empty and therefore byte-identical, and both invocations exited 0:

    pre-format:  git status --porcelain -- scripts tools .claude/lib/bash   ->  (empty), exit 0
    post-format: git status --porcelain -- scripts tools .claude/lib/bash   ->  (empty), exit 0

Because every file within the format stage's reach was tracked and clean before the run, the
porcelain comparison discriminates here rather than passing vacuously: a rewrite of any of those
files would have produced a ` M` line in the second listing that the first does not carry.

## Same-tree-state check

The three stages describe one tree state rather than three. `[P10-T1]` through `[P10-T3]` were run
locally against the worktree at the state that was pushed as head SHA
`c58ac6e58dd4831530509806143f4e32212bfeb0`, and run 34223163823, which supplied the `[P10-T4]`
result, ran on that same head SHA. No file was written between the local stages and the push other
than the evidence artifacts themselves, which lie outside the `scripts tools .claude/lib/bash`
pathspec the format stage can reach and outside the bats suite's inputs.

## AC-39 conjunction, evaluated

AC-39 requires: a single pass of format, then check, then test, with every stage exiting 0 and no
file rewritten by the format stage, with the transcript recorded under `evidence/qa-gates/`.

- Single pass, in that order: yes, one uninterrupted iteration, no restart.
- Every stage exiting 0: format 0, check 0, test 0.
- No file rewritten by the format stage: established above by the pre-format `shfmt -d` no-diff
  observation, corroborated by the byte-identical porcelain pair.
- Transcript recorded under `evidence/qa-gates/`: the three artifacts named in the table above, plus
  `evidence/qa-gates/final-qc-preformat-tree.2026-09-08T12-10.md` for the pre-format observation.

Verdict: PASS. AC-39 is satisfied and is checked off in `spec.md`.
