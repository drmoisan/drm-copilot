# Fail-Before — Consolidated Record for the Whole New-Test Set (P1-T6)

Timestamp: 2026-08-28T11-36

Task: [P1-T6] `[expect-fail]`
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## Counts read from the `Tests Passed: N, Failed: M` summary line

```
Tests Passed: 27, Failed: 19, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Metric | Value | Required |
| --- | --- | --- |
| Passed | 27 | equals the [P0-T4] in-scope baseline of 27 |
| Failed | 19 | exactly 19 |
| Skipped | 0 | — |
| Wrapper exit | 1 | matches `ExpectedExitCode: 1` |

**Zero unexpected failures among the pre-existing tests.** The passed count of 27 is identical to the in-scope suite count recorded in the [P0-T4] baseline artifact (`tests="27" errors="0" failures="0"`), so every pre-existing test still passes and none of the 19 failures is a pre-existing test.

## The 19 failing tests, by name, from the per-test lines of the same output

Allow cases — 3 (AC-1, AC-2, AC-3):

1. `allows when the matching parallel items[] record has merge_status merged`
2. `allows when the matching parallel items[] record has merge_status worktree_removed`
3. `matches a parallel worktree_path across backslash/forward-slash separator differences`

Deny cases — 8 (AC-4):

4. `denies when both checkpoint seams return $null`
5. `denies when the parallel checkpoint body is malformed JSON`
6. `denies when route_id is absent even though a merged matching item is present`
7. `denies when route_id is present but is not parallel even though a merged matching item is present`
8. `denies when route_id is parallel but no items key exists`
9. `denies when no items[] entry matches the target worktree path`
10. `denies when the matched parallel item has merge_status pr_open`
11. `denies when the matched parallel item carries no merge_status key`

Precedence and ordering — 2 (AC-7, AC-5):

12. `allows when the epic checkpoint authorizes while the parallel checkpoint does not (branches are ORed)`
13. `emits the envelope-anomaly deny before reading either checkpoint`

Direct predicate — 4 (AC-8):

14. `returns $false when Checkpoint is $null`
15. `returns $false when the route_id key is absent`
16. `returns $false when the items key is absent`
17. `skips an items[] entry that carries no worktree_path key`

Read seam — 2 (AC-9):

18. `Get-EpicWorktreeGateParallelCheckpointContent returns $null when the checkpoint file does not exist`
19. `Get-EpicWorktreeGateParallelCheckpointContent reads real content when the file exists`

3 + 8 + 2 + 4 + 2 = 19, matching the composition the task states.

## Why they fail

Two distinct causes, both the intended fail-before signal:

- Tests 1-13 and 18-19 fail with `CommandNotFoundException: Could not find Command Get-EpicWorktreeGateParallelCheckpointContent` — the parallel read seam does not yet exist, so Pester cannot mock it and the seam cannot be called.
- Tests 14-17 fail with `CommandNotFoundException: The term 'Test-ParallelCheckpointAllowsWorktreeRemoval' is not recognized as a name of a cmdlet, function, script file, or executable program.` — the predicate does not yet exist.

Both functions are created by [P2-T1] and [P2-T2], which is what converts this run to green at [P2-T5].

Output Summary: EXPECTED FAILURE recorded, consolidated. `Tests Passed: 27, Failed: 19`; wrapper exit 1 matches `ExpectedExitCode: 1`. Exactly 19 tests fail and all 19 are the newly added tests, enumerated above by name with their AC mapping (3 allow + 8 deny + 2 precedence/ordering + 4 predicate + 2 read-seam). Zero unexpected failures among the pre-existing tests: the passed count of 27 equals the in-scope pass count recorded in [P0-T4]. Failures are attributable to the two not-yet-existing functions `Get-EpicWorktreeGateParallelCheckpointContent` and `Test-ParallelCheckpointAllowsWorktreeRemoval`.
