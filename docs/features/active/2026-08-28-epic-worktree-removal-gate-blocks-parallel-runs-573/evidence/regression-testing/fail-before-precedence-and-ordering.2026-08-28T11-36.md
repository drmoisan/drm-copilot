# Fail-Before — Branch Precedence and Check Ordering (P1-T3)

Timestamp: 2026-08-28T11-36

Task: [P1-T3] `[expect-fail]`
Issue: #573
Acceptance criteria exercised: AC-5, AC-7
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## The two named `It` blocks added

Added in a new `Context 'branch precedence and check ordering (AC-5, AC-7)'`:

1. `allows when the epic checkpoint authorizes while the parallel checkpoint does not (branches are ORed)` — AC-7. The epic seam returns a `features[]` record matching the target path with `merge_status` `merged`; the parallel seam returns a `route_id == "parallel"` checkpoint whose matching `items[]` entry has `merge_status` `pr_open`. The expected decision is `allow`. Were the two branches ANDed, the parallel branch's refusal would force a deny, so a passing result proves the disjunction.

2. `emits the envelope-anomaly deny before reading either checkpoint` — AC-5. An empty payload is supplied while **both** seams are mocked, and each seam is asserted to have been invoked zero times via `Should -Invoke ... -Times 0 -Exactly`. A deny emitted after any checkpoint read would register a non-zero invocation count and fail the assertion, so a passing result proves the envelope-anomaly deny remains the first check.

## Observed result — both failing, as intended

Verbatim per-test lines and the summary line from the `-Output Detailed` output:

```
   [-] allows when the epic checkpoint authorizes while the parallel checkpoint does not (branches are ORed) 21ms (20ms|1ms)
   [-] emits the envelope-anomaly deny before reading either checkpoint 19ms (19ms|0ms)
Tests Passed: 27, Failed: 13, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Failed count is 13, comprising 3 allow tests ([P1-T1]), 8 deny tests ([P1-T2]), and the 2 added by this task. Both are individually listed as failing and the wrapper exited 1.

Both fail with `CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent`, since both mock the not-yet-existing parallel read seam. The pre-existing pass count remains 27, matching the [P0-T4] in-scope baseline.

Output Summary: EXPECTED FAILURE recorded. `Tests Passed: 27, Failed: 13`; wrapper exit 1 matches `ExpectedExitCode: 1`. Both newly added ordering-and-precedence tests are individually listed as failing, attributable to the missing parallel read seam. Cumulative new-test failure count is now 13 of the planned 19. The 27 pre-existing tests all still pass, matching the [P0-T4] in-scope baseline of 27.
