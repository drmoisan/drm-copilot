# Fail-Before — Parallel Read-Seam Tests (P1-T5)

Timestamp: 2026-08-28T11-36

Task: [P1-T5] `[expect-fail]`
Issue: #573
Acceptance criteria exercised: AC-9
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## The two named `It` blocks added

Added in a new `Context 'real Test-Path parallel read seam (AC-9)'`, mirroring the existing epic read-seam context at `Context 'real Test-Path read seam'`:

1. `Get-EpicWorktreeGateParallelCheckpointContent returns $null when the checkpoint file does not exist` — `Test-Path` mocked `$false` under `-ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }`; the seam must return `$null`.
2. `Get-EpicWorktreeGateParallelCheckpointContent reads real content when the file exists` — `Test-Path` mocked `$true` and `Get-Content` mocked under the same parameter filter on the parallel checkpoint script variable; the seam must return the mocked content.

Both parameter filters are keyed on `$script:ParallelCheckpointPath`, the script variable [P2-T1] adds, so the mocks are scoped to the parallel path and cannot intercept the epic seam's reads.

## Observed result — both failing, as intended

Verbatim per-test lines and the summary line from the `-Output Detailed` output:

```
   [-] Get-EpicWorktreeGateParallelCheckpointContent returns $null when the checkpoint file does not exist 20ms (19ms|1ms)
   [-] Get-EpicWorktreeGateParallelCheckpointContent reads real content when the file exists 27ms (26ms|0ms)
Tests Passed: 27, Failed: 19, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Failed count is 19, which is the full planned new-test set: 3 allow + 8 deny + 2 precedence/ordering + 4 predicate + 2 read-seam. Both tests added here are individually listed as failing and the wrapper exited 1.

The pre-existing pass count remains 27, matching the [P0-T4] in-scope baseline.

## File-size check

`wc -l` reports the extended suite at **405 lines**, comfortably under the 500-line limit in `.claude/rules/general-code-change.md`. The table-driven consolidation contingency in plan decision 5 is therefore not needed, and no eighth file was created.

Output Summary: EXPECTED FAILURE recorded. `Tests Passed: 27, Failed: 19`; wrapper exit 1 matches `ExpectedExitCode: 1`. Both newly added read-seam tests are individually listed as failing. The cumulative new-test failure count has reached exactly 19, the full planned set. The 27 pre-existing tests all still pass, matching the [P0-T4] in-scope baseline of 27. The suite is 405 lines, under the 500-line limit.
