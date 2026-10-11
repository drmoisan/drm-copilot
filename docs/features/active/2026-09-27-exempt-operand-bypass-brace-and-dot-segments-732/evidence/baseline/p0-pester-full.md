# PoshQC full Pester run (issue #732)

Timestamp: 2026-10-09T03-44
Task: [P0-T17]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p0-t17.sh (step 0 preservation, then R-FULL script B <SCRATCHPAD>/c1b732/rfb.ps1, package-join rule)
EXIT_CODE: 0
PRIOR_BLOCKED_RECORD: docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/baseline/p0-pester-full.round1-blocked.md exists=True
PRIOR_BLOCKED_RECORD_HAS_BLOCKER_LINE: True

## Output

```text
SCRIPT_A: reused round 1
REUSE_COMPARE_JUNIT_LAST_WRITE_UTC: 2026-10-09T03:27:08.5679398Z
REUSE_COMPARE_POSHQC_COVERAGE_LAST_WRITE_UTC: 2026-10-09T03:24:15.3864083Z
RUN_START_UTC: 2026-10-09T03:16:51.9736907Z
RUNNER_SUMMARY: Tests Passed: 7584, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
SCRIPT_A_EXIT: 2
JUNIT_LAST_WRITE_UTC: 2026-10-09T03:27:08.5679398Z
JUNIT_TESTS: 7596
JUNIT_FAILURES: 2
JUNIT_ERRORS: 0
JUNIT_SUITE: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 tests=82 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 tests=30 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests=56 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 tests=30 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 tests=9 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 tests=40 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests=50 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 tests=18 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 tests=45 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 tests=30 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 tests=25 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=87 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 tests=74 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 tests=52 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 tests=48 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 tests=40 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 tests=49 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 tests=36 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 tests=14 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 tests=9 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests=43 failures=1 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 tests=18 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 tests=25 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 tests=68 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 tests=29 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 tests=8 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests=32 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 tests=61 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 tests=70 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 tests=184 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 tests=44 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 tests=114 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 tests=16 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 tests=77 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-bash.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests=16 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 tests=16 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 tests=27 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 tests=32 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 tests=9 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 tests=80 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 tests=31 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 tests=49 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 tests=61 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 tests=49 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 tests=51 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 tests=16 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 tests=36 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 tests=40 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 tests=53 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 tests=100 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 tests=70 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 tests=36 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 tests=43 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 tests=46 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 tests=43 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 tests=47 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 tests=29 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 tests=31 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 tests=41 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 tests=32 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests=42 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 tests=31 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 tests=40 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 tests=95 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 tests=84 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 tests=31 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 tests=26 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 tests=1 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 tests=14 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 tests=24 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 tests=27 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 tests=48 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 tests=51 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/claude-settings.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 tests=8 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests=27 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 tests=9 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 tests=50 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests=49 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 tests=7 failures=1 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 tests=51 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 tests=36 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 tests=16 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests=28 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 tests=40 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 tests=48 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 tests=53 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 tests=25 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 tests=18 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 tests=8 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 tests=50 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 tests=29 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 tests=61 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 tests=39 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 tests=46 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 tests=9 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 tests=37 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 tests=8 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 tests=53 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/activate.Tests.ps1 tests=53 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/agents-attribution.Tests.ps1 tests=1 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 tests=25 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests=6 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 tests=18 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 tests=8 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 tests=29 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 tests=21 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/link-parent-child.Tests.ps1 tests=22 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/new-potential-entry.Tests.ps1 tests=44 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/run-actionlint.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 tests=20 failures=0 errors=0
JUNIT_SUITE: tests/scripts/dev-tools/tree.Tests.ps1 tests=29 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 tests=1 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 tests=17 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 tests=3 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_SUITE: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 tests=34 failures=0 errors=0
JUNIT_SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 tests=10 failures=0 errors=0
JUNIT_SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 tests=4 failures=0 errors=0
JUNIT_FAILED: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
JUNIT_FAILED: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
POSHQC_COVERAGE_LAST_WRITE_UTC: 2026-10-09T03:24:15.3864083Z
POSHQC_RULE: package-join
POSHQC_MATCH: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
POSHQC_MATCH: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=67 missed=0 percent=100.00
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=44 missed=0 percent=100.00
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 covered=165 missed=0 percent=100.00
```

## Done-condition evaluation

- PRIOR_BLOCKED_RECORD exists=True; round-1 record carries a POSHQC_COVERAGE_BLOCKER: line: True.
- JUNIT_LAST_WRITE_UTC later than RUN_START_UTC: True; POSHQC_COVERAGE_LAST_WRITE_UTC later than RUN_START_UTC: True.
- POSHQC_RULE: package-join recorded; five POSHQC_MATCH lines ending package-join classes=1: True.
- Numeric POSHQC_LINE_COVERAGE values: 5; MISSING or AMBIGUOUS lines: 0.
- B_FULL = the 2 JUNIT_FAILED: lines above.

Output Summary: SCRIPT_A: reused round 1; RUNNER_SUMMARY: Tests Passed: 7584, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0; JUNIT_TESTS: 7596; JUNIT_FAILURES: 2; JUNIT_FAILED (B_FULL) 2; PoshQC line-coverage baseline (package-join):
  .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
  .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
  .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=67 missed=0 percent=100.00
  .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=44 missed=0 percent=100.00
  .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 covered=165 missed=0 percent=100.00

