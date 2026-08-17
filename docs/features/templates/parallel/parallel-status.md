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

# <parallel-slug> - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be
hand-authored. Any manual edit will be overwritten on the next regeneration. It is a read-only
projection: the manifest and the checkpoint are authoritative, and this document is never the
source of the cohort table or of the schedule.

**Header**

- `parallel_slug`: _(run slug)_
- `mode`: _(`closed` or `open`; defaults to `closed`)_
- `max_concurrency`: _(integer 1 through 32; defaults to 4)_
- `current_cohort`: _(progress indicator: the lowest current-generation cohort index still holding a non-terminal, non-withdrawn item; updated only on durable confirmation and gating nothing)_
- `recolor_generation`: _(current generation; only cohorts at this generation are scheduled)_
- `last_updated`: _(ISO-8601 timestamp of this regeneration)_

**Items** — one row per `items[]` entry. The `cohort_index` column takes the place of the epic
status document's wave column.

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| _(populated on run kickoff from the manifest and the seeded cohorts, then updated in place at every item `state` or `merge_status` transition)_ | | | | | | | | | |

**Cohorts** — projection of `cohorts[] { index, generation, item_keys[] }`, so a recolored schedule
stays traceable by `generation`.

| index | generation | item_keys |
| --- | --- | --- |
| _(populated on run kickoff from the seeded cohort table, then reprojected at every cohort transition and every `recolor_generation` increment)_ | | |

## Conflict Edges

Read-only projection of `conflict_edges[]`. The array is seeded by `parallel-planner` and
recomputed only by the radius-drift feature; `parallel-orchestrator` renders it and never writes
it. An empty array renders this section empty rather than omitting it.

| a | b | reason |
| --- | --- | --- |
| _(populated from `conflict_edges[]`; empty when the run has no recorded contention)_ | | |

## Mutations

Read-only projection of `mutations[]`. Rows appear only once the mutation-protocol feature
populates that array; `parallel-orchestrator` renders it and never writes it. An empty array
renders this section empty rather than omitting it.

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |
| _(populated from `mutations[]`; empty until a mutation is recorded)_ | | | | | | |

## Drift Events

Read-only projection of `drift_events[]`. The array is populated only by the radius-drift feature;
`parallel-orchestrator` renders it and never writes it. An empty array renders this section empty
rather than omitting it.

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |
| _(populated from `drift_events[]`; empty until a drift event is recorded)_ | | | | | |
