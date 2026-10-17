# Acceptance Criteria Verification (Issue #931)

Timestamp: 2026-10-16T01-51
Command: (verification record; no single command)
EXIT_CODE: 0
Output Summary: AC1 and AC5 are verified. AC2, AC3, and AC4 are verified (local, status-only); the per-test confirmation from the PR CI pester-junit.xml is a supplementary S9 check. AC6 is pending-CI for the coverage no-regression clause. Baseline percent 94.26.

Source: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`, `## Acceptance Criteria` (AC1 to AC6).

| AC | Status | Evidence |
|---|---|---|
| AC1 | verified | `regression-testing/release-flow-script-static.2026-10-16T01-34.md` (P1-T11: no `--required`), `regression-testing/release-flow-pin-fail-before.2026-10-16T01-29.md`, `regression-testing/release-flow-pin-pass-after.2026-10-16T01-42.md` (P1-T25), `qa-gates/py-pytest-contract.2026-10-16T01-44.md` (P2-T4), `qa-gates/reference-search.2026-10-16T01-51.md` (P2-T11) |
| AC2 | verified (local, status-only) | Pester tests from P1-T16 to P1-T22 (`returns success when buckets are a mix of pass and skipping`, `returns success when every bucket is skipping`, `keeps polling and times out on an empty check set`, CheckClassification `reports pass ...` and `reports empty ...`), `regression-testing/pester-after-edit.2026-10-16T01-42.md` (P1-T24), `qa-gates/ps-test.2026-10-16T01-50.md` (P2-T7) |
| AC3 | verified (local, status-only) | `returns failure when a non-required check fails`, `returns failure when a check is cancelled`, existing `waits through pending checks then completes` and `returns failure on completion timeout`; CheckClassification `reports fail ...`; P1-T24 and P2-T7 artifacts |
| AC4 | verified (local, status-only) | `keeps polling and times out on an empty check set`, `returns failure on an unrecognized bucket`, `returns failure on a check with no bucket property`, `reports a failed check ahead of an unrecognized bucket`, `returns failure without throwing on unparsable check output`, `continues after a non-zero completion poll`, `continues after an unparsable completion poll`, `times out when completion polls keep failing`; CheckClassification unknown/empty and ConvertFrom-CheckPollOutput failure tests; P1-T24 and P2-T7 artifacts |
| AC5 | verified | `regression-testing/release-flow-script-static.2026-10-16T01-34.md` (no `required check` wording), `regression-testing/release-flow-pin-pass-after.2026-10-16T01-42.md`, `qa-gates/py-pytest-contract.2026-10-16T01-44.md`, `qa-gates/reference-search.2026-10-16T01-51.md` |
| AC6 | pending-CI | `baseline/ps-coverage-main.2026-10-16T01-23.md`, `qa-gates/ps-format.2026-10-16T01-45.md`, `qa-gates/ps-analyze.2026-10-16T01-48.md`, `qa-gates/ps-test.2026-10-16T01-50.md`. The PR CI coverage no-regression clause is pending. |

Supplementary per-test confirmation for AC2 to AC4: the PR CI `pester-junit.xml` (S9 step 5 below). A local scoped run recorded 0 failures across the four release-flow suites. That is not the result of record.

## AC6 baseline

Baseline percent (copied from `baseline/ps-coverage-main.2026-10-16T01-23.md`): 94.26 (115 covered of 122 valid lines, RUN_ID 38730332356, RUN_SHA adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99).

Supplementary local observation (not the comparison value of record): the scoped local run measured 153 covered of 160 valid lines (95.63%).

## S9 procedure for AC6

1. Take the PR `CI` run for the final head SHA and its job `poshqc / PowerShell QC` (`windows-latest`).
2. Download `poshqc-test-results` with `gh run download RUN_ID -n poshqc-test-results -D SCRATCH/931/pr-coverage`.
3. Derive covered, valid, and percent for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` exactly as in P0-T21: use the class-level `<counter type="LINE" missed=".." covered=".." />` of the `<class ... sourcefilename="Invoke-FullReleaseFlow.ps1">` element; valid = covered + missed.
4. Compare against the percent in the greatest `evidence/baseline/ps-coverage-main.*.md` (94.26). AC6's coverage clause passes when the PR percent is at least 94.26.
5. Confirm in `pester-junit.xml` that the 19 ChecksWait tests (6 existing plus 13 new) and the 17 CheckClassification tests passed with zero failures.
6. Check off AC6, commit and push to the PR branch, and re-run the S9 gate against the new head SHA.
