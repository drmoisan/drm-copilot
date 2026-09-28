# Parallel Kickoff: critical-bug-fixes

Planned by parallel-planner on 2026-08-24T14-20. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/critical-bug-fixes-plan).

## Invocation Prompt

Run `/parallel-run critical-bug-fixes` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/critical-bug-fixes/parallel.md on the plan-home branch parallel/critical-bug-fixes-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 505 | docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505 | 3 | C3 | bug/fix-all-json-cancel-thread-race-505 | docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md |
| 506 | docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506 | 4 | C3 | bug/ci-coverage-targets-nonexistent-package-506-r2 | docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md |
| 515 | docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515 | 0 | C3 | bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515 | docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md |
| 516 | docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516 | 1 | C3 | bug/preimplementation-gate-rejects-absolute-checkpoint-path-516 | docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md |
| 518 | docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518 | 5 | C3 | bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518 | docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md |
| 519 | docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519 | 6 | C3 | bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519 | docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md |
| 524 | docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524 | 2 | C3 | bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524 | docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md |
| 525 | docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525 | 3 | C3 | bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525 | docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md |
| 526 | docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526 | 5 | C3 | bug/tag-push-can-silently-skip-npm-publish-526 | docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md |

## Integrity

planning_commit: f53d472db7456fb254ba3876936e827f988adbc9

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md | 603a141eb514e286ed2799de13c9e9fbb660ac0a |
| docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md | 63cd08b0cebc1f0295d2fec9d0404e89df311c8d |
| docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md | 40a9fa6baa9d61c6d999a9961f5dd904cc91f920 |
| docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md | e505ce409d085bb19556b38a6069d3218c37707a |
| docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md | 5316b2f09242e611354d86336bf578bac672bf13 |
| docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md | 2db07e3c5b3e169533e6af7f43575219290c77c4 |
| docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md | fbd08011d0b48fd58cb04e434c4eb628b3a0a1c9 |
| docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md | 8ec750614e186a77f32da46c0622c996a9254e36 |
| docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md | 80528952378de8fc394bffaaa33bc06b2b328bca |
