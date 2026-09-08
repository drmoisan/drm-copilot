# Final QC — `[P10-T6]`, the bash coverage stage

Timestamp: 2026-09-08T12-10
Task: `[P10-T6]`
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (the workflow's coverage step runs `bash scripts/bash/shell-qc.sh test --coverage` and uploads `artifacts/pester/kcov/cov.xml` as the `shell-coverage` artifact)
EXIT_CODE: PENDING-CI
Output Summary: PENDING-CI ROUND. Neither `bats` nor `kcov` is installed on this host, and the local
run returns 127 without producing a `cov.xml`. The final CI round is the gate. **`[P10-T6]` stays
unchecked and AC-40 stays unchecked until the orchestrator supplies that round's headline.**

## Why this stage cannot be discharged locally

    cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5
    bash scripts/bash/shell-qc.sh test --coverage

    bats not installed; cannot run shell tests with coverage.
    COV_EXIT=127

`run_bats_coverage` at `scripts/bash/shell_qc_lib.sh` lines 311-312 prints that marker and returns
non-zero when `resolve_tool bats` fails. No `artifacts/pester/kcov/cov.xml` was produced, so no
headline exists to record. The plan's `pwsh`-wrapped WSL form, which would reach both tools, is
refused in this agent-isolated worktree.

## Assertion to be discharged from the final CI run

- Exit code 0.
- The headline `Bash coverage (lines): NN.N%` is printed, and its numeric value is at least 85.0.
- `artifacts/pester/kcov/cov.xml` is produced and uploaded.
- The per-file `line-rate` for `scripts/bash/cleanup_worktrees_preserve_lib.sh` is at least 0.850.

## The round C figures this round supersedes, read from the uploaded artifact

The `shell-coverage` artifact of run 34219866134 was downloaded and parsed directly rather than
taken on report, so the numbers below are read from the file itself:

    <coverage line-rate="0.923" lines-covered="2225" lines-valid="2411" ...>

    filename="scripts/bash/cleanup-worktrees.sh"                       line-rate="1.000"
    filename="scripts/bash/cleanup_worktrees_preserve_eol_lib.sh"      line-rate="0.870"
    filename="scripts/bash/cleanup_worktrees_preserve_lib.sh"          line-rate="0.807"

For `scripts/bash/cleanup_worktrees_preserve_lib.sh` the per-line elements give
`measured=212 uncovered=41`, a rate of 0.8066, with the uncovered set:

    111 112 113 115 116 117 118 119 120 121 122 123
    164 203 219 278 279 280 281 347 348
    394 396 398 399 401 403 406 407 408 409
    445 471 472 473 474 475 476 477 483 484

That 0.807 is the finding the coverage-remediation pass addressed. The remediation is recorded in
`evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`; it adds eleven behavioral tests
that execute twenty-one of those forty-one lines, and it adds no coverage exclusion for any path.

Projected post-remediation rate for that file: 192 / 212 = **0.906**. Nineteen of the twenty lines
that remain uncovered are the interior lines of two multi-line literals and are not statements, and
the twentieth is an unreachable defensive branch, so 0.906 is the achievable ceiling for the file.
That projection is local and is not the gate; CI is canonical when local and CI disagree.

Verdict: PENDING-CI ROUND.
