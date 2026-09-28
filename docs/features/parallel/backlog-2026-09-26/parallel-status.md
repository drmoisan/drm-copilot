<!-- GENERATED FILE - DO NOT HAND-AUTHOR. Regenerated from artifacts/orchestration/parallel-orchestrator-state.json by parallel-orchestrator. -->

# backlog-2026-09-26 - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be hand-authored. It is a read-only projection: the manifest and the checkpoint are authoritative, and this document is never the source of the cohort table or of the schedule.

**Header**

- `parallel_slug`: backlog-2026-09-26
- `mode`: closed
- `max_concurrency`: 4
- `current_cohort`: 1
- `recolor_generation`: 0
- `last_updated`: 2026-09-27T02:48:00Z
- `next_step`: COMPLETE

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 513 | docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513 | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/702 | b924a9e2352896e6f3e0e88e40d7053be425c28d | 2026-09-26T23:38:00Z | 2026-09-27T00:29:18Z | 2026-09-27T00:29:40Z |
| 528 | docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528 | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/701 | e3199e6b304ee2a888cbf66210d9836bdfb33512 | 2026-09-26T23:38:00Z | 2026-09-27T00:17:16Z | 2026-09-27T00:17:47Z |
| 588 | docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588 | 1 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/704 | fd9140b19e82116cba31e083ac61e424ccb2504a | 2026-09-27T01:07:00Z | 2026-09-27T01:57:18Z | 2026-09-27T01:58:03Z |
| 594 | docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594 | 1 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/705 | 98672438d68aa3c8aaf7172051f33cac8b86996f | 2026-09-27T01:07:00Z | 2026-09-27T02:45:05Z | 2026-09-27T02:45:29Z |
| 622 | docs/features/active/collect-pr-context-fabricates-auto-close-issues-622 | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/703 | b67453837646fd2dd4f5ac692f76e6f7703fe798 | 2026-09-26T23:38:00Z | 2026-09-27T01:03:25Z | 2026-09-27T01:03:50Z |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 513, 528, 622 |
| 1 | 0 | 588, 594 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |
| 528 | 588 | path_overlap |
| 528 | 594 | path_overlap |
| 588 | 622 | path_overlap |
| 594 | 622 | path_overlap |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |

## Mergeable Conflicts Resolved

| issue_num | path | resolved_at | merged_against | merge_commit_sha | entries_added_from_ours | entries_added_from_theirs | version_resolutions |
| --- | --- | --- | --- | --- | --- | --- | --- |
