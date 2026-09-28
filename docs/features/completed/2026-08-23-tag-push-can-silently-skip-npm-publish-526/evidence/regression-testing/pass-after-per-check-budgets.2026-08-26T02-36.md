# Pass-After Record — R1 Per-Check Budgets and R3 `RUN_INCOMPLETE`

Timestamp: 2026-08-26T04-10

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-10`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1,./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 -Output Detailed -CI'`

EXIT_CODE: 0

## Output Summary

This is the pass-after counterpart to
`evidence/regression-testing/fail-before-per-check-budgets.2026-08-26T02-36.md`. All six regression
tests introduced by tasks P2-T4, P3-T3, P3-T4, and P3-T5 now pass against the remediated
implementation.

Run totals for the two files: **39 passed, 0 failed, 0 skipped**, completed in 1.39 s, exit code 0.

### The six tests, named verbatim, with their observed result

| # | Task | Test title (verbatim) | Result |
|---|---|---|---|
| 1 | P2-T4 | `forwards the check (a) interval and attempt budget to Wait-ForWorkflowRun` | **passed** |
| 2 | P2-T4 | `forwards the check (b) interval and attempt budget to Test-PublishStepConclusion` | **passed** |
| 3 | P2-T4 | `polls the registry with the check (c) interval and attempt budget` | **passed** |
| 4 | P3-T3 | `check (b) returns RUN_INCOMPLETE when its attempt budget is exhausted` | **passed** |
| 5 | P3-T4 | `distinguishes an exhausted publish-step budget from a failed run conclusion` | **passed** |
| 6 | P3-T5 | `emits a RUN_INCOMPLETE instruction distinct from the RUN_FAILED instruction` | **passed** |

Test titles 1 through 5 live in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`;
title 6 lives in `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`.

### What each test now asserts about the remediated behaviour

**R1 — per-check polling budgets (tests 1 through 3).** `Invoke-TagPublishVerification` now declares
six per-check parameters instead of one shared `IntervalSeconds`/`MaxAttempts` pair, defaulted to the
spec section 3.4 ceilings: `RunIntervalSeconds` 10 and `RunMaxAttempts` 18 (3-minute ceiling),
`StepIntervalSeconds` 20 and `StepMaxAttempts` 60 (20-minute ceiling), `NpmIntervalSeconds` 15 and
`NpmMaxAttempts` 40 (10-minute ceiling).

- Test 1 mocks `Wait-ForWorkflowRun` under a `-ParameterFilter` binding both `IntervalSeconds -eq 10`
  and `MaxAttempts -eq 18`, and asserts `Should -Invoke -Times 1 -Exactly` against that same filter.
- Test 2 does the same for `Test-PublishStepConclusion` against `IntervalSeconds -eq 20` and
  `MaxAttempts -eq 60`.
- Test 3 arranges the npm seam never to resolve and asserts `Invoke-NpmExe` was invoked exactly 40
  times with `Invoke-Sleep` invoked exactly 39 times under a filter binding the sleep interval to 15.

Each invokes `Invoke-TagPublishVerification` supplying only `TagName`, `Version`, and `PackageName`,
so the defaults are what is under test. Before the remediation, one shared pair drove all three
checks, which ran check (b) at the 3-minute check (a) ceiling — the R1 defect.

**R3 — `RUN_INCOMPLETE` distinct from `RUN_FAILED` (tests 4 through 6).**

- Test 4 pins the exhaustion return of `Test-PublishStepConclusion` as the `RUN_INCOMPLETE` token,
  with its sleep-count assertion unchanged from the pre-rename version.
- Test 5 drives `Invoke-TagPublishVerification` twice — once with the run view never reporting status
  completed, once with the run conclusion set to failure — and asserts the two returned `State`
  values differ, that the first is `RUN_INCOMPLETE`, that the second is `RUN_FAILED`, and that both
  results carry a non-zero `ExitCode`.
- Test 6 asserts the `Get-RecoveryInstruction` entries for `RUN_INCOMPLETE` and `RUN_FAILED` are both
  non-empty and are different strings, so an operator receives a distinct recovery action.

`RUN_INCOMPLETE` is the seventh state token; the original six (`RESOLVED`, `NO_RUN`, `RUN_FAILED`,
`STEP_SKIPPED`, `STEP_MISSING`, `UNRESOLVED`) are unchanged and remain pairwise distinct.

### Acceptance criteria evidenced by this record

This artifact is the cited evidence for **AC29** (per-check budgets accepted, forwarded, and asserted
individually) and **AC30** (`RUN_INCOMPLETE` distinct from `RUN_FAILED`, with its own recovery
instruction and runbook section, both carrying a non-zero exit code). Both are checked off in
`spec.md` on the strength of the six passing tests above.
