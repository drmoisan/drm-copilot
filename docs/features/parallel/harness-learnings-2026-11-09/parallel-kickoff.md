# Parallel Kickoff: harness-learnings-2026-11-09

Planned by parallel-planner on 2026-11-10T03:01:47Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/harness-learnings-2026-11-09-plan).

## Invocation Prompt

Run `/parallel-run harness-learnings-2026-11-09` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/harness-learnings-2026-11-09/parallel.md on the plan-home branch parallel/harness-learnings-2026-11-09-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

Scheduling note: the conflict edges and tolerated overlaps were derived under the run-level conflict tolerance of owner directive OD-1 (tolerance_percent 21625; the committed config/blast-radius.json keeps 100). Reuse the recorded edges in docs/features/parallel/harness-learnings-2026-11-09/parallel-scheduling.json; do not recompute them from the committed truth table.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 1156 | docs/features/active/regenerate-after-integration-merge-1156 | 1 | C3 | feature/regenerate-after-integration-merge-1156 | docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md |
| 1157 | docs/features/active/owner-directive-pass-down-1157 | 1 | C3 | feature/owner-directive-pass-down-1157 | docs/features/active/owner-directive-pass-down-1157/plan.2026-11-09T16-32.md |
| 1158 | docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158 | 2 | C3 | feature/test-execution-policy-machine-lock-1158 | docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md |
| 1159 | docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159 | 0 | C3 | feature/hook-dispatcher-process-cost-1159 | docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/plan.2026-11-09T16-31.md |
| 1160 | docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160 | 0 | C3 | bug/preimplementation-gate-false-positives-1160 | docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md |
| 1161 | docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161 | 3 | C3 | feature/planner-worktree-removal-authorization-1161 | docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/plan.2026-11-09T16-33.md |
| 1162 | docs/features/active/2026-11-09-cross-epic-dependencies-1162 | 4 | C3 | feature/cross-epic-dependencies-1162 | docs/features/active/2026-11-09-cross-epic-dependencies-1162/plan.2026-11-09T16-32.md |
| 1163 | docs/features/active/2026-11-09-hook-session-root-resolution-1163 | 5 | C3 | bug/hook-session-root-resolution-1163 | docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md |

## Integrity

planning_commit: 1fd2af52a2a53e22e600b6e915799a88ff584298

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md | 46dddd7d448ca703ba018f76217b5356d724d5f8 |
| docs/features/active/owner-directive-pass-down-1157/plan.2026-11-09T16-32.md | 3d3d5834920cc1f077bd48e2fb8a49aa42b09ff3 |
| docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md | 75c96cbef40da404dd0535d98884dd34060ba65f |
| docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/plan.2026-11-09T16-31.md | b27d8347091f2405d953b226d136c0e5f4cf2319 |
| docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md | 67c60ee34c491ed4220b8e0620700669ef85d749 |
| docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/plan.2026-11-09T16-33.md | 9128f972a2f7b927f271e716013971f608997a71 |
| docs/features/active/2026-11-09-cross-epic-dependencies-1162/plan.2026-11-09T16-32.md | 92c7743114cc2a1524ba8e4902cc7e412ad3eac9 |
| docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md | 8bbc206395381eed6cf26cabdffbfbb06fac645e |
