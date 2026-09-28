# AC-38 Check-off (P18-T7)

Timestamp: 2026-09-27T22-01

## Criterion

AC-38: CI is green on the pull request, including the windows-latest Pester job (`poshqc / PowerShell QC`).

## Basis

- P18-T6 artifact: `evidence/qa-gates/ci-status.2026-09-27T22-01.md`
- PR #748, head `74ae7b5eb95a3da422f8789bea5cc66668b15e79` (the branch rebased onto main `e34a88b4` at the operator's request, and force-pushed with a lease pinned to `2fbf8345`).
- `CI` workflow run `36367250815`: conclusion `success` on that head.
- `gh pr checks 748`: 19 pass, 0 fail, 0 pending, including `poshqc / PowerShell QC`.
- mergeStateStatus: `CLEAN`.

## History

The earlier head `f5d06476` failed `poshqc / PowerShell QC` with 35 Pester failures:
- 34 from `BlastRadiusScheduling.psm1` resolving `Test-BlastRadiusConflict` from session state, which is invisible when the facade is imported in test scope;
- 1 from the no-Python guard rejecting the `& $relation` dynamic invocation.

Commit `9aca1ec6` fixed both by passing the conflict relation explicitly. A fresh-process Pester run of `tests/scripts/claude-lib/blast-radius` after the rebase gave 560 passed, 0 failed, 1 skipped. The skip is the intentional #452 "Tolerance branch" placeholder.

## Result

AC-38 is checked in `spec.md`; the count is 38 of 38 checked, 0 open.
