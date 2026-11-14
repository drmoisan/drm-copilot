# Epic Kickoff: shared-agent-harness-layer

Planned by epic-planner, refreshed on 2026-11-14T20-58 (UTC). Epic issue: #1018. Integration
branch: epic/shared-agent-harness-layer-integration. Planning state:
artifacts/orchestration/epic-planner-state.json (epic-planner worktree of that branch).

**Readiness status: NOT YET READY.** Every child has an issue, an active folder, research, spec,
user story and a plan that passes the plan validator. Seven plans are halted at the one-revision
preflight limit. Each needs an owner-recorded `extra_planner_revision` directive, one planner
revision and one confirming preflight before this prompt is replayed. See the Feature Summary and
`resume-note.md`. Do not replay the invocation prompt until the epic planner has set `next_step`
to `EPIC_EXECUTION_READY`.

## Invocation Prompt

Run `/epic-run shared-agent-harness-layer` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/shared-agent-harness-layer/epic.md. Epic issue: #1018 (epic_issue_num 1018).
The integration branch epic/shared-agent-harness-layer-integration already contains every
prepared feature folder and approved atomic plan; child features resume at atomic execution from
their committed plan-path rather than re-planning. Execute per the epic-orchestrate skill:
wave-scheduled child orchestrator runs in isolated worktrees, merge-on-green fan-in to the
integration branch, and the final integration-to-main PR. Child plans with an owner stop between
plans (#1025 plan A then plan B; #1016 stage A then stage B; #1032 main plan, then the H3 plan,
then branch A or B per #1025's verification result) run in that order.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path | preflight |
| --- | --- | --- | --- | --- | --- |
| 1025 | 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025 | 0 | C4 | plan.2026-10-30T17-06.md (plan A); owner-decision-plan.md (plan B) | plan A halted; plan B ALL CLEAR |
| 1035 | 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035 | 0 | C3 | plan.2026-10-30T17-11.md | halted |
| 1028 | 2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028 | 1 | C3 | plan.2026-10-30T18-30.md | halted |
| 1029 | 2026-10-30-push-down-consolidation-and-ecosystem-packs-1029 | 2 | C3 | plan.2026-10-30T18-37.md | halted |
| 1030 | 2026-10-30-hook-parity-across-claude-codex-copilot-1030 | 2 | C3 | plan.2026-10-30T18-37.md | ALL CLEAR |
| 1032 | 2026-10-30-retire-github-skills-and-thin-copilot-layer-1032 | 3 | C3 | plan.2026-10-30T18-39.md; plan-h3-sync-writer-retirement.md; plan-agents-branch-a.md; plan-agents-branch-b.md | ALL CLEAR (all four) |
| 1049 | 2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049 | 3 | C3 | plan.2026-10-31T14-03.md | halted |
| 1050 | 2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050 | 4 | C3 | plan.2026-11-14T09-31.md | halted |
| 1051 | 2026-10-31-push-down-integration-mcp-tools-and-skill-1051 | 5 | C3 | plan.2026-11-14T10-43.md | ALL CLEAR |
| 1016 | 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016 | 6 | C3 | plan.2026-10-30T18-59.md (stage A); plan.2026-10-30T23-35.md (stage B) | stage A ALL CLEAR; stage B halted |

All plan paths are relative to `docs/features/active/<feature_folder>/`.
