# Epic Kickoff: documentation-estate-tooling

Planned by epic-planner on 2026-10-31. All child features are prepared: issues promoted, active
folders created, research complete, spec/user-story written, atomic plans approved, preflight
ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json (branch:
epic/documentation-estate-tooling-integration). Epic issue: #1019.

## Invocation Prompt

Run `/epic-run documentation-estate-tooling` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/documentation-estate-tooling/epic.md. The integration branch
epic/documentation-estate-tooling-integration already contains every prepared feature folder and
approved atomic plan; child features resume at atomic execution from their committed plan-path
rather than re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator
runs in isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR. epic_issue_num: 1019.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 1020 | docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020 | 0 | C3 | docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/plan.2026-10-30T16-08.md |
| 1021 | docs/features/active/2026-10-30-docs-page-quality-checker-1021 | 1 | C3 | docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md |
| 1022 | docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022 | 1 | C4 | docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md |
| 1023 | docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023 | 1 | C4 | docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md |
| 1033 | docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033 | 1 | C4 | docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md |
| 1024 | docs/features/active/2026-10-30-docs-reference-generator-1024 | 2 | C3 | docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md |
| 1031 | docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031 | 2 | C3 | docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md |
| 1034 | docs/features/active/2026-10-30-docs-enforcement-and-ci-1034 | 2 | C3 | docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md |
| 1036 | docs/features/active/2026-10-30-docs-mcp-tools-1036 | 3 | C3 | docs/features/active/2026-10-30-docs-mcp-tools-1036/plan.2026-10-30T18-58.md |
| 1037 | docs/features/active/2026-10-30-docs-authoring-workflow-1037 | 4 | C4 | docs/features/active/2026-10-30-docs-authoring-workflow-1037/plan.2026-10-30T18-59.md |
| 1038 | docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038 | 5 | C3 | docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/plan.2026-10-30T18-59.md |

## Execution Notes

- Every child plan's Phase 0 verifies that its upstream code is on the integration branch and
  records BLOCKED otherwise; wave order must be respected.
- Execute each child in its item worktree under an exempt-route checkpoint (batch budget), not in
  an isolated executor worktree.
- 1031 needs a full `poetry install` in its item worktree before Phase 0.
- Execution-time checks recorded in epic.md: 1034 hook module visibility; 1031 digest
  recomputation against 1022's whole-file `architecture-component` digest.
- Owner questions Q4, Q6-Q15 and per-child open questions remain on their provisional defaults.
