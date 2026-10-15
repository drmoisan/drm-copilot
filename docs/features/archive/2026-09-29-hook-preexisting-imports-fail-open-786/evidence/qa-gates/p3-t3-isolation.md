# Claude Behaviour Suite Isolation ([P3-T3])

Timestamp: 2026-10-09T23-02
Command: R-ISOLATION: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1; closure census: sh <SCRATCHPAD>/r.sh closure-seams -Suite tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
EXIT_CODE: 0
Output Summary: R-ISOLATION 298 passed, 0 failed; the AC-4 and AC-6 rows naming tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 pass; the file is 195 lines, carries the four titles, names every Claude W-HOOKS hook path in its prefix table, and dot-sources the exemption list and the baseline helper.

CLOSURE-SEAMS: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-CheckpointContent, Get-CheckpointFileContent, Get-ChildOrchestratorCheckpointContent, Get-CleanupWorktreeManifestContent, Get-EpicCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-EpicScopeCheckpointText, Get-EpicWaveBarrierCheckpointContent, Get-EpicWorktreeGateCheckpointContent, Get-EpicWorktreeGateParallelCheckpointContent, Get-JacocoRepoCoverage, Get-LcovRepoCoverage, Get-ModelRoutingCheckpoint, Get-OrchestratorStateCheckpoint, Get-ParallelCheckpointContent, Get-ParallelCohortBarrierCheckpointContent, Get-ParallelDriftGateCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-ParallelWorktreeRemovalGateCheckpointContent, Get-ParallelWorktreeRemovalGateEpicCheckpointContent, Get-PrAuthorCheckpointContent, Get-PrAuthorReceiptContent, Get-PrdFeatureCheckpointFolder, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeResolutionGitFileText, Get-WorktreeRunCheckpointText, Invoke-PowerShellBatchBudgetHook, Invoke-PythonBatchBudgetHook, Test-CodexEpicChildRoutingLaunchAuthority
PROBE-FORM: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 2

Registration: the six seams with a .claude/lib/ DefiningFile are registered in one Claude statement; each of the 27 script-scope census entries has its own `if (Get-Command ...)` Codex statement. The probe It is the first It and names Get-EpicScopeCheckpointText, Get-WorktreeRunCheckpointText, Get-WorktreeItemCheckpointText, and Get-WorktreeItemLiveRoot.

R-ISOLATION output, closure census output, and token-check output follow.

```text

Starting discovery in 1 files.
Discovery found 298 tests in 20.45s.
Running tests.
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 74.8s (53.94s|422ms)
Tests completed in 74.81s
Tests Passed: 298, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 298
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=298 | failed=0
PASSED: AC-2 non-vacuity claude-hooks yields at least one suite
PASSED: AC-2 non-vacuity codex-hooks yields at least one suite
PASSED: AC-4 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/persist-session-id.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-bash.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-provenance.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-6 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 suite lacking a probe call yields a finding
PASSED: AC-6 suite with a probe call yields none
PASSED: AC-5 process-spawning report claude-hooks
PASSED: AC-5 process-spawning report codex-hooks
PASSED: AC-2 no hard-coded suite list in N2
PASSED: AC-2 no hard-coded suite list or decision D9 note in the legacy guard
PASSED: AC-3 closure-only variable-driven load is detected
PASSED: AC-3 suite whose rows never reach the seam is still flagged
PASSED: AC-5 process-spawning fixture is reported and does not fail
PASSED: AC-2 missing suite yields a finding
PASSED: AC-2 unparseable suite yields a finding
PASSED: AC-4 helper form satisfies the requirement
PASSED: AC-4 helper form naming the wrong seam is a finding
PASSED: AC-4 script-scope seam needs no import
PASSED: AC-4 form F2 fixture complies
PASSED: AC-4 form F3 fixture complies
PASSED: AC-4 helper form with a -ForEach-bound -Seam variable satisfies the requirement
PASSED: AC-4 helper form with an unresolvable -Seam variable is a finding
PASSED: AC-4 helper form with ExtraSeam entries adds a seam and an empty entry adds none
```

```text
CLOSURE-SEAMS: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-CheckpointContent, Get-CheckpointFileContent, Get-ChildOrchestratorCheckpointContent, Get-CleanupWorktreeManifestContent, Get-EpicCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-EpicScopeCheckpointText, Get-EpicWaveBarrierCheckpointContent, Get-EpicWorktreeGateCheckpointContent, Get-EpicWorktreeGateParallelCheckpointContent, Get-JacocoRepoCoverage, Get-LcovRepoCoverage, Get-ModelRoutingCheckpoint, Get-OrchestratorStateCheckpoint, Get-ParallelCheckpointContent, Get-ParallelCohortBarrierCheckpointContent, Get-ParallelDriftGateCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-ParallelWorktreeRemovalGateCheckpointContent, Get-ParallelWorktreeRemovalGateEpicCheckpointContent, Get-PrAuthorCheckpointContent, Get-PrAuthorReceiptContent, Get-PrdFeatureCheckpointFolder, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeResolutionGitFileText, Get-WorktreeRunCheckpointText, Invoke-PowerShellBatchBudgetHook, Invoke-PythonBatchBudgetHook, Test-CodexEpicChildRoutingLaunchAuthority
  REQ: Get-ArtifactFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChangedLanguageSet | module= | class=HookLocalContentSeam
  REQ: Get-CheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-CheckpointFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChildOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-CleanupWorktreeManifestContent | module=CleanupWorktreeManifest | class=ModuleTextSeam
  REQ: Get-EpicCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicScopeCheckpointText | module=EpicScopeResolution | class=ModuleTextSeam
  REQ: Get-EpicScopeCheckpointText | module= | class=HookLocalContentSeam
  REQ: Get-EpicWaveBarrierCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicWorktreeGateCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicWorktreeGateParallelCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-JacocoRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-LcovRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-ModelRoutingCheckpoint | module= | class=HookLocalContentSeam
  REQ: Get-OrchestratorStateCheckpoint | module=OrchestratorState | class=ModuleTextSeam
  REQ: Get-ParallelCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelCohortBarrierCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelDriftGateCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelWorktreeRemovalGateCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelWorktreeRemovalGateEpicCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-PrAuthorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-PrAuthorReceiptContent | module= | class=HookLocalContentSeam
  REQ: Get-PrdFeatureCheckpointFolder | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeItemCheckpointText | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeItemLiveRoot | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeResolutionGitFileText | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeRunCheckpointText | module=WorktreeRunResolution | class=ModuleTextSeam
  REQ: Invoke-PowerShellBatchBudgetHook | module= | class=CwdDerivedResolver
  REQ: Invoke-PythonBatchBudgetHook | module= | class=CwdDerivedResolver
  REQ: Test-CodexEpicChildRoutingLaunchAuthority | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: Get-EpicScopeCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText
  PROBE-FINDING: 
```

```text
LINES: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 195
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/check-powershell-test-purity.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/check-python-test-purity.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-checkpoint-monotonic.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-completion-consistency.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-discovery-artifact-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-epic-invocation-origin.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-epic-merge-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-epic-wave-barrier.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-epic-worktree-removal-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-evidence-locations.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-feature-folder-order.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-mermaid-validation.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-model-routing-receipt.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-parallel-abandon-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-parallel-cohort-barrier.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-parallel-drift-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-powershell-batch-budget.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-pr-author-skill.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-prd-feature-before-planner.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-promotion-mcp-only.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/enforce-python-batch-budget.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-bash.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-discovery-artifact-gate.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-feature-review-coverage.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-orchestrator-output.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-planner-output.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-pr-author-output.ps1
CHECK: ATLEAST1 | 1 | ok | .claude/hooks/validate-prd-feature-output.ps1
CHECK: EXACT1 | 1 | ok | <Event> <Hook> blocks naming <Dependency> when that direct edge fails
CHECK: EXACT1 | 1 | ok | <Event> <Hook> sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
CHECK: EXACT1 | 1 | ok | <Event> <Hook> exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
CHECK: EXACT1 | 1 | ok | has a reason-prefix entry for every discovered Claude hook and no other
CHECK: ATLEAST1 | 1 | ok | HookImportFailureExemptions.Helpers.ps1
CHECK: ATLEAST1 | 1 | ok | EpicStateIsolation.Baseline.Helpers.ps1
CHECK_FAILURES: 0
```
