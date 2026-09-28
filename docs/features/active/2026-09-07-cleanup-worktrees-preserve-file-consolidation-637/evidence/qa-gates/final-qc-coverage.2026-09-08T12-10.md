# Final QC — `[P10-T6]`, the bash coverage stage

Timestamp: 2026-09-08T12-10
DischargedAt: 2026-09-08T12-03 (UTC; the final CI round result was supplied by the orchestrator after
this artifact was first written in its PENDING-CI form)
Task: `[P10-T6]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's coverage step runs `bash scripts/bash/shell-qc.sh test --coverage` and uploads `artifacts/pester/kcov/cov.xml` as the `shell-coverage` artifact)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: DISCHARGED. Run 34223163823 on head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0`
concluded `success`. The headline printed is **`Bash coverage (lines): 93.2%`**; the numeric value
is **93.2**, which is at or above the 85.0 floor. `artifacts/pester/kcov/cov.xml` was produced and
uploaded, and it carries per-file `line-rate` entries. AC-40 is satisfied.

## The discharging run

| Field | Value |
| --- | --- |
| Run ID | 34223163823 |
| URL | `https://github.com/drmoisan/drm-copilot/actions/runs/34223163823` |
| Head SHA | `c58ac6e58dd4831530509806143f4e32212bfeb0` |
| Conclusion | `success` |
| Exit code recorded for this stage | 0 |
| Headline | `Bash coverage (lines): 93.2%` |
| Numeric value | 93.2 |
| `artifacts/pester/kcov/cov.xml` | produced and uploaded |

No branch column is printed, which is expected and is not a gap: `kcov` measures line coverage only,
so no bash branch-coverage gate exists and none is asserted. `.claude/rules/quality-tiers.md` records
that exemption explicitly.

## Assertions discharged

- **Exit code 0.** The coverage step ran to completion; it runs only after a green test step, and
  the test step was green at `1..386` per `[P10-T4]`.
- **The headline is printed with a non-empty percent value.** Neither degraded outcome the plan
  defines occurred: `extract_cobertura_line_rate` read a `line-rate` attribute successfully, so
  `print_coverage_summary` at `scripts/bash/shell_qc_lib.sh` lines 277-291 formatted a real value
  rather than printing nothing.
- **The numeric value is at least 85.0.** 93.2 >= 85.0.
- **`artifacts/pester/kcov/cov.xml` is produced.** The headline could not have printed otherwise.

## Per-file `line-rate` entries — the sub-item `[P0-T5]` deferred to this task

The `[P0-T5]` baseline artifact deferred the per-file `cov.xml` observation to this task, because no
run available to that executor emitted a per-file entry in a form the executor could read. That
sub-item is discharged here. The `cov.xml` of run 34223163823 carries per-file entries whose
`filename` names an existing `scripts/bash/*.sh` file together with a `line-rate` attribute. The
three entries for the modules this feature created or modified:

| Module | Baseline | Final |
| --- | --- | --- |
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` | n/a (created by this work) | **0.906** |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` | n/a (created by this work) | **0.870** |
| `scripts/bash/cleanup-worktrees.sh` | 1.000 | **1.000** |

Every new or modified module is at or above the 85% line-coverage obligation. The two new files were
not present in the baseline tree, so they have no baseline rate; `cleanup-worktrees.sh` was present
and holds at 1.000.

`scripts/bash/cleanup_worktrees_preserve_lib.sh` moved from **0.807** at round C (run 34219866134) to
**0.906** here. That is the reachable ceiling computed in the coverage-remediation decision recorded
at `evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`: of the twenty lines that
remain uncovered, nineteen are the interior lines of two multi-line literals, which kcov instruments
but the shell never reports as executed, and the twentieth is a defensive branch no input can reach.
The projected 0.906 and the observed 0.906 agree exactly.

## Why this stage could not be discharged locally

Recorded for audit continuity rather than as an open item. Neither `bats` nor `kcov` is installed on
this host; the local run prints `bats not installed; cannot run shell tests with coverage.` and
returns 127 from `run_bats_coverage` at `scripts/bash/shell_qc_lib.sh` lines 311-312, producing no
`cov.xml` and therefore no headline. The plan's `pwsh`-wrapped WSL form, which would reach both
tools, is refused in this agent-isolated worktree. The plan's `## Toolchain invocation shape`
paragraph authorizes the CI route for the coverage stage of `[P0-T5]` and `[P10-T6]` specifically,
and the orchestrator authorized it. CI is canonical when local and CI disagree on a coverage value.

Verdict: PASS. Exit code 0, headline `Bash coverage (lines): 93.2%`, cov.xml produced, every new or
modified module at or above 0.850. AC-40 is satisfied.
