Timestamp: 2026-09-28T20-06
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

Note: EXIT_CODE 2 equals baseline P0-T10 EXIT_CODE 2. Reported file list (79 [warn]/[error] lines, ANSI stripped, sorted) is byte-identical to the baseline list (diff empty). No package.json or package-lock.json path appears in the list. Acceptance met.
