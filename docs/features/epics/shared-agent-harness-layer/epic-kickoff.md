# Epic Kickoff: shared-agent-harness-layer

Planned by epic-planner on 2026-10-30, refreshed on 2026-11-14 and completed on 2026-11-15 (UTC). All child features are prepared: issues promoted or adopted, active folders created, research complete, spec/user-story written, atomic plans approved, preflight ALL CLEAR. Epic issue: #1018. Planning state: artifacts/orchestration/epic-planner-state.json (branch: epic/shared-agent-harness-layer-integration).

**Readiness status: READY.** `next_step` is `EPIC_EXECUTION_READY`.

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

## Preflight Status

Every plan is PREFLIGHT: ALL CLEAR:

- #1025: plan.2026-10-30T17-06.md (plan A) and owner-decision-plan.md (plan B).
- #1035: plan.2026-10-30T17-11.md.
- #1028: plan.2026-10-30T18-30.md.
- #1029: plan.2026-10-30T18-37.md.
- #1030: plan.2026-10-30T18-37.md.
- #1032: plan.2026-10-30T18-39.md, plan-h3-sync-writer-retirement.md, plan-agents-branch-a.md, plan-agents-branch-b.md.
- #1049: plan.2026-10-31T14-03.md.
- #1050: plan.2026-11-14T09-31.md.
- #1051: plan.2026-11-14T10-43.md.
- #1016: plan.2026-10-30T18-59.md (stage A) and plan.2026-10-30T23-35.md (stage B).

The plan-path column names each child's first plan; additional plans are listed above and in
the planning checkpoint `additional_plan_paths`.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 1025 | docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025 | 0 | C4 | docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md |
| 1035 | docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035 | 0 | C3 | docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/plan.2026-10-30T17-11.md |
| 1028 | docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028 | 1 | C3 | docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md |
| 1029 | docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029 | 2 | C3 | docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md |
| 1030 | docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030 | 2 | C3 | docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md |
| 1032 | docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032 | 3 | C3 | docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan.2026-10-30T18-39.md |
| 1049 | docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049 | 3 | C3 | docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/plan.2026-10-31T14-03.md |
| 1050 | docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050 | 4 | C3 | docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/plan.2026-11-14T09-31.md |
| 1051 | docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051 | 5 | C3 | docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/plan.2026-11-14T10-43.md |
| 1016 | docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016 | 6 | C3 | docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md |
