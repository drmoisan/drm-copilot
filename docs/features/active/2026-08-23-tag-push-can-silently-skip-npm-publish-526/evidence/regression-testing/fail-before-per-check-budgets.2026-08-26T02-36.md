# Fail-Before Record — Per-Check Polling Budgets (R1)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Invoke-Pester -Path <scratchpad>/prechange/FailBefore.Tests.ps1 -CI'`

EXIT_CODE: 2

ExpectedExitCode: 2

WhyFailingRunImpossible: Not applicable to two of the three tests, which were captured failing against
the pre-change module. It applies to the third, `forwards the check (a) interval and attempt budget to
Wait-ForWorkflowRun`, which cannot be made to fail before the change: check (a)'s specified budget of
10 seconds by 18 attempts is numerically identical to the single shared pair the pre-change code
forwarded to all three checks, so the pre-change code satisfies that assertion by coincidence. Check
(a) was never the defective check; the test pins the value so a future edit to the shared-to-per-check
wiring cannot silently move it.

## Method

A real failing run was captured rather than argued. The pre-change module was extracted from `HEAD`
with `git show HEAD:scripts/dev-tools/Invoke-ReleaseVerification.ps1` into a scratchpad directory
outside the repository tree (499 lines, the monolithic pre-split file), and the three regression tests
that P2-T4 adds were run verbatim against it from a scratchpad harness. The harness is not part of the
Pester suite, adds no file to `tests/`, creates no temporary file inside the repository, and mocks the
same `Invoke-GhExe`, `Invoke-NpmExe`, and `Invoke-Sleep` seams the shipped tests mock, so no real
`npm`, `gh`, or `git` process ran and no wall-clock wait was taken.

## Output Summary

Result against the pre-change module: **1 passed, 2 failed, 0 skipped**.

### 1. `forwards the check (a) interval and attempt budget to Wait-ForWorkflowRun`

- Pre-change result: PASSED.
- Budget the pre-change code supplied to check (a): `IntervalSeconds = 10`, `MaxAttempts = 18`, taken
  from the single shared `IntervalSeconds`/`MaxAttempts` pair of `Invoke-TagPublishVerification`.
- This equals the section 3.4 ceiling for check (a) (3 minutes), so the assertion could not fail
  before the change. See `WhyFailingRunImpossible:` above.

### 2. `forwards the check (b) interval and attempt budget to Test-PublishStepConclusion`

- Pre-change result: **FAILED**.
- Budget the pre-change code supplied to check (b): `IntervalSeconds = 10`, `MaxAttempts = 18` — the
  same shared pair, giving an effective ceiling of 3 minutes against a specified 20 minutes.
- Observed failure: the mock's `-ParameterFilter { $IntervalSeconds -eq 20 -and $MaxAttempts -eq 60 }`
  never matched, so the real `Test-PublishStepConclusion` ran instead of the mock and the composition
  returned `RESOLVED`. Verbatim assertion message:
  `Expected: 'STEP_SKIPPED' / But was: 'RESOLVED'`.

### 3. `polls the registry with the check (c) interval and attempt budget`

- Pre-change result: **FAILED**.
- Budget the pre-change code supplied to check (c): `MaxAttempts = 18` at `IntervalSeconds = 10` — the
  same shared pair, giving an effective ceiling of 3 minutes against a specified 10 minutes.
- Observed failure, verbatim:
  `Expected Invoke-NpmExe to be called 40 times exactly, but was called 18 times`.

## Why this matters

A budget expiry on check (b) or check (c) occurs after the tag has been pushed and possibly published.
The verifier aborts, and a re-run then trips the pre-push inverted registry check, finds the version
now resolving, and reports `VERSION_CONSUMED_ELSEWHERE` — forcing another version bump. That is the
irreversible version-number consumption this feature exists to prevent, reached through a false
negative. Measured real runs of 80 and 112 seconds against the 170-second effective budget left under
a 2x margin on both checks.

## Pass-after

Against the post-change module all three tests pass: the full
`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` file reports 28 passed, 0 failed. The
formal pass-after record is P6-T4, which is outside this execution scope.
