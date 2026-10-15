# S9 handoff (issue 895)

Timestamp: 2026-10-12T18-08

The executor does not check AC-7, AC-8, or the end-state evidence item. These stay open until the orchestrator's S9 evidence exists. The orchestrator completes the following items from the PR's CI run.

## AC-7

- Append the kcov `cov.xml` hit counts for the three bare delimiter lines and for the neighbouring command lines, read from the `shell-coverage` artifact, into the "## CI kcov evidence" section of `evidence/other/kcov-subshell-attribution-limit-895.md`.
- Replace the pending marker in that section with `S9-EVIDENCE: RECORDED`.
- Check the AC-7 box in `issue.md`.

## AC-8

- Confirm that the two relevant steps of job `shell-coverage`, "Run shell-qc check (shfmt diff + shellcheck)" and "Run shell-qc test with coverage", are green against the PR head.
- Read the bats pass count and the `Bash coverage (lines): NN.N%` line from the single log of the second step.
- Record the results in the three `evidence/qa-gates/ci-*-895.md` artifacts (`ci-shell-check-895.md`, `ci-bats-895.md`, `ci-kcov-coverage-895.md`) and in the three `evidence/baseline/ci-baseline-*-895.md` artifacts (`ci-baseline-shell-check-895.md`, `ci-baseline-bats-895.md`, `ci-baseline-kcov-coverage-895.md`), replacing each pending marker.
- Byte-identity of the mirror is already recorded in `evidence/qa-gates/mirror-hash-895.md`.
- Check the AC-8 box in `issue.md`.

## End-state

- Complete the end-state evidence item in the Evidence Checklist of `issue.md`.
