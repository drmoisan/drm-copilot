# Final QC — `[P10-T7]`, the coverage comparison

Timestamp: 2026-09-08T12-10
DischargedAt: 2026-09-08T12-03 (UTC; the final CI round result and the orchestrator's per-file
regression analysis were supplied after this artifact was first written in its PENDING-CI form)
Task: `[P10-T7]`
Command: (derivation only; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: DISCHARGED. Baseline line coverage **93.5%** (run 34211209394, head SHA
`0edc15e030d9a79307e1399e9658e95b2cd6066d`); post-change line coverage **93.2%** (run 34223163823,
head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0`); signed delta **-0.3 points**. The post-change
value is at or above the 85.0 floor. The new library
`scripts/bash/cleanup_worktrees_preserve_lib.sh` has its own line rate of **0.906**, and the second
new module `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` is at **0.870**; both are at or above
the 85% obligation. A per-file join of the baseline and final `cov.xml` found **zero files
regressed**, so the -0.3 headline movement is denominator dilution rather than a regression on any
changed or pre-existing line.

## The three mandatory values, plus the signed delta

| Value | Source | Figure |
| --- | --- | --- |
| Baseline line coverage | `evidence/baseline/baseline-shell-qc-coverage.2026-09-08T09-49.md`, run 34211209394, head SHA `0edc15e030d9a79307e1399e9658e95b2cd6066d` | **93.5%** |
| Post-change line coverage | `evidence/qa-gates/final-qc-coverage.2026-09-08T12-10.md`, run 34223163823, head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0` | **93.2%** |
| New library's own line rate | final-round `cov.xml`, `scripts/bash/cleanup_worktrees_preserve_lib.sh` | **0.906** |
| Signed delta (post-change minus baseline) | derived | **-0.3 points** |

The baseline value is mandatory and no substitution was made for it: it is the headline
`Bash coverage (lines): 93.5%` recorded verbatim in the `[P0-T5]` artifact and captured on the
pre-change tree. The post-change value is the headline `Bash coverage (lines): 93.2%` recorded
verbatim in the `[P10-T6]` artifact. The signed delta is the arithmetic difference of the two.

**The post-change value is at or above 85.0.** 93.2 >= 85.0.

## Per-file rates for the modules this work created or modified

| Module | Baseline | Final | 85% obligation |
| --- | --- | --- | --- |
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` | n/a (created by this work) | **0.906** | met |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` | n/a (created by this work) | **0.870** | met |
| `scripts/bash/cleanup-worktrees.sh` | 1.000 | **1.000** | met |

The two new libraries did not exist in the baseline tree, so neither carries a baseline rate.
`cleanup-worktrees.sh` was present in the baseline tree at 1.000 and holds at 1.000 after the
preserve dispatch arm was added.

The principal library moved from **0.807** at round C (run 34219866134) to **0.906** here, the result
of the coverage-remediation pass recorded at
`evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`. 0.906 is the reachable ceiling
computed there: nineteen of the twenty lines that remain uncovered are the interior lines of two
multi-line literals, which kcov instruments but the shell never reports as executed, and the
twentieth is a defensive branch no input can reach. The projected value and the observed value agree
exactly.

**Verdict against the 85% obligation: met by every new or modified module.** No module this work
created or modified is below 0.850.

## The no-regression finding, and the method that produced it

**Zero files regressed.**

Method, performed by the orchestrator and cited here on that attribution: the per-file line rates
were read from the baseline `cov.xml` (run 34211209394) and from the final `cov.xml`
(run 34223163823), the two sets were joined on `filename`, and every file whose final rate is below
its baseline rate was reported. The report is empty. No file present in both runs has a lower rate
in the final run than in the baseline run.

That finding resolves the question this artifact left open in its PENDING-CI form, where the
projection put the final headline marginally below the baseline and the decision on whether that
constituted a regression was reserved for the orchestrator. The join answers it directly rather than
by inference from the headline: the headline is an aggregate over a changed denominator, and the
per-file join is the measurement of the property the plan's no-regression condition is about.

## Why the headline moved from 93.5 to 93.2 without any file regressing

The -0.3 movement is denominator dilution. The baseline was measured against a tree that did not
contain the two new production libraries. Admitting `cleanup_worktrees_preserve_lib.sh` at 0.906 and
`cleanup_worktrees_preserve_eol_lib.sh` at 0.870 into a repository whose prior average was 93.5%
lowers that average arithmetically, because both new modules sit below the prior mean even though
both clear the 85% obligation and neither displaced coverage from any existing file.

The two headline figures are therefore not two measurements of the same code: they are measurements
of two different denominators, and comparing them alone cannot distinguish dilution from regression.
The per-file join above makes that distinction, and it reports no regression on any changed or
pre-existing line. No coverage exclusion was added for any path, which `[P9-T4]` asserts separately
and records at `evidence/qa-gates/gate-ac41-no-coverage-exclusion.2026-09-08T11-55.md`; the new
modules are in the denominator and their cost to the headline is visible rather than suppressed.

Verdict: PASS. Baseline 93.5%, post-change 93.2%, delta -0.3 points, post-change at or above 85.0,
every new or modified module at or above the 85% obligation, and zero files regressed on the per-file
join.
