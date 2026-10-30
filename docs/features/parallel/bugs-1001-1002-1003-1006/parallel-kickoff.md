# Parallel Kickoff: bugs-1001-1002-1003-1006

Planned by parallel-planner on 2026-10-30T14:37:34Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/bugs-1001-1002-1003-1006-plan).

## Invocation Prompt

Run `/parallel-run bugs-1001-1002-1003-1006` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/bugs-1001-1002-1003-1006/parallel.md on the plan-home branch parallel/bugs-1001-1002-1003-1006-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

Execution notes: items 1010, 1011 and 1013 carry Phase 0 dependency gates. 1010 requires the 1009 resolver module on origin/main; 1011 requires the 1009 resolver and the 1010 gate change; 1013 requires the 1006 scheduling-rule change. The derived cohort order already places each prerequisite in an earlier cohort. Items 1006, 1009, 1010 and 1013 exceed the three-file direct-mode batch budget and must execute on the large route.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 1001 | docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001 | 0 | C3 | bug/merge-gate-epic-mode-string-false-1001 | docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/plan.2026-10-30T06-58.md |
| 1006 | docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006 | 1 | C3 | bug/parallel-scheduling-false-hard-edges-1006 | docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/plan.2026-10-30T06-58.md |
| 1009 | docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009 | 2 | C3 | bug/batch-budget-hooks-coordinator-root-1009 | docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/plan.2026-10-30T08-09.md |
| 1010 | docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010 | 3 | C3 | bug/preimplementation-gate-item-worktree-1010 | docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/plan.2026-10-30T08-09.md |
| 1012 | docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012 | 4 | C3 | bug/completion-stop-hook-rejected-mutation-1012 | docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/plan.2026-10-30T08-10.md |
| 1013 | docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013 | 5 | C3 | feature/parallel-scheduling-integration-cost-1013 | docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md |
| 1002 | docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002 | 6 | C2 | bug/parallel-planner-leaves-scratch-worktrees-1002 | docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/plan.2026-10-30T06-59.md |
| 1003 | docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003 | 6 | C3 | bug/new-claude-worktree-session-commands-concatenated-1003 | docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/plan.2026-10-30T06-59.md |
| 1011 | docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011 | 6 | C3 | bug/pr-author-session-not-rooted-1011 | docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/plan.2026-10-30T08-09.md |

## Integrity

planning_commit: 92e82fe4754495eb974378941db340ed5a12280f

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/plan.2026-10-30T06-58.md | cc48a44b7762457b31195ba20b298523bb16f942 |
| docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/plan.2026-10-30T06-58.md | 560bce4ad88e8b8fe8f1d0af1dcffe7d1e18ecfb |
| docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/plan.2026-10-30T08-09.md | 33641c78f49631152d2fec2464a31b296a69c167 |
| docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/plan.2026-10-30T08-09.md | 066809a5efb3dc0dd20da512e1d30d08a32833d8 |
| docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/plan.2026-10-30T08-10.md | 1be5d9ac4b9435c2d3251d0c49916ed98abd902b |
| docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md | 8d935130c3c07d8def246ea8d252c8f4a97a8dfd |
| docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/plan.2026-10-30T06-59.md | f8d7e7e1e0254c986fe34e927dec25612afa8466 |
| docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/plan.2026-10-30T06-59.md | f15a9eb5b9cea08c1dfa3be16d6758458f8e0b36 |
| docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/plan.2026-10-30T08-09.md | adbd7d3334b4f3177c77f74516ba13e2b16841bd |
