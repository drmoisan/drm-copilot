<!--
  GENERATED FILE - DO NOT HAND-AUTHOR.
  Generated projection of artifacts/orchestration/parallel-orchestrator-state.json, regenerated in
  full by parallel-orchestrator at each documentation-maintenance boundary. The manifest and the
  checkpoint are authoritative; this file is never the source of the cohort table or the schedule.
-->

# bug-burndown-2026-10-08 - Parallel Run Status (generated)

This document is regenerated from the parallel-orchestrator checkpoint and must not be
hand-authored. It is a read-only projection: the manifest and the checkpoint are authoritative.

**Header**

- `parallel_slug`: bug-burndown-2026-10-08
- `mode`: closed
- `max_concurrency`: 4
- `current_cohort`: 0
- `recolor_generation`: 0
- `last_updated`: 2026-10-09T23:57:00Z
- `next_step`: await green on 861; monitor 847 848 793

**Items**

| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 794 | docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794 | 0 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/860 | 8754efe64ef2e724fbfcfbc6c32d3f0ea0e53979 | 2026-10-09T06:48:10Z | 2026-10-09T23:46:09Z | - |
| 797 | docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797 | 0 | in_flight | pr_open | https://github.com/drmoisan/drm-copilot/pull/861 | - | 2026-10-09T06:48:10Z | - | - |
| 798 | docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798 | 0 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/862 | 6874389b303dea9f81dc3e7d1bfcfb9fa1e9ee9b | 2026-10-09T06:48:10Z | 2026-10-09T23:56:20Z | - |
| 844 | docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844 | 0 | merged | merged | https://github.com/drmoisan/drm-copilot/pull/859 | 460cd755de560b733be0c471d1d144e553fbe0e5 | 2026-10-09T06:48:10Z | 2026-10-09T23:33:41Z | - |
| 847 | docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847 | 0 | in_flight | worktree_created | - | - | 2026-10-09T23:34:11Z | - | - |
| 848 | docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848 | 0 | in_flight | worktree_created | - | - | 2026-10-09T23:46:27Z | - | - |
| 793 | docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793 | 1 | in_flight | worktree_created | - | - | 2026-10-09T23:56:38Z | - | - |
| 824 | docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824 | 1 | prepared | not_started | - | - | - | - | - |
| 843 | docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843 | 1 | prepared | not_started | - | - | - | - | - |
| 845 | docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845 | 1 | prepared | not_started | - | - | - | - | - |
| 846 | docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846 | 1 | prepared | not_started | - | - | - | - | - |
| 796 | docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796 | 2 | prepared | not_started | - | - | - | - | - |
| 841 | docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841 | 2 | prepared | not_started | - | - | - | - | - |
| 543 | docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543 | 3 | prepared | not_started | - | - | - | - | - |
| 791 | docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791 | 3 | prepared | not_started | - | - | - | - | - |
| 790 | docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790 | 4 | prepared | not_started | - | - | - | - | - |
| 849 | docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849 | 4 | prepared | not_started | - | - | - | - | - |
| 842 | docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842 | 5 | prepared | not_started | - | - | - | - | - |

**Cohorts**

| index | generation | item_keys |
| --- | --- | --- |
| 0 | 0 | 794, 797, 798, 844, 847, 848 |
| 1 | 0 | 793, 824, 843, 845, 846 |
| 2 | 0 | 796, 841 |
| 3 | 0 | 543, 791 |
| 4 | 0 | 790, 849 |
| 5 | 0 | 842 |

## Conflict Edges

| a | b | reason |
| --- | --- | --- |
| 543 | 790 | path_overlap |
| 543 | 796 | path_overlap |
| 543 | 798 | path_overlap |
| 543 | 824 | path_overlap |
| 543 | 841 | path_overlap |
| 543 | 842 | path_overlap |
| 543 | 843 | path_overlap |
| 543 | 844 | path_overlap |
| 790 | 796 | path_overlap |
| 790 | 798 | path_overlap |
| 790 | 824 | path_overlap |
| 790 | 841 | path_overlap |
| 790 | 842 | path_overlap |
| 790 | 844 | path_overlap |
| 791 | 794 | path_overlap |
| 791 | 798 | path_overlap |
| 791 | 824 | path_overlap |
| 791 | 841 | path_overlap |
| 791 | 842 | path_overlap |
| 791 | 843 | path_overlap |
| 791 | 849 | path_overlap |
| 793 | 796 | path_overlap |
| 793 | 798 | path_overlap |
| 793 | 844 | path_overlap |
| 794 | 824 | path_overlap |
| 794 | 842 | path_overlap |
| 796 | 843 | path_overlap |
| 796 | 844 | path_overlap |
| 797 | 845 | path_overlap |
| 798 | 824 | path_overlap |
| 798 | 841 | path_overlap |
| 798 | 842 | path_overlap |
| 798 | 843 | path_overlap |
| 798 | 846 | path_overlap |
| 798 | 849 | path_overlap |
| 824 | 841 | path_overlap |
| 824 | 842 | path_overlap |
| 824 | 844 | path_overlap |
| 824 | 847 | path_overlap |
| 824 | 849 | path_overlap |
| 841 | 842 | path_overlap |
| 841 | 843 | path_overlap |
| 841 | 846 | path_overlap |
| 841 | 849 | path_overlap |
| 843 | 849 | path_overlap |
| 844 | 846 | path_overlap |
| 847 | 849 | path_overlap |

## Mutations

| op | item_key | prior_state | new_state | disposition | recolor_generation | at |
| --- | --- | --- | --- | --- | --- | --- |

## Drift Events

| item_key | declared | observed | escaped_paths | action | at |
| --- | --- | --- | --- | --- | --- |

## Mergeable Conflicts Resolved

| issue_num | path | resolved_at | merged_against | merge_commit_sha | entries_added_from_ours | entries_added_from_theirs | version_resolutions |
| --- | --- | --- | --- | --- | --- | --- | --- |
