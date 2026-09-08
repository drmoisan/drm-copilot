# Final QC — `[P10-T7]`, the coverage comparison

Timestamp: 2026-09-08T12-10
Task: `[P10-T7]`
Command: (derivation only; no command executed)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND. Baseline line coverage **93.5%** (run 34211209394, from the
`[P0-T5]` artifact). The most recent measured post-change value is **92.3%** (run 34219866134),
a signed delta of **−1.2 points**, which is above the 85.0 floor but below the baseline. That
measurement predates the coverage-remediation pass and is therefore superseded; the post-change
value of record comes from the final CI round, which has not yet run. **`[P10-T7]` stays
unchecked.**

## The three values this task must record

| Value | Source | Status |
| --- | --- | --- |
| Baseline line coverage | `evidence/baseline/baseline-shell-qc-coverage.2026-09-08T09-49.md`, run 34211209394 | **93.5%** — final |
| Post-change line coverage | final CI round | **PENDING-CI** (92.3% at round C, superseded) |
| New library's own line rate | final CI round `cov.xml` | **PENDING-CI** (0.807 at round C, superseded) |
| Signed delta | derived | **PENDING-CI** (−1.2 at round C, superseded) |

The baseline value is mandatory and no substitution was made for it: it is the headline
`Bash coverage (lines): 93.5%` recorded verbatim in the `[P0-T5]` artifact.

## Round C, read from the uploaded artifact rather than taken on report

The `shell-coverage` artifact of run 34219866134 was downloaded and its `cov.xml` parsed directly:

    <coverage line-rate="0.923" lines-covered="2225" lines-valid="2411" ...>
    filename="scripts/bash/cleanup_worktrees_preserve_lib.sh"      line-rate="0.807"
    filename="scripts/bash/cleanup_worktrees_preserve_eol_lib.sh"  line-rate="0.870"
    filename="scripts/bash/cleanup-worktrees.sh"                   line-rate="1.000"

Overall 0.923 satisfies the 85.0 floor. The per-module obligation was not satisfied:
`scripts/bash/cleanup_worktrees_preserve_lib.sh` at 0.807 is below 0.850, and the overall figure
concealed that.

## Why the round C numbers are superseded rather than recorded as final

The coverage-remediation pass that followed round C added eleven behavioral tests in
`tests/shell/test_cleanup_worktrees_preserve_failures.bats` and two fixture groups, and removed
nothing. Twenty-one of the forty-one uncovered lines in the preserve library are now executed;
the derivation and per-test line attribution are recorded in
`evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`.

Projected values for the final round, stated as projections and not as the gate:

- `scripts/bash/cleanup_worktrees_preserve_lib.sh`: 192 / 212 = **0.906**, against 0.807 at round C.
- Overall: 2225 + 21 covered of 2411 valid = 2246 / 2411 = **0.9315**, against 0.9230 at round C,
  bringing the value to within 0.2 points of the 93.5% baseline. The arithmetic assumes the eleven
  new tests add no new production lines to the denominator, which holds because they add no
  production file: `lines-valid` is a property of the measured production tree and the remediation
  changed no production file.

## The no-regression question, stated plainly rather than resolved optimistically

The plan states that if the post-change value is below the baseline value the verdict is
remediation-required and this task stays unchecked until a further test-adding pass restores it. At
round C the post-change value was 1.2 points below baseline. The projection above puts the final
round within 0.2 points, still marginally below.

This task therefore stays unchecked, and the decision on whether a 0.2-point shortfall against a
93.5% baseline constitutes a regression requiring a further pass belongs to the orchestrator once the
final round supplies real numbers rather than projections. Two facts bear on it and are recorded
here so the decision is informed:

1. The baseline was measured against a tree that did not contain the three new production files. The
   comparison is therefore between two different denominators, not between two measurements of the
   same code. `lines-valid` at round C is 2411; the baseline run measured fewer valid lines, because
   `cleanup_worktrees_preserve_lib.sh` (212 lines), `cleanup_worktrees_preserve_eol_lib.sh`, and the
   preserve arm of `cleanup-worktrees.sh` did not exist in it.
2. The new library is at its achievable ceiling after remediation. Nineteen of its twenty remaining
   uncovered lines are the interior lines of two multi-line literals, which kcov instruments but the
   shell never reports, and the twentieth is a defensive branch that no input can reach. No further
   test-adding pass can raise that file, so a further pass could only raise coverage elsewhere in
   the tree, which is outside this work's scope.

Verdict: PENDING-CI ROUND.
