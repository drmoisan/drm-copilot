# Phase 0 Baseline AC 3 Pester Suites (S-AC3, pre-merge tree)

Timestamp: 2026-10-10T23-47
Task: [P0-T7]
Command: cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh rscoped tests/scripts/claude-runtime tests/scripts/claude-hooks tests/scripts/codex-hooks
EXIT_CODE: 0

PassedCount: 6421
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER_COUNT: 211 (all `result=Passed`)

Named AC 3 containers present pre-merge (14 of 14 expected pre-merge; the Issue824 and thresholds suites arrive with the merge and the ThresholdsGuard suite with [P2-T1]):

- hook-dependency-guard-completeness.Tests.ps1: passed=598
- hook-import-failure-exemptions.Guard.Tests.ps1: passed=10
- claude-hooks hook-import-failure-exemptions.FailClosed.Tests.ps1: passed=19
- codex-hooks hook-import-failure-exemptions.FailClosed.Tests.ps1: passed=5
- claude-hooks hook-dependency-guard.Tests.ps1: passed=12
- codex-hooks hook-dependency-guard.Tests.ps1: passed=11
- hook-dependency-failure.Claude.Tests.ps1: passed=139
- hook-dependency-failure.SpecialCases.Tests.ps1: passed=11
- hook-dependency-failure.Codex.Tests.ps1: passed=75
- codex-bundle-hook-probe.Tests.ps1: passed=3
- claude-hooks validate-feature-review-coverage.Tests.ps1: passed=4
- claude-hooks validate-feature-review-coverage.Coverage.Tests.ps1: passed=43
- codex-hooks validate-feature-review-coverage.Coverage.Tests.ps1: passed=29
- enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: passed=315

FAILED lines: none (no pre-existing failures).

Output Summary: 6421 passed, 0 failed, 0 failed blocks, 0 failed containers across 211 containers; all 14 named pre-merge AC 3 containers Passed.

## CONTAINER lines

```text
CONTAINER: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | result=Passed | passed=32 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Passed | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | result=Passed | passed=25 | failed=0
CONTAINER: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | result=Passed | passed=15 | failed=0
CONTAINER: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | result=Passed | passed=83 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | result=Passed | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | result=Passed | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | result=Passed | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | result=Passed | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | result=Passed | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | result=Passed | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | result=Passed | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=315 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | result=Passed | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | result=Passed | passed=30 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | result=Passed | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | result=Passed | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | result=Passed | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | result=Passed | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | result=Passed | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | result=Passed | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | result=Passed | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | result=Passed | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | result=Passed | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | result=Passed | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | result=Passed | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | result=Passed | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | result=Passed | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | result=Passed | passed=23 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | result=Passed | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | result=Passed | passed=48 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | result=Passed | passed=68 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | result=Passed | passed=32 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | result=Passed | passed=61 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | result=Passed | passed=70 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | result=Passed | passed=184 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | result=Passed | passed=25 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | result=Passed | passed=44 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | result=Passed | passed=114 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | result=Passed | passed=47 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Passed | passed=139 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | result=Passed | passed=77 | failed=0
CONTAINER: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | result=Passed | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | result=Passed | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | result=Passed | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | result=Passed | passed=15 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | result=Passed | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | result=Passed | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | result=Passed | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | result=Passed | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | result=Passed | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | result=Passed | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | result=Passed | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | result=Passed | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | result=Passed | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | result=Passed | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | result=Passed | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | result=Passed | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
```
