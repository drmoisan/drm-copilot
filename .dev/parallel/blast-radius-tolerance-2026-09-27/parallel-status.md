<!--
  GENERATED FILE — DO NOT HAND-AUTHOR.

  parallel-status.md is a generated projection of the parallel-orchestrator
  checkpoint (artifacts/orchestration/parallel-orchestrator-state.json). It is
  regenerated in full by the parallel-orchestrator agent at each boundary listed
  in the `## Documentation Maintenance Boundaries` section of
  .claude/skills/parallel-orchestrate/SKILL.md: run kickoff, every item state or
  merge_status transition, every cohort transition, every recolor_generation
  increment, every append to mutations[] or drift_events[], and run completion
  (closed mode) or run close (open mode).

  It is never the source of the cohort table and never the source of the
  schedule, and it must never be edited by hand — the run manifest at
  docs/features/parallel/<slug>/parallel.md and the parallel checkpoint JSON are
  the authoritative sources. Any manual edit is overwritten on the next
  regeneration.
-->

# blast-radius-tolerance-2026-09-27 - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be
hand-authored. Any manual edit will be overwritten on the next regeneration. It is a read-only
projection: the manifest and the checkpoint are authoritative, and this document is never the
source of the cohort table or of the schedule.

**Header**

- `parallel_slug`: blast-radius-tolerance-2026-09-27
- `mode`: closed
- `max_concurrency`: 4
- `current_cohort`: 0
- `recolor_generation`: 0
- `last_updated`: 2026-10-09T23:24:20Z

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 452 | docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452 | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/747 | e34a88b4ccd55d1be418109dceaee13137a221c1 | 2026-09-27T18:33:10Z | 2026-09-27T22:50:30Z | 2026-09-27T22:52:00Z |
| 722 | docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722 | 0 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/748 | 92b2b23de002b9836995b0a69b5078f5c94916da | 2026-09-27T18:33:10Z | 2026-09-28T10:49:13Z |  |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 452, 722 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |

## Mergeable Conflicts Resolved

| issue_num | path | resolved_at | merged_against | merge_commit_sha | entries_added_from_ours | entries_added_from_theirs | version_resolutions |
| --- | --- | --- | --- | --- | --- | --- | --- |
