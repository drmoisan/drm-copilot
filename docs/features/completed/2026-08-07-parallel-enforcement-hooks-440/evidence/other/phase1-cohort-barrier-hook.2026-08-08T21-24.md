# Phase 1 Implementation Evidence — Layer 1 Cohort Barrier Hook — Issue #440

Timestamp: 2026-08-08T21-24

Task: [P1-T1]

File created: `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (498 lines, under the 500-line limit)

Command: `wc -l .claude/hooks/enforce-parallel-cohort-barrier.ps1 && git status --short .claude/hooks/`

EXIT_CODE: 0

## Acceptance Criteria Verification

| Required element | Implemented as | Verified |
| --- | --- | --- |
| Script constant `$script:ParallelCheckpointPath` | `'artifacts/orchestration/parallel-orchestrator-state.json'` | yes |
| Script constant `$script:AllowedMergeStatuses` | `@('merged', 'worktree_removed')` | yes |
| Script constant `$script:ParallelModeMarker` | `'Parallel mode: true'` | yes |
| Activation gate: empty payload allows | early return in `Invoke-ParallelCohortBarrierDecision` | yes |
| Activation gate: malformed `CLAUDE_TOOL_INPUT` throws, entrypoint exits 1 | `throw` on `ConvertFrom-Json` failure; entrypoint `catch { Write-Error $_; exit 1 }` | yes |
| Activation gate: non-`orchestrator` `subagent_type` allows | `if (-not $subagent -or $subagent -ne 'orchestrator')` | yes |
| Activation gate: prompt lacking the marker allows | `-notlike "*$script:ParallelModeMarker*"` | yes |
| Prompt-based target resolution of the `docs/features/active/<folder>` token | `Find-ParallelCohortBarrierFeatureFolderFromPrompt` (epic regex verbatim, longest match wins, `.md` resolves to parent) matched to `items[].feature_folder` through the shared `Get-ParallelCohortBarrierFolderBasename` normalizer | yes |
| Unresolvable target denies with an instructive reason | `PARALLEL_COHORT_BARRIER_BLOCKED: a parallel-mode orchestrator delegation must reference the target item feature folder path (docs/features/active/<folder>) in the prompt ...` | yes |
| Mockable read seam | `Get-ParallelCohortBarrierCheckpointContent`, called from `Invoke-ParallelCohortBarrierDecision` | yes |
| Missing/unparseable checkpoint denies fail-closed | `$checkpoint = $null` on both paths, then `Test-ParallelCohortBarrierClear` returns `$false` | yes |
| Cohort membership restricted to `generation == recolor_generation` | `Find-ParallelCohortBarrierCohortIndex` skips any row whose `generation` differs from the top-level `recolor_generation` | yes |
| Absence of a current-generation cohort assignment denies fail-closed | `if ($null -eq $targetIndex) { return $false }` | yes |
| Deny prefix literal | `PARALLEL_COHORT_BARRIER_BLOCKED` | yes |
| Barrier condition | every `conflict_edges[]` neighbor whose current-generation cohort index is strictly less than the target's must have `merge_status` in `('merged', 'worktree_removed')` | yes |
| `ci_green` does not satisfy the barrier | `ci_green` is absent from `$script:AllowedMergeStatuses`; asserted by test | yes |
| Same-cohort and later-cohort neighbors do not block Layer 1 | `if ($neighborIndex -ge $targetIndex) { continue }` | yes |
| Public entry `Invoke-ParallelCohortBarrierDecision -ToolInputRaw <json>` | present | yes |
| Ordered-dictionary `hookSpecificOutput` shape | `Get-ParallelCohortBarrierAllowDecision` / `Get-ParallelCohortBarrierBlockDecision`, identical shape to the epic hook | yes |
| Dot-source test guard | `if ($MyInvocation.InvocationName -eq '.') { return }` | yes |
| Compressed-JSON emission and exit-code convention | `ConvertTo-Json -Compress -Depth 5`; `exit 0` success, `exit 1` on throw | yes |
| File under 500 lines | 498 | yes |

## Additive-Only Confirmation

`git status --short .claude/hooks/` reports exactly one entry, `?? .claude/hooks/enforce-parallel-cohort-barrier.ps1`. The template `.claude/hooks/enforce-epic-wave-barrier.ps1` is unmodified (it does not appear in the status output), satisfying plan Binding Constraint 4.

## Adaptation Notes

- The epic hook's `depends_on` lookup is replaced by conflict-edge plus cohort-index logic, because the parallel surface prohibits `depends_on` at any level (`.claude/rules/parallel-orchestration.md` invariant 10).
- Target matching compares basenames on both sides via `Get-ParallelCohortBarrierFolderBasename`, so a checkpoint that records `items[].feature_folder` as a full `docs/features/active/<folder>` path and one that records a bare basename both resolve against the bare prompt token frozen by P0-T10 (U13).
- A conflict neighbor that is absent from the current coloring is skipped rather than denied: it is by definition not "a neighbor in a strictly prior current-generation cohort". Invariant 13 permits absence only for `withdrawn`, `merged`, or `blocked` items.

Output Summary: PASS. Created `.claude/hooks/enforce-parallel-cohort-barrier.ps1` at 498 lines (under the 500-line limit) as a near-verbatim adaptation of `.claude/hooks/enforce-epic-wave-barrier.ps1` with the `depends_on` lookup replaced by conflict-edge plus current-generation cohort-index logic. All twenty-three required elements of the task text were verified present, including the three frozen script constants, the four-branch activation gate, the mockable `Get-ParallelCohortBarrierCheckpointContent` read seam (which `Invoke-ParallelCohortBarrierDecision` actually calls, so the mock intercepts it), fail-closed denial on missing/unparseable checkpoint and on missing current-generation cohort assignment, the exact `PARALLEL_COHORT_BARRIER_BLOCKED` deny prefix, exclusion of `ci_green` from the barrier-satisfying set, and non-blocking treatment of same-cohort and later-cohort neighbors. `git status --short .claude/hooks/` shows only the one new untracked file, confirming `enforce-epic-wave-barrier.ps1` remains byte-identical per plan Binding Constraint 4.
