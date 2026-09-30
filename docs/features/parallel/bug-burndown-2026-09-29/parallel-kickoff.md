# Parallel Kickoff: bug-burndown-2026-09-29

Planned by parallel-planner on 2026-09-30T09:26:50Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/bug-burndown-2026-09-29-plan).

## Invocation Prompt

Run `/parallel-run bug-burndown-2026-09-29` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/bug-burndown-2026-09-29/parallel.md on the plan-home branch parallel/bug-burndown-2026-09-29-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 338 | docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338 | 4 | C2 | bug/potential-entry-ide-launcher-audit-gaps-338 | docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/plan.2026-09-29T14-12.md |
| 406 | docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406 | 1 | C2 | bug/potential-to-issue-python-files-oversized-406 | docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/plan.2026-09-29T14-12.md |
| 510 | docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510 | 3 | C2 | bug/claude-resource-parity-enumerates-gitignored-state-510 | docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/plan.2026-09-29T14-11.md |
| 512 | docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512 | 0 | C1 | bug/unauthorized-noqa-e501-in-blast-radius-parity-test-512 | docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/plan.2026-09-29T15-16.md |
| 527 | docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527 | 2 | C3 | bug/poshqc-coverage-denominator-not-reproducible-527 | docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md |
| 532 | docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532 | 2 | C3 | bug/parallel-parent-routes-on-a-band-nothing-produces-532 | docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/plan.2026-09-29T15-46.md |
| 543 | docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543 | 2 | C3 | bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543 | docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md |
| 609 | docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609 | 1 | C2 | bug/bash-lane-assertion-newline-edges-divergence-609 | docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/plan.2026-09-29T18-29.md |
| 623 | docs/features/active/promotion-receipt-destination-unverified-623 | 0 | C3 | bug/promotion-receipt-destination-unverified-623 | docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md |
| 645 | docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645 | 3 | C3 | feature/portable-handoff-614-review-follow-ups-645 | docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/plan.2026-09-29T19-29.md |
| 647 | docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647 | 1 | C3 | bug/test-tree-typecheck-not-gated-647 | docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/plan.2026-09-29T20-10.md |
| 658 | docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658 | 3 | C3 | bug/epic-child-prs-trigger-no-ci-658 | docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/plan.2026-09-29T20-45.md |
| 659 | docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659 | 0 | C3 | bug/epic-wave-barrier-violations-lack-start-guard-659 | docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md |
| 723 | docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723 | 0 | C2 | bug/npm-publish-verify-window-too-short-723 | docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/plan.2026-09-29T21-31.md |
| 734 | docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734 | 1 | C3 | bug/quality-tiers-yml-missing-and-unenforced-734 | docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/plan.2026-09-29T21-45.md |
| 739 | docs/features/active/2026-09-27-npm-token-guard-gaps-739 | 1 | C3 | bug/npm-token-guard-gaps-739 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md |
| 740 | docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740 | 4 | C3 | bug/pr-context-helper-duplication-and-vacuous-tests-740 | docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/plan.2026-09-29T22-17.md |
| 741 | docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741 | 2 | C3 | bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741 | docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md |
| 743 | docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743 | 0 | C3 | bug/ci-gaps-linux-pester-and-kcov-set-u-743 | docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/plan.2026-09-30T03-15.md |
| 744 | docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744 | 1 | C3 | bug/orchestration-completion-gate-and-tooling-friction-744 | docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/plan.2026-09-30T03-18.md |
| 756 | docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756 | 3 | C2 | bug/cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756 | docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/plan.2026-09-30T03-38.md |
| 764 | docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764 | 0 | C2 | bug/feature-review-skill-cites-nonexistent-validator-764 | docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md |

## Integrity

planning_commit: f50d5231b98ddef20e36d83593329287c1914136

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/plan.2026-09-29T14-12.md | f6c93ebc7b1e8ae0b7511b6c50ce8f446f25982a |
| docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/plan.2026-09-29T14-12.md | 383bde791f8aeb52de9c0ceeb5702a0424d7319a |
| docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/plan.2026-09-29T14-11.md | a8d736c0600673693cd1c98c3765b5840995e28d |
| docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/plan.2026-09-29T15-16.md | 154212145022c5f5e4fb015ed14bb5f1d12f2636 |
| docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md | 9476e3e24bbbc08e78b8fe2b2f8f2e71d08a2425 |
| docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/plan.2026-09-29T15-46.md | a6ba945371b6bba656476bd09a319dc48f2aa549 |
| docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md | d7ad6c064ea84199e61caf7bbeccdaf263624bbb |
| docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/plan.2026-09-29T18-29.md | 2c4178d83482c6487601327bd297acf7f0cb02b6 |
| docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md | c9518458dffe9dab10475840ed5ddbfa9d8c3dfc |
| docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/plan.2026-09-29T19-29.md | 8ecc2a7cfc4abb0c14b0a0e0476e7ecf7be7f850 |
| docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/plan.2026-09-29T20-10.md | d0bdef2a8bf228601715ecf536c55e5241f62467 |
| docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/plan.2026-09-29T20-45.md | 04ad9e5386a73d28f7b14e366007f3c43d803fb9 |
| docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md | 154c7d902287a6d1b28deff9c24ad54fce0dea94 |
| docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/plan.2026-09-29T21-31.md | 7db48d68b495c6df81f5725fdc71c0f2566565b9 |
| docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/plan.2026-09-29T21-45.md | 13e768f2130ae6a2e16b248337e8c27f051b7ced |
| docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md | c85ee44a74ff8d3478056b0d54231c683335df56 |
| docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/plan.2026-09-29T22-17.md | dffa905fb103a740e6f863a70f298d4bb51f0e4d |
| docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md | e086407c477243fd31244d66e9b82fce1877ea94 |
| docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/plan.2026-09-30T03-15.md | 7ae72e167977e55944411b3a4ffcff1736b0b41e |
| docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/plan.2026-09-30T03-18.md | 18b80a560c4ca166ac8e35ed3b4203bd473c799a |
| docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/plan.2026-09-30T03-38.md | d0e445723ba30bd85a80d45c17a9f15359064622 |
| docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md | a5ab7734bc97c782f8133cee26b1723188de5a8c |
