<!--
  GENERATED FILE — DO NOT HAND-AUTHOR.

  parallel-status.md is a generated projection of the parallel-orchestrator
  checkpoint (artifacts/orchestration/parallel-orchestrator-state.json). It is
  regenerated in full by the parallel-orchestrator agent at each boundary listed
  in the `## Documentation Maintenance Boundaries` section of
  .claude/skills/parallel-orchestrate/SKILL.md. It is never the source of the
  cohort table or of the schedule and must never be edited by hand.
-->

# bugs-1001-1002-1003-1006 - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be
hand-authored. Any manual edit will be overwritten on the next regeneration. It is a read-only
projection: the manifest and the checkpoint are authoritative, and this document is never the
source of the cohort table or of the schedule.

**Header**

- `parallel_slug`: bugs-1001-1002-1003-1006
- `mode`: open
- `max_concurrency`: 4
- `current_cohort`: 7
- `recolor_generation`: 0
- `last_updated`: 2026-10-31T22:05:00Z

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1009 | docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009 | 0 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1017 | 0c0027faefff4231a129579b2a850fe4c377f4e8 | 2026-10-30T17:04:00Z | 2026-10-30T19:43:58Z | 2026-10-31T22:05:00Z |
| 1010 | docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010 | 1 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1039 | 1a342cc8c974593fd0c733894a7b140527dbca82 | 2026-10-30T19:46:00Z | 2026-10-31T00:54:21Z | 2026-10-31T00:55:00Z |
| 1011 | docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011 | 2 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1040 | ccec4eba82e272d27f7d81c0e0657a93110de5fb | 2026-10-31T00:57:00Z | 2026-10-31T06:05:21Z | 2026-10-31T06:07:00Z |
| 1001 | docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001 | 3 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1042 | 1898400756e909b88cde5f51a05f0b11d423d3b0 | 2026-10-31T06:09:00Z | 2026-10-31T07:55:15Z | 2026-10-31T07:57:00Z |
| 1006 | docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006 | 4 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1043 | 52d818c3fc93288e1133f7d36fe76857f3c879a4 | 2026-10-31T07:59:00Z | 2026-10-31T10:15:34Z | 2026-10-31T10:17:00Z |
| 1012 | docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012 | 5 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1044 | c7b2850fda58ef2c80624952e582738b76a546f4 | 2026-10-31T10:19:00Z | 2026-10-31T12:45:46Z | 2026-10-31T12:46:00Z |
| 1002 | docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002 | 6 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1045 | 8d9d50f6ceec6ea018f0469d147ca5a379b21fec | 2026-10-31T12:47:00Z | 2026-10-31T14:17:56Z | 2026-10-31T14:19:00Z |
| 1003 | docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003 | 6 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1046 | 1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6 | 2026-10-31T12:51:00Z | 2026-10-31T14:20:06Z | 2026-10-31T14:21:00Z |
| 1013 | docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013 | 7 | merged | worktree_removed | https://github.com/drmoisan/drm-copilot/pull/1052 | 58b81ca577943cd2944b62ee23ff3a3d1d737092 | 2026-10-31T14:22:00Z | 2026-10-31T19:13:33Z | 2026-10-31T19:15:00Z |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 1009 |
| 1 | 0 | 1010 |
| 2 | 0 | 1011 |
| 3 | 0 | 1001 |
| 4 | 0 | 1006 |
| 5 | 0 | 1012 |
| 6 | 0 | 1002, 1003 |
| 7 | 0 | 1013 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |
| 1001 | 1002 | path_overlap |
| 1001 | 1003 | path_overlap |
| 1001 | 1006 | path_overlap |
| 1001 | 1009 | path_overlap |
| 1001 | 1010 | path_overlap |
| 1001 | 1011 | path_overlap |
| 1001 | 1012 | path_overlap |
| 1001 | 1013 | path_overlap |
| 1002 | 1006 | path_overlap |
| 1002 | 1009 | path_overlap |
| 1002 | 1010 | path_overlap |
| 1002 | 1012 | path_overlap |
| 1002 | 1013 | path_overlap |
| 1003 | 1006 | path_overlap |
| 1003 | 1009 | path_overlap |
| 1003 | 1010 | path_overlap |
| 1003 | 1012 | path_overlap |
| 1003 | 1013 | path_overlap |
| 1006 | 1009 | path_overlap |
| 1006 | 1010 | path_overlap |
| 1006 | 1011 | path_overlap |
| 1006 | 1012 | path_overlap |
| 1006 | 1013 | path_overlap |
| 1009 | 1010 | path_overlap |
| 1009 | 1011 | path_overlap |
| 1009 | 1012 | path_overlap |
| 1009 | 1013 | path_overlap |
| 1010 | 1011 | path_overlap |
| 1010 | 1012 | path_overlap |
| 1010 | 1013 | path_overlap |
| 1011 | 1012 | path_overlap |
| 1011 | 1013 | path_overlap |
| 1012 | 1013 | path_overlap |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |
| close | null | null | null | null | 0 | 2026-10-31T21-58 |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |

## Mergeable Conflicts Resolved

| issue_num | path | resolved_at | merged_against | merge_commit_sha | entries_added_from_ours | entries_added_from_theirs | version_resolutions |
| --- | --- | --- | --- | --- | --- | --- | --- |
