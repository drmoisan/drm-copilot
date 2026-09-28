# Parallel Kickoff: followups-2026-09-27

Planned by parallel-planner on 2026-09-27T02:05:00Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/followups-2026-09-27-plan).

## Invocation Prompt

Run `/parallel-run followups-2026-09-27` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/followups-2026-09-27/parallel.md on the plan-home branch parallel/followups-2026-09-27-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 706 | docs/features/active/cleanup-report-registration-lost-false-positive-706 | 6 | C3 | bug/cleanup-report-registration-lost-false-positive-706 | docs/features/active/cleanup-report-registration-lost-false-positive-706/plan.2026-09-26T22-56.md |
| 707 | docs/features/active/codex-gates-4-5-lack-epic-scope-707 | 3 | C3 | bug/codex-gates-4-5-lack-epic-scope-707 | docs/features/active/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md |
| 708 | docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708 | 4 | C3 | bug/completion-consistency-edit-reads-relative-checkpoint-708 | docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/plan.2026-09-26T22-56.md |
| 709 | docs/features/active/gate-suites-read-unmocked-local-epic-state-709 | 6 | C3 | bug/gate-suites-read-unmocked-local-epic-state-709 | docs/features/active/gate-suites-read-unmocked-local-epic-state-709/plan.2026-09-26T22-55.md |
| 710 | docs/features/active/preimplementation-helpers-backslash-chain-operator-710 | 0 | C3 | bug/preimplementation-helpers-backslash-chain-operator-710 | docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md |
| 711 | docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711 | 7 | C2 | bug/remaining-cannot-fail-count-assertions-711 | docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/plan.2026-09-26T22-56.md |
| 712 | docs/features/active/unused-npm-token-secret-712 | 5 | C3 | bug/unused-npm-token-secret-712 | docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md |
| 713 | docs/features/active/preimplementation-gate-blocks-attribution-trailers-713 | 1 | C3 | bug/preimplementation-gate-blocks-attribution-trailers-713 | docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md |
| 714 | docs/features/active/collector-core-no-whichgh-branch-untested-714 | 3 | C2 | bug/collector-core-no-whichgh-branch-untested-714 | docs/features/active/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md |
| 715 | docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715 | 7 | C2 | bug/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715 | docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md |
| 716 | docs/features/active/compare-code-point-helper-duplicated-716 | 2 | C2 | bug/compare-code-point-helper-duplicated-716 | docs/features/active/compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md |

## Integrity

planning_commit: 7e58115e7f92b69bf5e7fc6600e0a09837dd4498

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/cleanup-report-registration-lost-false-positive-706/plan.2026-09-26T22-56.md | 67d80953c8ca61bde5cd61710387cd4c699a8f06 |
| docs/features/active/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md | df1aa717ab2af8ae0240508a595478cc7e548e7b |
| docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/plan.2026-09-26T22-56.md | 4951fe3ad22787ff2e5472962a56b7bac28b8ba4 |
| docs/features/active/gate-suites-read-unmocked-local-epic-state-709/plan.2026-09-26T22-55.md | a44ad837b8f32c949efe91d081717f6e1c76fcc2 |
| docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md | 1af4ccc2319399652305e5c2d0a1a56a40772459 |
| docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/plan.2026-09-26T22-56.md | 37e07e13a7536e676f06c579e203b63a70e54ee7 |
| docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md | c5ed64cf94611f441a6a35591949649e5c171c0f |
| docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md | 4f3f6598def407ced00923d7909a4782e07b4c9a |
| docs/features/active/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md | 59db4c37c47bf3a9d73ea59f769d42fd7ab3f742 |
| docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md | bc31754e953b528289ad18a86e3f2903e3e315ec |
| docs/features/active/compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md | 87d62e162d657c547a0180cb9bf46550f713db47 |
