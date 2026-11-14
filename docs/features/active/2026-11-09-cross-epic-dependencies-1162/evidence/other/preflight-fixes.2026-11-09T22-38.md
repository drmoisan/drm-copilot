# Preflight Fixes (Round 2, Confirming Pass)

Timestamp: 2026-11-09T22-38
Plan: docs/features/active/2026-11-09-cross-epic-dependencies-1162/plan.2026-11-09T16-32.md
Prior record: docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/other/preflight-fixes.2026-11-09T22-21.md (unchanged)
Validators after fixes: Python CLI `plan` subcommand exit 0; MCP `validate_orchestration_artifacts` ok.

## Fixes

1. Terms and Run Constraints (Language bullet) | wording contradiction | "no new Python file is created" now reads "no new Python production file is created", and names the two P2-T2 test files as the only new Python files. The spec's Files in Scope already lists both test files; the production constraint is unchanged.
2. [P1-T1] | test enumeration aligned with spec AC2.1 | The test list now names the `Get-EpicCrossDependencyPrerequisitePr` cases that spec AC2.1 assigns to `EpicCrossDependency.Tests.ps1`: a file-rule-only match, a token-rule-only match, one PR matching both rules returned as one match, two distinct matches giving `PREREQ_PR_AMBIGUOUS`, and an invalid snapshot giving `PREREQ_SNAPSHOT_INVALID`. The AC and its test file are unchanged.
3. [P2-T1] | corpus detail aligned with spec AC1.4 | Each corpus case now names its checkpoint type, and the malformed shape cases appear for both `epic-orchestrator-state` and `epic-planner-state`, so the shared corpus exercises the planner-checkpoint shape check that AC1.4 requires.
4. [P2-T3] | test detail aligned with spec AC1.4 | The new Jest test now runs each corpus case through the validator of its checkpoint type (`validateEpicOrchestratorStateText` or `validateEpicPlannerStateText`), so the planner call added in `epic-planner-state-core.ts` has a test that fails if it is omitted.
5. [P4-T3] | token instruction for a P4-T4 assertion | The `.codex/agents/epic-planner.toml` bullet now states that the planner-checkpoint copy names `cross_epic_depends_on`, the token P4-T4 asserts in that file.
6. [P0-T1] | satisfiable-condition clarification | The task now commits pending branch changes, including the untracked feature folder, before the merge, so the existing acceptance "`git status --porcelain` is empty after the merge commit" can hold.
7. [P5-T1] | satisfiable-condition clarification | The task now commits the Phase 1 to 4 changes and evidence before the merge, so the existing acceptance "`git status --porcelain` is empty" can hold and the merge does not start from a dirty tree.
