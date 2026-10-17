Timestamp: 2026-09-28T20-03
Command: npm run format:check --prefix .
EXIT_CODE: 2
Output Summary: (last 25 lines of output below)
```text
[[33mwarn[39m] tests/fixtures/parallel_cohorts/cohorts_star_graph.json
[[33mwarn[39m] tests/fixtures/parallel_cohorts/cohorts_tie_breaking_equal_degrees.json
[[33mwarn[39m] tests/fixtures/parallel_cohorts/cohorts_two_paths.json
[[33mwarn[39m] tests/fixtures/parallel_cohorts/cohorts_zero_key.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m1_empty_frontmatter.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m1_non_mapping_frontmatter.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m2_empty_parallel.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m2_missing_parallel.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m6_item_not_an_object.json
[[33mwarn[39m] tests/fixtures/parallel_manifest_bash/manifest_m6_items_not_a_list.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/model-routing/item-own-no-receipt/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/model-routing/item-own-receipt/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/model-routing/item-stale-receipt/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/model-routing/session-root/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_body_1.receipt.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/orchestration/orchestrator-state.json
[[33mwarn[39m] tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/pr_body_1.receipt.json
[[31merror[39m] tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json: SyntaxError: Unexpected keyword 'this'. (1:3)
[[31merror[39m] > 1 | { this is not valid json
[[31merror[39m]     |   ^
[[31merror[39m]   2 |
Error occurred when checking code style in the above file.
```

Reported file list (complete, ANSI stripped, sorted; pre-existing baseline):
```text
[error]     |   ^
[error]   2 |
[error] > 1 | { this is not valid json
[error] tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json: SyntaxError: Unexpected keyword 'this'. (1:3)
[warn] tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json
[warn] tests/fixtures/blast_radius/derivation-artifacts-segment-removed.json
[warn] tests/fixtures/blast_radius/derivation-cross-corpus-doc-glob-rejected.json
[warn] tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json
[warn] tests/fixtures/blast_radius/derivation-letterless-contract-rejected.json
[warn] tests/fixtures/blast_radius/derivation-mandate-read-excluded.json
[warn] tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json
[warn] tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json
[warn] tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
[warn] tests/fixtures/blast_radius/historical-runs/epic-655-followups.json
[warn] tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json
[warn] tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
[warn] tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json
[warn] tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json
[warn] tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json
[warn] tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json
[warn] tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json
[warn] tests/fixtures/blast_radius/validation-mandate-read-self-consistent.json
[warn] tests/fixtures/blast_radius/validation-placeholder-self-consistent.json
[warn] tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json
[warn] tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json
[warn] tests/fixtures/blast_radius/write-intent/write-intent-read-task.json
[warn] tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json
[warn] tests/fixtures/codex_routing/deployment.json
[warn] tests/fixtures/codex_routing/topology.json
[warn] tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json
[warn] tests/fixtures/orchestration-handoff/contract/invalid-contract-cases.json
[warn] tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json
[warn] tests/fixtures/orchestration-handoff/contract/valid-parallel-codex-to-claude.json
[warn] tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/source-checkpoint.json
[warn] tests/fixtures/parallel_cohorts/batches_cap_exceeds_cohort_size.json
[warn] tests/fixtures/parallel_cohorts/batches_error_negative_concurrency.json
[warn] tests/fixtures/parallel_cohorts/batches_error_zero_concurrency.json
[warn] tests/fixtures/parallel_cohorts/batches_exact_multiple.json
[warn] tests/fixtures/parallel_cohorts/batches_negative_keys.json
[warn] tests/fixtures/parallel_cohorts/batches_single_slot.json
[warn] tests/fixtures/parallel_cohorts/batches_unsorted_input_is_sorted.json
[warn] tests/fixtures/parallel_cohorts/batches_with_remainder.json
[warn] tests/fixtures/parallel_cohorts/cohorts_disjoint_items.json
[warn] tests/fixtures/parallel_cohorts/cohorts_duplicate_and_reversed_edges.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_duplicate_key.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_duplicate_negative_key.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_self_loop.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_self_loop_precedes_unknown_endpoint.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_unknown_endpoint_negative.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_unknown_first_endpoint.json
[warn] tests/fixtures/parallel_cohorts/cohorts_error_unknown_second_endpoint.json
[warn] tests/fixtures/parallel_cohorts/cohorts_fully_connected_triangle.json
[warn] tests/fixtures/parallel_cohorts/cohorts_isolated_plus_clique.json
[warn] tests/fixtures/parallel_cohorts/cohorts_mergeable_only_overlaps.json
[warn] tests/fixtures/parallel_cohorts/cohorts_negative_keys.json
[warn] tests/fixtures/parallel_cohorts/cohorts_path_of_three.json
[warn] tests/fixtures/parallel_cohorts/cohorts_permuted_input_equivalent.json
[warn] tests/fixtures/parallel_cohorts/cohorts_single_item.json
[warn] tests/fixtures/parallel_cohorts/cohorts_square_cycle.json
[warn] tests/fixtures/parallel_cohorts/cohorts_star_graph.json
[warn] tests/fixtures/parallel_cohorts/cohorts_tie_breaking_equal_degrees.json
[warn] tests/fixtures/parallel_cohorts/cohorts_two_paths.json
[warn] tests/fixtures/parallel_cohorts/cohorts_zero_key.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m1_empty_frontmatter.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m1_non_mapping_frontmatter.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m2_empty_parallel.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m2_missing_parallel.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m6_item_not_an_object.json
[warn] tests/fixtures/parallel_manifest_bash/manifest_m6_items_not_a_list.json
[warn] tests/fixtures/worktree-resolution/model-routing/item-own-no-receipt/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/model-routing/item-own-receipt/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/model-routing/item-stale-receipt/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/model-routing/session-root/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_body_1.receipt.json
[warn] tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/orchestration/orchestrator-state.json
[warn] tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/pr_body_1.receipt.json
```
Note: EXIT_CODE 2 arises from Prettier syntax error on intentionally invalid fixture tests/fixtures/worktree-resolution/shared/item-own-invalid-json/... plus [warn] style findings on fixtures; recorded as pre-existing.
