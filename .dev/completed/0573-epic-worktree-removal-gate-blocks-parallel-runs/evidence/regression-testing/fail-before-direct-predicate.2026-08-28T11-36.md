# Fail-Before — Direct Predicate Tests (P1-T4)

Timestamp: 2026-08-28T11-36

Task: [P1-T4] `[expect-fail]`
Issue: #573
Acceptance criteria exercised: AC-8
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 1
ExpectedExitCode: 1

## The four named `It` blocks added

Added in a new `Context 'Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)'`. Each calls the predicate directly and asserts `Should -BeFalse`, reaching guard clauses the end-to-end cases cannot, mirroring the merge gate's direct-branch-coverage contexts:

1. `returns $false when Checkpoint is $null`
2. `returns $false when the route_id key is absent`
3. `returns $false when the items key is absent`
4. `skips an items[] entry that carries no worktree_path key`

Every fixture is a literal JSON string parsed in-test with `ConvertFrom-Json`; no file is read and no temporary file is created.

## Observed result — all four failing, as intended

Verbatim per-test lines and the summary line from the `-Output Detailed` output:

```
   [-] returns $false when Checkpoint is $null 16ms (15ms|1ms)
   [-] returns $false when the route_id key is absent 16ms (15ms|0ms)
   [-] returns $false when the items key is absent 15ms (15ms|0ms)
   [-] skips an items[] entry that carries no worktree_path key 16ms (15ms|0ms)
Tests Passed: 27, Failed: 17, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Failed count is 17: 3 allow ([P1-T1]) + 8 deny ([P1-T2]) + 2 precedence/ordering ([P1-T3]) + the 4 added here. All four are individually listed as failing and the wrapper exited 1.

The failure cause on these four differs from the earlier tasks and is the correct one for a direct predicate test:

```
CommandNotFoundException: The term 'Test-ParallelCheckpointAllowsWorktreeRemoval' is not recognized as a name of a cmdlet, function, script file, or executable program.
```

The predicate does not yet exist. The pre-existing pass count remains 27, matching the [P0-T4] in-scope baseline.

Output Summary: EXPECTED FAILURE recorded. `Tests Passed: 27, Failed: 17`; wrapper exit 1 matches `ExpectedExitCode: 1`. All 4 newly added direct-predicate tests are individually listed as failing, each with `CommandNotFoundException: The term 'Test-ParallelCheckpointAllowsWorktreeRemoval' is not recognized`, attributing them to the missing predicate rather than to the missing read seam. Cumulative new-test failure count is now 17 of the planned 19. The 27 pre-existing tests all still pass, matching the [P0-T4] in-scope baseline of 27.
