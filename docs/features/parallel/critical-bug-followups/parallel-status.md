<!--
  GENERATED FILE - DO NOT HAND-AUTHOR.

  parallel-status.md is a generated projection of the parallel-orchestrator checkpoint
  (artifacts/orchestration/parallel-orchestrator-state.json), regenerated in full at each boundary
  in the `## Documentation Maintenance Boundaries` section of
  .claude/skills/parallel-orchestrate/SKILL.md. Any manual edit is overwritten on the next
  regeneration. The run manifest and the checkpoint are authoritative; this document is never the
  source of the cohort table or of the schedule.
-->

# critical-bug-followups - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be
hand-authored. It is a read-only projection.

**Header**

- `parallel_slug`: critical-bug-followups
- `mode`: closed
- `max_concurrency`: 4
- `current_cohort`: 1
- `recolor_generation`: 0
- `last_updated`: 2026-08-28T20-25

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 573 | `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573` | 0 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/579 | e546e814e246d814474d35067f0674590b0e41ff | 2026-08-28T11-45 | 2026-08-28T16-41 |  |
| 574 | `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574` | 1 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/582 | b0eaa58f6c82d27ad40fc7b327cf1401c9161549 | 2026-08-28T17-08 | 2026-08-28T18-06 |  |
| 575 | `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575` | 1 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/580 | d8b81f81cf194d337fe9e61e8c10ac8278c043fd | 2026-08-28T17-08 | 2026-08-28T17-23 |  |
| 576 | `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576` | 1 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/581 | 0a5bd1059c767e43b6f6529452791a6d853f4d72 | 2026-08-28T17-08 | 2026-08-28T18-00 |  |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 573 |
| 1 | 0 | 574, 575, 576 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |
| 573 | 574 | path_overlap |
| 573 | 575 | module_overlap |
| 573 | 576 | path_overlap |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |
