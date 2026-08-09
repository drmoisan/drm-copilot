# Phase 1 Implementation Evidence — Parallel Worktree Removal Gate Test Suite — Issue #440

Timestamp: 2026-08-08T21-24

Task: [P1-T4]

File created: `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` (350 lines, under the 500-line limit)

Command: `pwsh -NoProfile -Command 'Invoke-Pester -Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 -Output Detailed'`

EXIT_CODE: 0

## Scoped Run Result

```
Tests Passed: 40, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Tests completed in 1.86s
```

## Read-Seam Compliance (mandatory)

Every checkpoint fixture is supplied through `Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent`. The suite contains no read of `artifacts/orchestration/parallel-orchestrator-state.json`, no read of `artifacts/orchestration/orchestrator-state.json`, and no temporary-file creation. The only filesystem interaction is inside the `real Test-Path read seam` context, which mocks `Test-Path` and `Get-Content` with a `-ParameterFilter` bound to `$script:ParallelCheckpointPath`.

Run-time seam binding is proved, not assumed:

| Test | Command payload | Mocked seam value | Decision | `Should -Invoke` |
| --- | --- | --- | --- | --- |
| calls the read seam exactly once and allows when the seam reports merged | identical | `merge_status: merged` | `allow` | `-Times 1 -Exactly` |
| calls the read seam exactly once and denies for the identical command when the seam reports ci_green | identical | `merge_status: ci_green` | `deny` | `-Times 1 -Exactly` |
| does not call the read seam for a command that is not git worktree remove | `git worktree list` | n/a | `allow` | `-Times 0 -Exactly` |

The two decision rows submit a byte-identical `ToolInputRaw` and diverge only on the mocked seam value, so the production script must resolve the named seam at run time.

## Non-Terminal `merge_status` Coverage (each enum value at least once)

The `merge_status` enum is owned by F3 and has eight members; the two barrier-satisfying values are covered in the allow context and the remaining six are each covered by a dedicated deny test.

| `merge_status` | Class | Test | Result |
| --- | --- | --- | --- |
| `not_started` | non-terminal | denies when the matching record has merge_status not_started | PASS |
| `worktree_created` | non-terminal | denies when the matching record has merge_status worktree_created | PASS |
| `pr_open` | non-terminal | denies when the matching record has merge_status pr_open | PASS |
| `ci_green` | non-terminal | denies when the matching record has merge_status ci_green | PASS |
| `blocked_drift` | non-terminal | denies when the matching record has merge_status blocked_drift | PASS |
| `blocked_ci_loop_limit` | non-terminal | denies when the matching record has merge_status blocked_ci_loop_limit | PASS |
| `merged` | terminal | allows git worktree remove when the matching record has merge_status merged | PASS |
| `worktree_removed` | terminal | allows git worktree remove when the matching record has merge_status worktree_removed | PASS |

## Deny-Prefix Assertion Form

Every deny test asserts `$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'`. `-BeLike` with a trailing wildcard verifies the token is the reason's prefix; a substring match anywhere in the reason would not satisfy it. Eleven deny tests carry this assertion.

## Full Test-Case Inventory (40)

Context `commands outside scope are allowed unconditionally`
1. allows when CLAUDE_TOOL_INPUT is empty
2. allows when the JSON payload has no command field
3. allows git worktree list
4. allows git worktree add
5. allows an unrelated Bash command
6. throws on malformed JSON so the hook exits 1

Context `allow when the matched item merge_status is terminal`
7. allows git worktree remove when the matching record has merge_status merged
8. allows git worktree remove when the matching record has merge_status worktree_removed
9. allows git worktree remove --force when the matching record has merge_status merged

Context `deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status`
10. denies when the matching record has merge_status not_started
11. denies when the matching record has merge_status worktree_created
12. denies when the matching record has merge_status pr_open
13. denies when the matching record has merge_status ci_green
14. denies when the matching record has merge_status blocked_drift
15. denies when the matching record has merge_status blocked_ci_loop_limit
16. denies when the matching record carries no merge_status key

Context `deny fail-closed on an unusable checkpoint or an unmatched path`
17. denies when the parallel checkpoint file is absent
18. denies when the parallel checkpoint content is malformed JSON
19. denies when no items[] record has a matching worktree_path
20. denies when the checkpoint carries no items key

Context `read seam binding (the mocked seam value determines the decision)`
21. calls the read seam exactly once and allows when the seam reports merged
22. calls the read seam exactly once and denies for the identical command when the seam reports ci_green
23. does not call the read seam for a command that is not git worktree remove

Context `path normalization`
24. matches worktree_path across backslash/forward-slash separator differences
25. matches worktree_path when the recorded value carries a trailing slash
26. matches worktree_path when the command quotes the target path

Context `Get-ParallelWorktreeRemovalCommandPath helper`
27. extracts the target path from the command text
28. returns $null when the command does not name a path

Context `Find-ParallelWorktreeItemRecord helper`
29. returns $null when Checkpoint is $null
30. returns $null when the items key is absent
31. returns $null when WorktreePath is empty
32. skips item records with no worktree_path key
33. returns the matching item record

Context `Test-ParallelWorktreeRemovalAllowed helper`
34. returns $false when ItemRecord is $null
35. returns $false when the merge_status key is absent
36. returns $true for merge_status merged

Context `real Test-Path read seam`
37. Get-ParallelWorktreeRemovalGateCheckpointContent returns $null when the checkpoint file does not exist
38. Get-ParallelWorktreeRemovalGateCheckpointContent reads real content when the file exists

Context `script entrypoint (end-to-end)`
39. allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)
40. exits 1 on malformed JSON

Cases 39-40 short-circuit before the checkpoint read (empty payload returns `allow`; malformed JSON throws), so neither reads the live checkpoint. This mirrors the epic suites verbatim.

Output Summary: PASS. Created `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` at 350 lines with 40 test cases; the scoped run reports 40 passed, 0 failed, 0 skipped in 1.86 s. Every checkpoint fixture is injected through `Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent`; the suite reads no live checkpoint and creates no temporary files, so it does not reproduce the coupling defect in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`. Seam binding is proved by two tests that submit a byte-identical command and diverge (`allow` versus `deny`) solely on the mocked seam value, each asserting `Should -Invoke ... -Times 1 -Exactly`, plus one asserting `-Times 0 -Exactly` for an out-of-scope command. All six non-terminal `merge_status` enum values are each covered by a dedicated deny test (including `pr_open` and `ci_green`), both terminal values are covered by allow tests, non-`git worktree remove` commands are covered by four unconditional-allow tests, fail-closed denial is covered for unreadable checkpoint, malformed checkpoint JSON, an unmatched worktree path, and a checkpoint with no `items` key, malformed `CLAUDE_TOOL_INPUT` is asserted to throw, and all eleven deny tests assert the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` token as a prefix using `-BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'`.
