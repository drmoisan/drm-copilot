# Baseline Parallel Pester (P0-T8)

Timestamp: 2026-11-04T00-34
Command: pwsh -NoProfile -File SCRATCH/issue-1066-parallel.ps1 -Root <worktree root> -Prefix baseline-parallel -ProfileOut SCRATCH/issue-1066-PP_base.json (imports scripts/powershell/PoshQC/PoshQC.psd1, runs Invoke-PoshQCParallelTest -Root <worktree root>, copies each artifacts/pester/parallel/shard-<i>/pester-junit.xml to RAW/baseline-parallel-shard-<i>.xml and each shard coverage file to RAW/baseline-parallel-shard-<i>-coverage.xml, then derives per-shard counts and the union container profile table); the analysis step was re-run with -AnalyzeOnly after a parser fix for the shard-files.json `selected` list
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- ExitCode=1 WorkerCount=8 WallClockSeconds=412.97; no merged artifact was written because shards 2 to 8 exited non-zero (pre-existing failures).
- Per-shard exit codes: 1=0, 2=8, 3=18, 4=2, 5=255, 6=16, 7=18, 8=15.
- Per-shard total/failed: 1: 439/0 (junit); 2: 1478/8 (junit); 3: 2440/18 (junit); 4: 1612/2 (junit); 5: 2062/13 (summary line; its JUnit does not load as XML); 6: 2120/16 (junit); 7: 2124/18 (junit); 8: 1635/15 (junit).
- Summed total=13910, summed failed=90. Every shard directory holds pester-junit.xml and powershell-coverage.xml.
- Union container profile table (PP_base): 424 containers from loadable JUnit files; the 72 containers of shard 5 are marked `unavailable`. 20 available containers have a non-zero field (listed below).

## Run output

```text
Started 8 shard processes; logs are under artifacts/pester/parallel.
Shard 1 exited with code 0; log: artifacts/pester/parallel/shard-1/shard.log
Shard 2 exited with code 8; log: artifacts/pester/parallel/shard-2/shard.log
Shard 3 exited with code 18; log: artifacts/pester/parallel/shard-3/shard.log
Shard 4 exited with code 2; log: artifacts/pester/parallel/shard-4/shard.log
Shard 5 exited with code 255; log: artifacts/pester/parallel/shard-5/shard.log
Shard 6 exited with code 16; log: artifacts/pester/parallel/shard-6/shard.log
Shard 7 exited with code 18; log: artifacts/pester/parallel/shard-7/shard.log
```

## Per-shard counts, unavailable containers, and union profile table (PP_base)

```text
  SHARD 1: source=junit total=439 failed=0 junit=True coverage=True
  SHARD 2: source=junit total=1478 failed=8 junit=True coverage=True
  SHARD 3: source=junit total=2440 failed=18 junit=True coverage=True
  SHARD 4: source=junit total=1612 failed=2 junit=True coverage=True
  SHARD-JUNIT-LOAD-FAILED 5: Cannot convert value "<?xml version="1.0" encoding="utf-8" standalone="no"?>
  SHARD 5: source=summary-line total=2062 failed=13 junit=True coverage=True
  SHARD 6: source=junit total=2120 failed=16 junit=True coverage=True
  SHARD 7: source=junit total=2124 failed=18 junit=True coverage=True
  SHARD 8: source=junit total=1635 failed=15 junit=True coverage=True
SUM: total=13910 failed=90 containers=424 unavailable=72
  UNAVAILABLE tests/scripts/ci/CiChangeScope.Tests.ps1
  UNAVAILABLE tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1
  UNAVAILABLE tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/persist-session-id.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-bash.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
  UNAVAILABLE tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/discovery-validation/DiscoveryObservation.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/discovery-validation/DiscoveryStart.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
  UNAVAILABLE tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
  UNAVAILABLE tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
  UNAVAILABLE tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/epic-provenance.Tests.ps1
  UNAVAILABLE tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
  UNAVAILABLE tests/scripts/dev-tools/activate.Tests.ps1
  UNAVAILABLE tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
  UNAVAILABLE tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1
  UNAVAILABLE tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1
  UNAVAILABLE tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | tests=439 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-capability.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | tests=57 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 | tests=66 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | tests=93 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | tests=53 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/file-size-policy/FileSizePolicy.HookDecision.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-settings.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-planning-gate.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | tests=54 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | tests=39 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-start.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | tests=2 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | tests=38 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | tests=76 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | tests=67 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryManifest.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryPlanning.Tests.ps1 | tests=42 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryStop.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | tests=46 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | tests=671 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | tests=55 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | tests=50 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | tests=60 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/file-size-policy.Tests.ps1 | tests=125 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | tests=46 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1 | tests=83 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | tests=5 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | tests=28 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0
  P tests/scripts/host-tools.manifest.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/ci/FileSizeBaseline.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/ci/New-FileSizeBaseline.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-entrypoints.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-planning-gate.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | tests=86 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | tests=68 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | tests=114 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1 | tests=39 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | tests=38 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | tests=89 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/agents-attribution.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | tests=17 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | tests=85 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | tests=48 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/premortem-section.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | tests=83 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | tests=72 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | tests=59 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryRootGrant.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryStartRecord.Seams.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryToolRouting.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | tests=53 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | tests=100 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1 | tests=48 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | tests=27 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | tests=48 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-output.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1 | tests=61 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-capability.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-parent-child.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | tests=18 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-discovery-artifact-gate.HelperImportFailure.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | tests=88 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | tests=108 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | tests=184 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | tests=78 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | tests=61 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexDiscoveryRouting.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryAuthority.Tests.ps1 | tests=53 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryAuthorization.Tests.ps1 | tests=67 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | tests=84 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1 | tests=83 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-start.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | tests=23 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/HostTooling.Tests.ps1 | tests=22 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/workflows/CiWorkflow.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-output.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-start.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | tests=50 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | tests=32 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | tests=55 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | tests=32 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | tests=82 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryPayload.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | tests=95 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 | tests=60 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-capability.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-entrypoints.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-pre-tool.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | tests=68 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-entrypoints.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-output.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-planning.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | tests=32 failed=8 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/run-actionlint.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
```
