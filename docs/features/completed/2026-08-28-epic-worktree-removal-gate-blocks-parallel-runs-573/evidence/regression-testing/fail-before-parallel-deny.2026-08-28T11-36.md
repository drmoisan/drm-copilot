# Fail-Before — Parallel-Branch DENY Tests (P1-T2)

Timestamp: 2026-08-28T11-36

Task: [P1-T2] `[expect-fail]`
Issue: #573
Acceptance criteria exercised: AC-4
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## The eight named `It` blocks added

Added in a new `Context 'parallel branch fail-closed deny (AC-4)'`, whose `BeforeEach` mocks `Get-EpicWorktreeGateCheckpointContent` to `$null`. Each asserts `permissionDecision` is `deny` and that `permissionDecisionReason` matches `EPIC_WORKTREE_REMOVAL_BLOCKED`.

| # | `It` name | Deny case from the task |
| --- | --- | --- |
| a | `denies when both checkpoint seams return $null` | both seams `$null` |
| b | `denies when the parallel checkpoint body is malformed JSON` | malformed JSON body |
| c | `denies when route_id is absent even though a merged matching item is present` | `route_id` absent |
| d | `denies when route_id is present but is not parallel even though a merged matching item is present` | `route_id` present but not parallel |
| e | `denies when route_id is parallel but no items key exists` | no `items` key |
| f | `denies when no items[] entry matches the target worktree path` | no matching `items[]` entry |
| g | `denies when the matched parallel item has merge_status pr_open` | matched item `pr_open` |
| h | `denies when the matched parallel item carries no merge_status key` | eighth case: matched item with no `merge_status` key |

## Observed result — all eight failing, as intended

Verbatim per-test lines and the summary line from the `-Output Detailed` output:

```
   [-] denies when both checkpoint seams return $null 23ms (21ms|1ms)
   [-] denies when the parallel checkpoint body is malformed JSON 19ms (18ms|0ms)
   [-] denies when route_id is absent even though a merged matching item is present 20ms (19ms|1ms)
   [-] denies when route_id is present but is not parallel even though a merged matching item is present 21ms (20ms|1ms)
   [-] denies when route_id is parallel but no items key exists 21ms (21ms|0ms)
   [-] denies when no items[] entry matches the target worktree path 21ms (21ms|1ms)
   [-] denies when the matched parallel item has merge_status pr_open 19ms (18ms|0ms)
   [-] denies when the matched parallel item carries no merge_status key 36ms (35ms|0ms)
Tests Passed: 27, Failed: 11, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Failed count is 11, comprising the 3 allow tests from [P1-T1] and all 8 deny tests added by this task. Every one of the eight is listed above as failing on its own per-test line. The wrapper exited 1.

Each failure is `CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent` — the read seam does not yet exist. The pre-existing pass count remains 27, matching the [P0-T4] in-scope baseline.

Output Summary: EXPECTED FAILURE recorded. `Tests Passed: 27, Failed: 11`; wrapper exit 1 matches `ExpectedExitCode: 1`. All 8 newly added deny tests are individually listed as failing, alongside the 3 allow tests from [P1-T1]. The failure cause on every new test is the missing `Get-EpicWorktreeGateParallelCheckpointContent` read seam. The 27 pre-existing tests all still pass, matching the [P0-T4] in-scope baseline of 27.
