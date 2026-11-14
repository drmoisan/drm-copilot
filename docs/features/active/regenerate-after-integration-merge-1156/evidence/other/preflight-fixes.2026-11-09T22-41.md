# Preflight Fixes — regenerate-after-integration-merge (Issue #1156), round 2

Timestamp: 2026-11-09T22-41
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned separately; the fixes below are task-text edits only, with no task added, removed, or reordered, and no assertion changed)
Prior record: docs/features/active/regenerate-after-integration-merge-1156/evidence/other/preflight-fixes.2026-11-09T22-22.md (not edited)

## Fixes

1. `[P4-T1]` | literal not quoted for a token the plan asserts | [P4-T6] asserts `config/orchestration-regeneration.json`, `idempotency_check`, `no_config`, `config_invalid`, and `regeneration_events[]` in the orchestrate skill, but [P4-T1] did not quote them as literals the task creates. Added one sentence listing every [P4-T6] orchestrate-skill literal. The [P4-T6] assertion is unchanged.
2. `[P4-T5]` | literal not quoted for a token the plan asserts | [P4-T6] asserts `policy-level control` in the rules-file section; [P4-T5] wrote "policy-level-control disclosure", which does not contain that token. The task text now quotes the literal. The [P4-T6] assertion is unchanged.
3. `[P4-T2]` | incomplete existing-test constraint (validator-blind class) | `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` rejects every phrase of `REMOVED_CHILD_ITEM_PHRASES` (not only `features[]`) and counts column-0 lines matching `NUMBERED_STEP_PATTERN` in the lifecycle section. The task text now names both constraints. Disposition (unchanged) is the same.
4. `[P3-T4]` | incomplete existing-test dispositions (validator-blind class) | Added the remaining suites that load the epic-scope files: the Claude `TargetWorktree`, `OperandResolution`, and `EpicScopeHelperParity` suites and the Codex `epic-scope`, `epic-scope.Decision`, `epic-resolution`, and `target-worktree` suites, each unchanged because the allowance admits nothing without a config. The Codex epic-scope suite's 500-line bound on the Codex epic-scope file (currently below the bound by a margin larger than the planned addition) is named.
5. `[P3-T2]` | incomplete existing-test dispositions (validator-blind class) | Added `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.Codex.Tests.ps1` (one auto-derived B1 row per direct edge, so the guarded new edge gains a passing row), `epic-execution-gates.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1`, and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, each unchanged. `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` is not added here: it is returned as a substantive defect because the planned edit cannot satisfy it.

## Validation after fixes

- Installed MCP validator, artifact_type plan: ok.
- Branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan`: passed, exit 0.
