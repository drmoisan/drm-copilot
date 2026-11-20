# Fail-Before — Parallel-Branch ALLOW Tests (P1-T1)

Timestamp: 2026-08-28T11-36

Task: [P1-T1] `[expect-fail]`
Issue: #573
Acceptance criteria exercised: AC-1, AC-2, AC-3
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## The three named `It` blocks added

Added to `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` in a new `Context 'parallel branch allow (AC-1, AC-2, AC-3)'`, whose `BeforeEach` mocks `Get-EpicWorktreeGateCheckpointContent` to `$null` so branch 1 cannot authorize:

1. `allows when the matching parallel items[] record has merge_status merged` — AC-1
2. `allows when the matching parallel items[] record has merge_status worktree_removed` — AC-2
3. `matches a parallel worktree_path across backslash/forward-slash separator differences` — AC-3 (checkpoint path written with backslashes, command path written with forward slashes)

Each mocks `Get-EpicWorktreeGateParallelCheckpointContent` to a literal JSON string carrying `route_id` exactly `parallel`. No temporary file is created and no real checkpoint is read.

## Observed result — all three failing, as intended

Verbatim per-test lines and the summary line from the `-Output Detailed` output:

```
   [-] allows when the matching parallel items[] record has merge_status merged 26ms (24ms|1ms)
    CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent
   [-] allows when the matching parallel items[] record has merge_status worktree_removed 19ms (19ms|0ms)
    CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent
   [-] matches a parallel worktree_path across backslash/forward-slash separator differences 20ms (19ms|1ms)
    CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent
Tests Passed: 27, Failed: 3, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Failed count is 3, which satisfies the acceptance condition of at least 3 failures, and the wrapper exited 1.

The failure cause is `CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent` on all three — the read seam does not yet exist, so Pester cannot mock it. That is precisely the missing-parallel-seam attribution the task requires, and it is the fail-before signal the fix in Phase 2 removes.

The pre-existing pass count is 27, identical to the in-scope suite count recorded in the [P0-T4] baseline, so no pre-existing test regressed.

Output Summary: EXPECTED FAILURE recorded. `Tests Passed: 27, Failed: 3`; wrapper exit 1 matches `ExpectedExitCode: 1`. All 3 failures are the three newly added parallel-branch allow tests, each failing with `CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent`, which attributes them to the missing parallel read seam. The 27 pre-existing tests all still pass, matching the [P0-T4] in-scope baseline of 27.
