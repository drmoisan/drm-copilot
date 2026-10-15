# Parallel Kickoff: bug-burndown-2026-10-08

Planned by parallel-planner on 2026-10-09T06:40:55Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/bug-burndown-2026-10-08-plan).

## Invocation Prompt

Run `/parallel-run bug-burndown-2026-10-08` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/bug-burndown-2026-10-08/parallel.md on the plan-home branch parallel/bug-burndown-2026-10-08-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 794 | docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794 | 0 | C2 | bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 | docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/plan.2026-10-08T17-25.md |
| 797 | docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797 | 0 | C3 | bug/blast-radius-path-extractor-misses-real-plan-writes-797 | docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md |
| 798 | docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798 | 0 | C3 | bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798 | docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md |
| 844 | docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844 | 0 | C3 | bug/handoff-failure-cause-fallback-and-name-gaps-844 | docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/plan.2026-10-08T23-42.md |
| 847 | docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847 | 0 | C3 | bug/powershell-aggregate-line-coverage-below-floor-847 | docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md |
| 848 | docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848 | 0 | C2 | bug/root-format-check-fails-on-test-fixtures-848 | docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/plan.2026-10-09T01-32.md |
| 793 | docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793 | 1 | C2 | bug/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793 | docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md |
| 824 | docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824 | 1 | C3 | bug/issue-823-tier-rule-adoption-follow-ups-824 | docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md |
| 843 | docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843 | 1 | C3 | bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843 | docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/plan.2026-10-08T22-17.md |
| 845 | docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845 | 1 | C3 | bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845 | docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/plan.2026-10-08T23-42.md |
| 846 | docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846 | 1 | C3 | bug/bug-burndown-2026-09-29-review-nits-846 | docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md |
| 796 | docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796 | 2 | C3 | bug/duplicated-string-comparators-outside-pr-context-796 | docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/plan.2026-10-08T17-25.md |
| 841 | docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841 | 2 | C3 | bug/ci-gate-vacuous-on-empty-check-list-841 | docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md |
| 543 | docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543 | 3 | C3 | bug/epic-planner-topology-receipt-gate-543 | docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md |
| 791 | docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791 | 3 | C3 | bug/issue-763-parallel-skill-cli-port-follow-ups-791 | docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md |
| 790 | docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790 | 4 | C3 | bug/issue-507-python-push-down-divergence-follow-ups-790 | docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md |
| 849 | docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849 | 4 | C3 | bug/parallel-items-fail-completion-on-promotion-receipts-849 | docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md |
| 842 | docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842 | 5 | C2 | bug/cleanup-worktrees-scan-root-derivation-follow-ups-842 | docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md |

## Integrity

planning_commit: c0f168cf6c70a621ab807cc6e28f063e14887e45

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/plan.2026-10-08T17-25.md | f51365bc18e4f2a66eaaf29b1eee084735d1ffcc |
| docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md | 1d50b1f7699b21291bbf9f7e40f4ef98de4466bd |
| docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md | f917ef2acf16b453e805e80150f34716f26adc55 |
| docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/plan.2026-10-08T23-42.md | 0c6370720044a5223c13e5558c3d8e662599f822 |
| docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md | d4bcb86c1d199d927e30ee28ff4d83187e4327c9 |
| docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/plan.2026-10-09T01-32.md | ea8d37e1636b623b6b6b6a6c254a402cfa616f57 |
| docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md | bb81f59456ce72b5b90ee18c19018d819699d6ad |
| docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md | cfdabf0d45db0bebfb07d61194a77baae3b93b3c |
| docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/plan.2026-10-08T22-17.md | 0dced377a92ce2128d13a359ab8267f67e4d6720 |
| docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/plan.2026-10-08T23-42.md | 6936a8990b3ac5f3b7c80954914318af11ab1cca |
| docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md | 01cd5b314bfaca1fced7766f287d4512ed5c942e |
| docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/plan.2026-10-08T17-25.md | 72f5ce3ec9e64669f0640121d642953c62f807c0 |
| docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md | fec7acc7da817e0cdbb6019200eb212f6ad4ff15 |
| docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md | 19baa0f500b41df0ccc8c416158016dfd3a50fd6 |
| docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md | d3e374feb20c2741a8141251d477c8247ec64dd7 |
| docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md | 1adf48e90d9cab115b7f261a0c39cc43a74a9478 |
| docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md | 7622ed324e9054b8fb112f8b174050df6a59c76f |
| docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md | ddca64c6dde2240390afdd50c36100ca36b292dd |
