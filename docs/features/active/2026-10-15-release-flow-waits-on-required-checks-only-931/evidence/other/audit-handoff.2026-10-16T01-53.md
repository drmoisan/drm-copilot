# Reduced-Audit Handoff Manifest (Issue #931)

Timestamp: 2026-10-16T01-53

Feature folder: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (`<FEATURE>`)
Plan: `<FEATURE>/plan.2026-10-15T15-45.md`
AC source: `<FEATURE>/issue.md` `## Acceptance Criteria` (minor-audit)

## Greatest-stamp artifacts

### baseline/

| Artifact name | Task | File |
|---|---|---|
| phase0-instructions-read | P0-T9 | `baseline/phase0-instructions-read.2026-10-16T00-08.md` |
| minor-audit-gate | P0-T10 | `baseline/minor-audit-gate.2026-10-16T00-11.md` |
| git-base | P0-T11 | `baseline/git-base.2026-10-16T00-12.md` |
| line-counts | P0-T12 | `baseline/line-counts.2026-10-16T00-12.md` |
| py-black-check | P0-T13 | `baseline/py-black-check.2026-10-16T00-14.md` |
| py-ruff | P0-T14 | `baseline/py-ruff.2026-10-16T00-15.md` |
| py-pyright | P0-T15 | `baseline/py-pyright.2026-10-16T00-15.md` |
| py-pytest-contract | P0-T16 | `baseline/py-pytest-contract.2026-10-16T00-15.md` |
| ps-format | P0-T17 | `baseline/ps-format.2026-10-16T00-16.md` |
| ps-analyze | P0-T18 | `baseline/ps-analyze.2026-10-16T00-20.md` |
| ps-test | P0-T19 | `baseline/ps-test.2026-10-16T01-26.md` |
| ci-main-run | P0-T20 | `baseline/ci-main-run.2026-10-16T01-23.md` |
| ps-coverage-main | P0-T21 | `baseline/ps-coverage-main.2026-10-16T01-23.md` |
| ps-coverage-content-match | P0-T22 | `baseline/ps-coverage-content-match.2026-10-16T01-23.md` |
| new-test-absence | P0-T23 | `baseline/new-test-absence.2026-10-16T01-23.md` |

### regression-testing/

| Artifact name | Task | File |
|---|---|---|
| release-flow-pin-fail-before | P1-T3 | `regression-testing/release-flow-pin-fail-before.2026-10-16T01-29.md` |
| release-flow-script-static | P1-T11 | `regression-testing/release-flow-script-static.2026-10-16T01-34.md` |
| release-flow-script-size | P1-T12 | `regression-testing/release-flow-script-size.2026-10-16T01-34.md` |
| checkswait-size | P1-T20 | `regression-testing/checkswait-size.2026-10-16T01-36.md` |
| checkclassification-size | P1-T23 | `regression-testing/checkclassification-size.2026-10-16T01-37.md` |
| pester-after-edit | P1-T24 | `regression-testing/pester-after-edit.2026-10-16T01-42.md` |
| release-flow-pin-pass-after | P1-T25 | `regression-testing/release-flow-pin-pass-after.2026-10-16T01-42.md` |
| fail-before-exception | P1-T26 | `regression-testing/fail-before-exception.2026-10-16T01-42.md` |

### qa-gates/

| Artifact name | Task | File |
|---|---|---|
| py-black-check | P2-T1 | `qa-gates/py-black-check.2026-10-16T01-44.md` |
| py-ruff | P2-T2 | `qa-gates/py-ruff.2026-10-16T01-44.md` |
| py-pyright | P2-T3 | `qa-gates/py-pyright.2026-10-16T01-44.md` |
| py-pytest-contract | P2-T4 | `qa-gates/py-pytest-contract.2026-10-16T01-44.md` |
| ps-format | P2-T5 | `qa-gates/ps-format.2026-10-16T01-45.md` |
| ps-analyze | P2-T6 | `qa-gates/ps-analyze.2026-10-16T01-48.md` |
| ps-test | P2-T7 | `qa-gates/ps-test.2026-10-16T01-50.md` |
| qc-loop-pass | P2-T8 | `qa-gates/qc-loop-pass.2026-10-16T01-51.md` |
| line-counts-final | P2-T9 | `qa-gates/line-counts-final.2026-10-16T01-51.md` |
| scope | P2-T10 | `qa-gates/scope.2026-10-16T01-51.md` |
| reference-search | P2-T11 | `qa-gates/reference-search.2026-10-16T01-51.md` |
| ac-verification | P2-T12 | `qa-gates/ac-verification.2026-10-16T01-51.md` |
| ac-status | P2-T18 | `qa-gates/ac-status.2026-10-16T01-52.md` |

### other/

- `other/phase0-commit.2026-10-16T01-27.md` (P0-T24)
- `other/phase1-handoff.2026-10-16T01-28.md` (P1-T1)
- `other/phase1-commit.2026-10-16T01-44.md` (P1-T27)
- `other/phase2-commit.<ts>.md` (P2-T20, written after this manifest)

P2-T13 to P2-T17 have no separate artifact. Their evidence is the `issue.md` checkbox state, which `qa-gates/ac-status` records.

## `## Writes` paths

- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`

## Pending-CI item

AC6: the PoshQC results of record and the line-coverage no-regression comparison for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` against the 94.26% baseline. The PR CI job is `poshqc / PowerShell QC`, and the S9 procedure is in `qa-gates/ac-verification.2026-10-16T01-51.md`.

## Execution deviations for the auditor

1. `git grep` has no `-x` option; P0-T10 used the equivalent anchored regex `^## Acceptance Criteria$`.
2. Full-suite `run_poshqc_test` calls exceed the client MCP idle timeout (1802 s and 1814 s); P0-T19, P1-T24, and P2-T7 used `scan_folders = ["tests/scripts/dev-tools"]`.
3. P1-T8's element check uses `[System.Management.Automation.PSCustomObject]`, because `[pscustomobject]` resolves to `PSObject` and accepted scalars; this was found by the new test `reports failure for a scalar element`.
4. P1-T12: the script was 505 lines after the edits; six blank lines in the new helpers were removed (final 499).
5. P1-T15: the `A check failed for PR #291` count reads `:3` rather than `:1`, because P1-T16 test (2) and P1-T17 test (7) assert the same message; line 110 is the only pre-existing line changed.
6. Timestamps were read with `date -u +%Y-%m-%dT%H-%M`, because no PowerShell tool was available in the executing session; the format is identical.
7. Commit trailers: the Phase 0 commit used the delegation-supplied trailer; later commits use the session-supplied trailer `Co-Authored-By: Claude Opus 5.5` with session `013PGF3obDYS7SqmfKekvaYp`.

## Unrelated findings from `## Notes` (for later filing only; no issue created)

- (a) `Invoke-GitExe` (script line 76) and `Invoke-GhExe` (line 93) declare `[OutputType([hashtable])]` but return the `[pscustomobject]` built by `ConvertTo-CommandResult`.
- (b) Phase A of `Wait-ForPullRequestChecks` treats an auth or network failure of `gh` the same as "checks not yet registered", delaying the failure report by the registration budget (24 attempts x 5 s).
