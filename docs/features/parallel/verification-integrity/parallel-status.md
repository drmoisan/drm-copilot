<!--
  GENERATED FILE - DO NOT HAND-AUTHOR.

  Regenerated in full from artifacts/orchestration/parallel-orchestrator-state.json by
  parallel-orchestrator. The run manifest and the checkpoint are authoritative; this
  document is never the source of the cohort table or of the schedule. Any manual edit is
  overwritten on the next regeneration.
-->

# verification-integrity - Parallel Run Status (generated)

**Header**

- `parallel_slug`: verification-integrity
- `mode`: open
- `max_concurrency`: 8
- `current_cohort`: 1
- `recolor_generation`: 0
- `last_updated`: 2026-08-21T01:36:48Z

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | pr_opened_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 485 | `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485` | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/494 | 646504f32d57e098f82ab7a5235de1824348d522 | 2026-08-20T13:45:35Z | 2026-08-20T15:54:20Z | 2026-08-20T16:07:24Z | 2026-08-20T16:21:00Z |
| 486 | `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/496 | cd4b887f4e56606a7aca4bd02e093829b33bf8db | 2026-08-20T18:36:31Z | 2026-08-20T22:52:00Z | 2026-08-20T22:45:06Z | 2026-08-20T22:54:00Z |
| 487 | `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487` | 1 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/497 | 364df72f636ddc2df86c6007f3708febf96362ad | 2026-08-20T22:56:00Z | 2026-08-21T00:20:00Z | 2026-08-21T00:24:06Z | 2026-08-21T01:07:00Z |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 485, 486 |
| 1 | 0 | 487 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |
| 486 | 487 | path_overlap |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |
| close | - | - | - | - | 0 | 2026-08-21T01:36:48Z |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |
