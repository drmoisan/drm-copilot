# Phase 1 Implementation Evidence — Layer 1 Cohort Barrier Test Suite — Issue #440

Timestamp: 2026-08-08T21-24

Task: [P1-T2]

File created: `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` (498 lines, under the 500-line limit)

Command: `pwsh -NoProfile -Command 'Invoke-Pester -Path tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 -Output Detailed'`

EXIT_CODE: 0

## Scoped Run Result

```
Discovery found 56 tests in 185ms.
Tests Passed: 56, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Tests completed in 2.16s
```

## Read-Seam Compliance (mandatory)

Every checkpoint fixture is supplied through `Mock -CommandName Get-ParallelCohortBarrierCheckpointContent`. The suite contains:

- no reference to `artifacts/orchestration/parallel-orchestrator-state.json` as a read target,
- no reference to `artifacts/orchestration/orchestrator-state.json`,
- no temporary-file creation (no `New-TemporaryFile`, no `$env:TEMP`, no `Out-File`, no `Set-Content`).

The only filesystem interaction is inside the dedicated `real Test-Path read seam` context, which mocks `Test-Path` and `Get-Content` with a `-ParameterFilter` bound to `$script:ParallelCheckpointPath` so the seam's own two branches are covered without touching disk.

The dedicated `read seam binding (the mocked seam value determines the decision)` context proves the seam is bound at run time rather than merely present:

| Test | Payload | Mocked seam value | Decision | `Should -Invoke` assertion |
| --- | --- | --- | --- | --- |
| allows when the seam reports a merged neighbor | identical | neighbor `merge_status: merged` | `allow` | seam invoked `-Times 1 -Exactly` |
| denies for the identical payload when the seam reports ci_green | identical | neighbor `merge_status: ci_green` | `deny` | seam invoked `-Times 1 -Exactly` |
| does not call the read seam when the call is out of scope | non-`orchestrator` target | n/a | `allow` | seam invoked `-Times 0 -Exactly` |

Because the two decision rows use a byte-identical `ToolInputRaw` payload and differ only in the mocked seam value, per-side correctness alone cannot explain the divergent decisions; the production script must be calling the named seam.

## Required Coverage from the Task Text

| Required case | Test name | Result |
| --- | --- | --- |
| deny for a conflicting strictly-prior-cohort neighbor with non-terminal `merge_status` | denies when the conflicting prior-cohort neighbor has merge_status pr_open / not_started / blocked_drift | PASS |
| deny for a `ci_green` neighbor specifically | denies when the conflicting prior-cohort neighbor has merge_status ci_green | PASS |
| allow when every conflicting prior-cohort neighbor is `merged` or `worktree_removed` | allows when the conflicting prior-cohort neighbor has merge_status merged; allows when ... worktree_removed | PASS |
| allow for a target with no conflicting prior-cohort neighbors | allows a cohort-0 target whose only conflicting neighbor sits in a later cohort; allows a target that has no conflict edges at all; allows when a same-cohort conflicting neighbor is not terminal | PASS |
| allow for empty payload | allows when CLAUDE_TOOL_INPUT is empty | PASS |
| allow for non-`orchestrator` `subagent_type` | allows a non-orchestrator subagent delegation | PASS |
| allow for a prompt lacking `Parallel mode: true` | allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker | PASS |
| deny fail-closed for missing checkpoint | denies when the parallel checkpoint file is absent | PASS |
| deny fail-closed for malformed checkpoint JSON | denies when the parallel checkpoint content is malformed JSON | PASS |
| deny fail-closed for no feature-folder token in the prompt | denies when the prompt carries no feature-folder token | PASS |
| deny fail-closed for no matching `items[]` record | denies when no items[] record matches the resolved feature folder | PASS |
| deny fail-closed for no current-generation cohort assignment | denies when the target has no current-generation cohort assignment | PASS |
| malformed `CLAUDE_TOOL_INPUT` throws | throws on malformed JSON so the hook exits 1 | PASS |

## Full Test-Case Inventory (56)

Context `allow (no-op) when the call is out of scope`
1. allows when CLAUDE_TOOL_INPUT is empty
2. allows a non-orchestrator subagent delegation
3. allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker
4. allows an orchestrator delegation with an empty prompt
5. throws on malformed JSON so the hook exits 1

Context `allow when every conflicting prior-cohort neighbor is merged or worktree_removed`
6. allows when the conflicting prior-cohort neighbor has merge_status merged
7. allows when the conflicting prior-cohort neighbor has merge_status worktree_removed
8. allows a cohort-0 target whose only conflicting neighbor sits in a later cohort
9. allows a target that has no conflict edges at all
10. allows when a same-cohort conflicting neighbor is not terminal (not a Layer 1 concern)
11. ignores a superseded-generation cohort row when projecting the current coloring

Context `deny PARALLEL_COHORT_BARRIER_BLOCKED when a conflicting prior-cohort neighbor is not terminal`
12. denies when the conflicting prior-cohort neighbor has merge_status pr_open
13. denies when the conflicting prior-cohort neighbor has merge_status ci_green
14. denies when the conflicting prior-cohort neighbor has merge_status not_started
15. denies when the conflicting prior-cohort neighbor has merge_status blocked_drift
16. denies when the conflicting prior-cohort neighbor record has no merge_status key
17. denies when the conflicting prior-cohort neighbor has no items[] record
18. denies when the conflict edge names the target as endpoint a

Context `deny fail-closed on an unusable checkpoint or an unresolvable target`
19. denies when the parallel checkpoint file is absent
20. denies when the parallel checkpoint content is malformed JSON
21. denies when the prompt carries no feature-folder token
22. denies when no items[] record matches the resolved feature folder
23. denies when the target has no current-generation cohort assignment
24. denies when the target items[] record carries no issue_num

Context `read seam binding (the mocked seam value determines the decision)`
25. calls the read seam exactly once and allows when the seam reports a merged neighbor
26. calls the read seam exactly once and denies for the identical payload when the seam reports ci_green
27. does not call the read seam when the call is out of scope

Context `Get-ParallelCohortBarrierFolderBasename helper`
28. returns $null for an empty value
29. reduces a full docs path to its basename
30. resolves a .md-suffixed value to its parent directory basename

Context `Find-ParallelCohortBarrierFeatureFolderFromPrompt helper`
31. returns $null for an empty prompt
32. resolves a bare docs/features/active token to its basename
33. returns $null when no path token is present

Context `Find-ParallelCohortBarrierItemRecord helper`
34. returns $null when Checkpoint is $null
35. returns $null when the items key is absent
36. skips item records that carry no feature_folder
37. matches a checkpoint that records a bare basename feature_folder

Context `Find-ParallelCohortBarrierItemByKey helper`
38. returns $null when Checkpoint is $null
39. returns $null when the items key is absent
40. skips item records that carry no issue_num

Context `Find-ParallelCohortBarrierCohortIndex helper`
41. returns $null when Checkpoint is $null
42. returns $null when recolor_generation is absent
43. skips cohort rows that are missing a required key
44. skips cohort rows whose index is not an integer
45. returns cohort index 0 for a current-generation match

Context `Get-ParallelCohortBarrierConflictNeighborList helper`
46. returns an empty list when Checkpoint is $null
47. returns an empty list when conflict_edges is absent
48. skips edges that are missing an endpoint
49. returns the opposite endpoint regardless of which side matches

Context `Test-ParallelCohortBarrierClear helper`
50. returns $false when Checkpoint is $null
51. returns $false when ItemRecord is $null
52. returns $false when the item record carries no issue_num

Context `real Test-Path read seam`
53. Get-ParallelCohortBarrierCheckpointContent returns $null when the checkpoint file does not exist
54. Get-ParallelCohortBarrierCheckpointContent reads real content when the file exists

Context `script entrypoint (end-to-end)`
55. allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)
56. exits 1 on malformed JSON

Note on cases 55-56: the entrypoint runs the real script in a child `pwsh`, but both payloads short-circuit before the checkpoint read (empty payload returns `allow` immediately; malformed JSON throws), so neither case reads the live checkpoint and neither is environment-sensitive. This mirrors the epic hook suites verbatim.

Output Summary: PASS. Created `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` at 498 lines with 56 test cases; the scoped run reports 56 passed, 0 failed, 0 skipped in 2.16 s. Every checkpoint fixture is injected through `Mock -CommandName Get-ParallelCohortBarrierCheckpointContent`; the suite never reads `artifacts/orchestration/parallel-orchestrator-state.json` or `artifacts/orchestration/orchestrator-state.json` from disk and creates no temporary files, so it does not reproduce the live-checkpoint coupling defect present in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`. Run-time seam binding is proved rather than assumed: two tests submit a byte-identical payload and diverge (`allow` versus `deny`) solely on the mocked seam value, each additionally asserting `Should -Invoke -CommandName Get-ParallelCohortBarrierCheckpointContent -Times 1 -Exactly`, and a third asserts `-Times 0 -Exactly` for an out-of-scope call. All thirteen behavior cases enumerated in the P1-T2 task text are covered and passing.
