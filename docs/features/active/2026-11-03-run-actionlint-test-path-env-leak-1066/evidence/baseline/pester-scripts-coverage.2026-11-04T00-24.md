# Baseline CI Shape: tests/scripts Single Process with Coverage (P0-T7)

Timestamp: 2026-11-04T00-24
Command: sh SCRATCH/issue-1066-launch-poshqc.sh tests/scripts baseline-scripts.xml baseline-scripts-coverage.xml issue-1066-p0t7.log (pwsh -NoProfile -File SCRATCH/issue-1066-poshqc-run.ps1 -Root <worktree root> -ScanFolders tests/scripts -TestResultPath RAW/baseline-scripts.xml -CoverageOutputPath RAW/baseline-scripts-coverage.xml); profile and keys by SCRATCH/issue-1066-junit-sets.ps1; coverage by SCRATCH/issue-1066-coverage.ps1
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Total=13910 Passed=13070 Failed=830 Skipped=10 NotRun=0 FailedBlocks=7 FailedContainers=0 (pre-existing Linux host failures; exit 1 is expected on this host).
- RAW/baseline-scripts.xml loads as XML: 496 containers; profile sums tests=13910 failed=830 blocks=7 container=0 (PS_base). 116 containers have a non-zero failed, blocks, or container field.
- Failing keys (information only): 614 distinct keys over 13917 testcases (13910 tests plus 7 [block] entries).
- Coverage (RAW/baseline-scripts-coverage.xml, JaCoCo LINE counters): overall 21303 of 23279 lines = 91.51% over 265 files; `scripts/dev-tools/run-actionlint.ps1` 4 of 50 lines = 8.00%. (Pester's own console figure is 90.95% of 35,638 commands.)

Tooling deviation (mechanical): the first attempt of this run (same command) completed the tests (Total 13910, Failed 830) but returned no result object, because `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` leaves `Run.PassThru` at false and the PassThru check in `Invoke-PoshQCTest` tests the option object rather than its value. `SCRATCH/issue-1066-poshqc-run.ps1` now also sets `Run.PassThru` to true inside its `-InvokePester` scriptblock; the run was repeated and this artifact records the repeated run. No repository file was changed.

The PS_base profile table is also stored as SCRATCH/issue-1066-PS_base.json for the P4-T4 comparison.

## Container profile table (PS_base)

```text
PROFILE: Containers=496 Tests=13910 Failed=830 Blocks=7 Container=0
  P tests/scripts/host-tools.manifest.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/activate.Tests.ps1 | tests=53 failed=13 blocks=0 container=0
  P tests/scripts/dev-tools/agents-attribution.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | tests=5 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | tests=23 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | tests=28 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | tests=32 failed=8 blocks=0 container=0
  P tests/scripts/dev-tools/HostTooling.Tests.ps1 | tests=22 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | tests=25 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | tests=18 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | tests=21 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-parent-child.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | tests=35 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | tests=2 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | tests=18 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/run-actionlint.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 | tests=35 failed=8 blocks=0 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=160 blocks=1 container=0
  P tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | tests=5 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | tests=17 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | tests=21 failed=1 blocks=0 container=0
  P tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/file-size-policy/FileSizePolicy.HookDecision.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1 | tests=111 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1 | tests=83 failed=1 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | tests=27 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | tests=48 failed=4 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1 | tests=39 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | tests=53 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | tests=100 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryAuthority.Tests.ps1 | tests=53 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryAuthorization.Tests.ps1 | tests=67 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryManifest.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryObservation.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryPayload.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryPlanning.Tests.ps1 | tests=42 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryRootGrant.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryStart.Tests.ps1 | tests=72 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryStartRecord.Seams.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryStop.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryToolRouting.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexDiscoveryRouting.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | tests=46 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1 | tests=48 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | tests=95 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1 | tests=84 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | tests=32 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | tests=82 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | tests=47 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | tests=61 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | tests=51 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | tests=59 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | tests=19 failed=1 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-capability.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-entrypoints.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-output.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-planning.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/copilot-hooks/discovery-start.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/ci/CiChangeScope.Tests.ps1 | tests=80 failed=0 blocks=0 container=0
  P tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/ci/FileSizeBaseline.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/ci/New-FileSizeBaseline.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/claude-settings.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | tests=671 failed=1 blocks=0 container=0
  P tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | tests=15 failed=6 blocks=0 container=0
  P tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 | tests=60 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | tests=5 failed=4 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | tests=34 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | tests=55 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1 | tests=20 failed=6 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=3 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | tests=9 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | tests=50 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | tests=38 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | tests=49 failed=9 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | tests=37 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=11 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=51 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | tests=34 failed=17 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | tests=36 failed=6 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | tests=21 failed=10 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-capability.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-entrypoints.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-output.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-planning-gate.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-pre-tool.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/discovery-start.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | tests=16 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | tests=7 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | tests=37 failed=4 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | tests=6 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | tests=29 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | tests=10 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | tests=8 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | tests=11 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=21 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1 | tests=33 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1 | tests=36 failed=14 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1 | tests=61 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | tests=60 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | tests=49 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | tests=54 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | tests=56 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1 | tests=47 failed=9 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | tests=12 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 failed=7 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 failed=14 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=50 blocks=1 container=0
  P tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | tests=29 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | tests=11 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | tests=68 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 | tests=3 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/file-size-policy.Tests.ps1 | tests=125 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | tests=39 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | tests=46 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | tests=89 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1 | tests=83 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=43 blocks=1 container=0
  P tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | tests=10 failed=4 blocks=0 container=0
  P tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1 | tests=28 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | tests=19 failed=11 blocks=0 container=0
  P tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | tests=34 failed=12 blocks=0 container=0
  P tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | tests=85 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-capability.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-entrypoints.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-output.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-planning-gate.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/discovery-start.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | tests=24 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | tests=4 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | tests=7 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 | tests=37 failed=4 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | tests=47 failed=20 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-discovery-artifact-gate.HelperImportFailure.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | tests=16 failed=6 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | tests=37 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | tests=15 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1 | tests=51 failed=6 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1 | tests=34 failed=5 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1 | tests=6 failed=4 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | tests=20 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | tests=40 failed=6 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | tests=57 failed=5 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | tests=11 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | tests=31 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | tests=47 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | tests=18 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | tests=45 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | tests=439 failed=10 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | tests=38 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | tests=76 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | tests=2 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | tests=88 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 | tests=66 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | tests=108 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | tests=86 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1 | tests=41 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | tests=120 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | tests=93 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1 | tests=43 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | tests=36 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | tests=20 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | tests=53 failed=3 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=4 blocks=1 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | tests=14 failed=7 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | tests=49 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | tests=41 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | tests=50 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | tests=47 failed=9 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1 | tests=21 failed=6 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | tests=36 failed=4 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | tests=67 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | tests=19 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | tests=26 failed=10 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | tests=14 failed=9 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | tests=20 failed=13 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | tests=48 failed=13 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 | tests=68 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | tests=32 failed=16 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1 | tests=20 failed=6 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | tests=34 failed=4 blocks=0 container=0
  P tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | tests=68 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 | tests=70 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 | tests=184 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | tests=114 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | tests=47 failed=3 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | tests=186 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | tests=30 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | tests=19 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | tests=16 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/premortem-section.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | tests=83 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | tests=78 failed=2 blocks=0 container=0
  P tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-bash.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | tests=16 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1 | tests=31 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | tests=24 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | tests=72 failed=19 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | tests=17 failed=7 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | tests=27 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1 | tests=38 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1 | tests=14 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | tests=7 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1 | tests=28 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1 | tests=18 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | tests=26 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | tests=13 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | tests=25 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | tests=55 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1 | tests=6 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | tests=9 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | tests=66 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | tests=34 failed=0 blocks=0 container=0
  P tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | tests=40 failed=0 blocks=0 container=0
  P tests/scripts/workflows/CiWorkflow.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
  P tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=15 failed=0 blocks=0 container=0
  P tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | tests=4 failed=0 blocks=0 container=0
```

## Failing keys (information only)

```text
FIRST: Total=13917 Failed=614
  F1 tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1|enforce-checkpoint-monotonic.ps1.Write tool calls.allows when content has no completed_steps field
  F1 tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1|bundled Codex enforce-completion-consistency.ps1.uses the helper-backed route gate for bundled Codex resources
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1|enforce-completion-consistency.ps1 default reader against committed fixtures (issue #736).denies an Edit to complete on the non-empty fixture and names ci_gate
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1|enforce-completion-consistency.ps1 edit semantics (issue #736).resolves 0 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1|enforce-completion-consistency.ps1 edit semantics (issue #736).resolves 1 occurrence without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1|enforce-completion-consistency.ps1 edit semantics (issue #736).resolves 2 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1|enforce-completion-consistency.ps1 edit semantics (issue #736).returns False from Get-EditReplaceAllFlag when replace_all is absent
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.completion asserted with empty feature-folder is blocked.blocks and references feature-folder
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.completion asserted with full evidence is allowed.accepts variables.issue-num and variables.feature-folder fallbacks
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.completion asserted with full evidence is allowed.allows when issue-num, feature-folder, and a success ci_gate with head_sha are present
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.issue #663 epic checkpoint pinning (D3).issue #663 still denies a per-feature checkpoint whose feature-folder is under docs/features/epics/
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Route-driven pr_gate enforcement (Gap 4).allows when a requires_pr_gate route supplies complete matching PR and CI evidence
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Route-driven pr_gate enforcement (Gap 4).blocks when a requires_pr_gate route has stale ci_gate.head_sha versus pr_gate.head_sha
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Route-driven pr_gate enforcement (Gap 4).does NOT require pr_gate for the small route (no requires_pr_gate)
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Route-driven pr_gate enforcement (Gap 4).enforces the gate for a non-232 route with requires_pr_gate true (route-driven, not issue-driven)
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Route-driven pr_gate enforcement (Gap 4).requires pr_gate and blocks when a requires_pr_gate route omits PR evidence
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).allows a digits-only issue-num with a valid existing feature-folder
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).allows a valid docs/features/active/... feature-folder that exists
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks a feature-folder sentinel "n/a"
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks a valid-shaped feature-folder when the injected existence check returns false
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks issue-num sentinel "  "
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks issue-num sentinel ""
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks issue-num sentinel "n/a"
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks issue-num sentinel "none"
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Sentinel issue-num and feature-folder rejection (Gap 2).blocks issue-num sentinel "tbd"
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Test-RouteRequiresPrGate unit behavior.returns false for a route without requires_pr_gate
  F1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1|enforce-completion-consistency.ps1.Test-RouteRequiresPrGate unit behavior.returns false when the payload selects no route
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides allow for a squash merge of 691 with a valid 691 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides allow for a valid 691 record in the per-feature checkpoint
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides deny for a blanket true flag
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides deny for a record naming 777 only
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides deny for a session_id that differs from the envelope
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1|enforce-epic-merge-gate.ps1 standalone authorization (issue #670).decision matrix.decides deny for an envelope carrying no session_id
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1|enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.allows a docs-only merge with no checkpoint record (issue #927)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1|enforce-epic-merge-gate strict epic_mode (issue #1001).Invoke-EpicMergeGateDecision branch 1 with a child checkpoint bound to PR 42.returns allow for gh pr merge 42 --merge when epic_mode is JSON true
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.ci_gate.head_sha case absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.declines ci_gate case ci_gate absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.declines ci_gate case conclusion absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.declines pr_gate.pr_number case absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.declines pr_gate.pr_number case pr_gate absent with a matching authorization record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1|enforce-epic-merge-gate green-CI pure functions (issue #997).Test-ChildCheckpointGreenCiRecorded fail-closed rows.declines step9_status case absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1|enforce-epic-merge-gate green-CI decision (issue #997).allow rows.allows a standalone merge with a green S9 gate and a matching live head (issue #997)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1|enforce-epic-merge-gate green-CI decision (issue #997).allow rows.allows when --match-head-commit equals the live head (issue #997)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1|enforce-epic-merge-gate green-CI decision (issue #997).allow rows.allows when pr_gate.head_sha equals ci_gate.head_sha (issue #997)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1|enforce-epic-merge-gate green-CI decision (issue #997).command-shape declines.still allows --rebase with a valid green checkpoint (issue #997)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1|enforce-epic-merge-gate green-CI decision (issue #997).command-shape declines.still allows --squash with a valid green checkpoint (issue #997)
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1|enforce-epic-merge-gate existing branches around the green-CI branch (issue #997).a matching session-bound standalone_merge_authorizations record still allows a non-green checkpoint
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1|enforce-epic-merge-gate existing branches around the green-CI branch (issue #997).branch 1 still allows epic_mode true with step9_status passed
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1|enforce-epic-merge-gate existing branches around the green-CI branch (issue #997).the docs-only branch still allows when no checkpoint records the PR
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1|enforce-epic-merge-gate existing branches around the green-CI branch (issue #997).the parallel allow-branch still allows a ci_green item
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1|epic merge gate item-worktree resolution.authorizes a standalone merge from the item worktree checkpoint
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides allow for gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides allow for gh pr merge --merge --auto 5 with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides allow for gh pr merge --subject x 5 --merge with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides allow for gh pr merge 5 --squash with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides allow for gh pr merge https://github.com/drmoisan/drm-copilot/pull/5 --merge with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1|enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).a matching authorization record allows every gated spelling (AC-8).decides deny for gh pr merge 6 --auto with a pull request 5 record
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1|enforce-epic-merge-gate.ps1.allow via epic-integration checkpoint (ci_gate success + matching PR number).allows gh pr merge <N> --merge when epic_merge_pr.ci_gate.conclusion is success and PR number matches
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1|enforce-epic-merge-gate.ps1.allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR).allows gh pr merge --merge <N> when route_id is parallel and the matched item is ci_green
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1|enforce-epic-merge-gate.ps1.deny on non-matching PR number.denies gh pr merge <N> --merge when N does not match epic_merge_pr.pr_number
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1|enforce-epic-merge-gate.ps1.Test-EpicCheckpointAllowsMerge helper (direct branch coverage).returns $false when epic_merge_pr is absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1|enforce-epic-merge-gate.ps1.Test-EpicCheckpointAllowsMerge helper (direct branch coverage).returns $false when epic_merge_pr.ci_gate is absent
  F1 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1|epic merge gate run-target resolution.M9 allows a standalone-authorized merge when neither run branch resolves
  F1 tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1|enforce-epic-wave-barrier.ps1.Find-EpicWaveBarrierFeatureRecord helper.returns $null when features key is absent
  F1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1|enforce-epic-worktree-removal-gate.ps1.Find-EpicWorktreeFeatureRecord helper.returns $null when features key is absent
  F1 tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1|enforce-evidence-locations.ps1.canonical evidence paths.allows writes to <FEATURE>/evidence/baseline/ (canonical evidence path)
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-3 suite whose rows never reach the seam is still flagged
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 form F2 fixture complies
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 form F3 fixture complies
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 helper form naming the wrong seam is a finding
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 helper form satisfies the requirement
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 helper form with a -ForEach-bound -Seam variable satisfies the requirement
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 helper form with an unresolvable -Seam variable is a finding
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 helper form with ExtraSeam entries adds a seam and an empty entry adds none
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-4 script-scope seam needs no import
  F1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1|discovery guard (both hook surfaces).AC-5 process-spawning fixture is reported and does not fail
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1|enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names features as the failed conjunct
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1|enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names items as the failed conjunct
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1|Claude preimplementation gate cleanup legs (issue #1026).consolidation git add.allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1|Claude preimplementation gate cleanup legs (issue #1026).prefilters and fail-closed behavior.starts no listing process when every prefilter fails
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1|preimplementation gate behavioral parity (claude).AC-17 readiness an empty checkpoint object claude
  F1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1|preimplementation gate behavioral parity (codex).AC-17 readiness an empty checkpoint object codex
  F1 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1|enforce-parallel-cohort-barrier.ps1.Find-ParallelCohortBarrierItemByKey helper.returns $null when the items key is absent
  F1 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1|enforce-parallel-cohort-barrier.ps1.Find-ParallelCohortBarrierItemRecord helper.returns $null when the items key is absent
  F1 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1|enforce-parallel-cohort-barrier.ps1.Get-ParallelCohortBarrierConflictNeighborList helper.returns an empty list when conflict_edges is absent
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation [block]
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.records the narrowing as strictly conservative on the widened-radius row
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.reports unresolved on every non-conforming-timestamp row of the shared table
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.derivation helpers.Get-ParallelDriftGateUnresolvedState surfaces LatestAt for the latest event of each item
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).another run item cited alongside the target.D4b: allows when the canonical issue-number line selects the target
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).nested-artifact citations resolve to the target folder.D1: allows the target folder cited alone when it has no drift event
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).nested-artifact citations resolve to the target folder.D2a: allows the target folder cited together with a research artifact
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).nested-artifact citations resolve to the target folder.D2b: allows the target folder cited together with an evidence artifact
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).nested-artifact citations resolve to the target folder.D3a: allows a research artifact cited alone
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).nested-artifact citations resolve to the target folder.D3b: allows an evidence artifact cited alone
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1|enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565).the finding-presence probe receives the resolved basename.D8: probes the target folder, not the nested evidence kind, for an unresolved drift event
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1|enforce-parallel-drift-gate.ps1.item-record resolution helper.Find-ParallelDriftGateItemRecord returns $null for an absent items key
  F1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1|enforce-parallel-worktree-removal-gate.ps1.Find-ParallelWorktreeItemRecord helper.returns $null when the items key is absent
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.treats a throwing checkpoint reader as direct mode without raising
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.direct mode.allows the first three distinct production paths and denies the 4th with no checkpoint
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.direct mode.denies the 4th distinct production path when the checkpoint route is small
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.direct mode.enforces direct mode for a terminal large-route checkpoint
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.direct mode.names the routing target, counted paths, requested path, and observed route
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.direct mode.omits every prohibited remedy phrase and the state-file path from the deny reason
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.removed cap overrides.ignores CLAUDE_POWERSHELL_BUDGET_PROD and _TEST set in the test scope
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1|enforce-powershell-batch-budget.ps1 large-path routing.removed cap overrides.loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint is terminal by next_step
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint is terminal by S12_complete
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint selects a non-large route
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item has no checkpoint
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.counts a sibling worktree against its own keyed budget
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1|enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.still counts a production file under a nested directory named artifacts
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1|enforce-powershell-batch-budget.ps1.allows a new production file under the production cap and records it
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1|enforce-powershell-batch-budget.ps1.ignores non-PowerShell file paths
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1|enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root
  F1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1|enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.block message.names the resolved folder ahead of the prd-feature remedy phrase
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.block message.retains the PRD_FEATURE_BLOCKED prefix on every deny reason
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.decision equivalence and the reproduction differential.allows full-bug with spec present and user-story absent citing a nested research artifact
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.decision equivalence and the reproduction differential.returns the same decision for all four prompt forms
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.decision equivalence and the reproduction differential.returns the same decision for folder-relative and repo-relative research paths
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.preserved gate behavior.allows minor-audit when neither prerequisite file is present
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.preserved gate behavior.denies full-bug when spec.md is missing
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.preserved gate behavior.denies full-feature when spec.md is missing
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.preserved gate behavior.denies full-feature when user-story.md is missing and names it
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 folder resolution.preserved gate behavior.normalizes the legacy full marker to the full-feature prerequisite set
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd lets no feature-folder path and no file path select the worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R1 allows a coordinating-session delegation whose item is identified by issue number while the folder exists in twelve worktrees
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R4 resolves by branch when a stale attempt records the same issue
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R5 never composes a checkpoint path under the coordinating session root
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R5 reads the feature folder from the checkpoint of the resolved worktree when the prompt names none
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R6 denies with the missing-document reason when a prerequisite is absent beneath the resolved worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R7 ignores a feature-folder path when choosing the worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd R8 selects among two cited folders with the checkpoint of the resolved worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 identity resolution.prd resolution-family and document-family reasons never appear in each other's decisions
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.allows a repo-relative citation placed in the item worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.allows an absolute path to the target feature folder
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.allows when the modelled cwd is the item worktree
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.allows when the target root holds the required document
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.denies with the missing-document reason when the document is absent under the target root
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.probes once on a full-bug allow row
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.probes twice on a full-feature allow row
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.reads the checkpoint of the resolved worktree rather than the session root's
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1|enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.resolves the required document set for each work mode
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.accepts backslash separators inside the prompt path
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.allows the session-root fallback when the derived target is the session root
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.allows when both spec.md and user-story.md exist in the target folder (prompt path)
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.blocks when spec.md is missing
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.blocks when user-story.md is missing
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.prefers the prompt-derived folder over the checkpoint folder
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.atomic-planner delegation.treats a path ending in .md as a file and uses its parent directory
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.allows full-bug mode when only spec.md is present (user-story.md absent)
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.allows full-feature mode when spec.md and user-story.md are both present
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.allows minor-audit mode even when spec.md and user-story.md are both absent
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.blocks full-bug mode when spec.md is missing and does not demand user-story.md
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.blocks full-feature mode when spec.md is missing, naming the work mode
  F1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1|enforce-prd-feature-before-planner.ps1.work-mode aware prerequisite resolution.treats the legacy full marker as the full-feature requirement set
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.treats a throwing checkpoint reader as direct mode without raising
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.allows the first three distinct production paths and denies the 4th with no checkpoint
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.blank route_id with path_selected large checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.empty checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.malformed checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.names the routing target, counted paths, requested path, and observed route
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.non-object checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.null route_id with path_selected large checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.omits every prohibited remedy phrase and the state-file path from the deny reason
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.route_id small checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.terminal next_step complete checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.terminal S12_complete checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.direct mode.unknown route checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.removed cap overrides.ignores CLAUDE_PYTHON_BUDGET_PROD and _TEST set in the test scope
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1|enforce-python-batch-budget.ps1 large-path routing.removed cap overrides.loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint is terminal by next_step
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint is terminal by S12_complete
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item checkpoint selects a non-large route
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.caps the item on the fourth path when the item has no checkpoint
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.counts a sibling worktree against its own keyed budget
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1|enforce-python-batch-budget.ps1 target-worktree resolution (issue #1009).target-worktree evaluation with an explicit invoker.still counts a production file under a nested directory named artifacts
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1|enforce-python-batch-budget.ps1.allows a new production file under the production cap and records it
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1|enforce-python-batch-budget.ps1.ignores non-Python file paths
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1|enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root
  F1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1|enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root
  F1 tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1|hook-command-invocation classification, claude copy (issue #824).IV-10 absorbs --exec-path=<value> as one global option
  F1 tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1|hook-command-invocation classification, codex copy (issue #824).IV-10 absorbs --exec-path=<value> as one global option
  F1 tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for empty input
  F1 tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for null input
  F1 tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for whitespace-only input
  F1 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1|parallel drift gate handler proof.H5 control: enforce-parallel-drift-gate.ps1 allows the D1 delegation when feature-folder-resolution.ps1 loads
  F1 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1|prd-feature planner handler proof.H3 control: enforce-prd-feature-before-planner.ps1 allows a planner delegation whose prerequisites exist when feature-folder-resolution.ps1 loads
  F1 tests/scripts/claude-hooks/persist-session-id.Tests.ps1|persist-session-id.ps1.Invoke-PersistSessionIdHook.appends CLAUDE_SESSION_ID=<id> to the env file when CLAUDE_ENV_FILE is set
  F1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1|subagentstop-envelope helper.source constraints.imports and dot-sources nothing
  F1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1|subagentstop-envelope helper.source constraints.writes nothing to the success, host, information or warning streams
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR10a: LineBelowFloor is repairable with stop_hook_active False
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR10a: LineBelowFloor is repairable with stop_hook_active True
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR10a: NoCoverageRow is repairable with stop_hook_active False
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR10a: NoCoverageRow is repairable with stop_hook_active True
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR10c: a repairable and a non-repairable coverage condition still block with stop_hook_active true
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR4a: an absent root CLAUDE.md applies the default branch floor
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR4a: an absent root CLAUDE.md applies the default line floor
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Invoke-FeatureReviewCoverageValidation.allows a changed language whose coverage row carries a verdict
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Invoke-FeatureReviewCoverageValidation.blocks when a changed language has no coverage verdict
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.accepts a FAIL verdict for coverage below the line floor
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.E4-TR6: branch floor message names 60% branch coverage floor (root CLAUDE.md)
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.E4-TR6: branch floor message names 75% branch coverage floor (default)
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.E4-TR6: line floor message names 70% line coverage floor (root CLAUDE.md)
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.E4-TR6: line floor message names 85% line coverage floor (default)
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.fails when a coverage row narrows scope
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.fails when branch coverage is below the floor
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.fails when coverage rows carry no verdict
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.fails when line coverage is below the floor without a FAIL verdict
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow.fails when no coverage-scoped row mentions the language
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-4 reads PowerShell line coverage from the JaCoCo report
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-5 reads branch coverage from the JaCoCo report
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-6 rejects a coverage row that narrows scope
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - coverage parsing paths (coverage support).F824-8 rejects a language mention with no coverage-scoped row
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-2 falls back to the default floors when the root CLAUDE.md states no figures
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1|validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-3 applies a line-only figure and keeps the default branch floor
  F1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1|validate-feature-review-coverage.ps1.coverage verdict enforcement.blocks when a changed language lacks an explicit PASS or FAIL coverage verdict
  F1 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1|validate-pr-author-output.ps1.Get-PrAuthorOutputDecision - allow scenarios.allows when output contains a PR #<n> reference
  F1 tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1|Get-ComplexityFloor.Determinism.returns an identical band across repeated calls with the same input
  F1 tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1|HookTargetWorktree module source (AST).performs no file, environment, or clock read outside the default invoker body
  F1 tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1|WorktreeResolution.worktree enumeration.returns an empty array for a .git file with no gitdir line
  F1 tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1|WorktreeResolution.worktree enumeration.returns an empty array for a linked worktree whose admin directory has no commondir
  F1 tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1|WorktreeResolution.worktree enumeration.returns an empty array for a session root with no .git entry
  F1 tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1|WorktreeResolution.worktree enumeration.returns an empty array for an empty session root
  F1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1|hook dependency guard structural completeness (issue #786).S9: no registered hook loads the retired DiscoveryValidation compatibility module (issue #980)
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.detection logic (in-memory fixtures).detects a banned substring in the banned fixture and none in the positive fixture
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.detection logic (in-memory fixtures).reports all required fields present and extracts the MCP tool list from the positive fixture
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.detection logic (in-memory fixtures).reports missing and present body references against the positive fixture
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.real persona files.assertion 2 - each persona declares name, description, tools and memory
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.real persona files.assertion 6 - each persona full text contains no banned domain-specific substring
  F1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1|legacy-discovery-agent-roles structural test.real persona files.assertion 7 - each persona body names its owned artifact kinds, the validated profile and finalize
  F1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1|test-name-uniqueness adapter-ID collision guard.detection logic (in-memory fixtures).detects a literal -ForEach whose rows differ only by data-value case
  F1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1|test-name-uniqueness adapter-ID collision guard.detection logic (in-memory fixtures).detects two sibling It names that differ only by letter case
  F1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1|test-name-uniqueness adapter-ID collision guard.detection logic (in-memory fixtures).reports no collision when a literal -ForEach disambiguates rows with a distinct data key
  F1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1|test-name-uniqueness adapter-ID collision guard.detection logic (in-memory fixtures).skips a non-literal -ForEach argument without raising a collision
  F1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1|Codex per-batch budget PreToolUse hooks.the PowerShell batch-budget hook.allows when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1|Codex per-batch budget PreToolUse hooks.the Python batch-budget hook.allows when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the PowerShell hook.target-worktree evaluation with an explicit invoker.caps an item worktree without a checkpoint on the fourth path
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the PowerShell hook.target-worktree evaluation with an explicit invoker.counts a path outside every registered worktree against the session root as today
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the PowerShell hook.target-worktree evaluation with an explicit invoker.evaluates each side of an apply_patch move against its own worktree
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the Python hook.target-worktree evaluation with an explicit invoker.caps an item worktree without a checkpoint on the fourth path
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the Python hook.target-worktree evaluation with an explicit invoker.counts a path outside every registered worktree against the session root as today
  F1 tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1|Codex batch-budget hooks target-worktree resolution (issue #1009).the Python hook.target-worktree evaluation with an explicit invoker.evaluates each side of an apply_patch move against its own worktree
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697) [block]
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).derives 20 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).leaves no batch-budget state in the bundle
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
  F1 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1|enforce-completion-consistency route-driven pr_gate evidence.Invoke-CompletionConsistencyDecision terminal branches.allows a completion-asserting checkpoint that carries every required piece of evidence
  F1 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1|enforce-completion-consistency route-driven pr_gate evidence.Invoke-CompletionConsistencyDecision terminal branches.denies a completion-asserting checkpoint whose pr_gate evidence is incomplete
  F1 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1|enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is dormant
  F1 tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1|Codex evidence-location and checkpoint-order PreToolUse hooks.enforce-checkpoint-monotonic decision function.allows when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1|Codex evidence-location and checkpoint-order PreToolUse hooks.enforce-evidence-locations policy functions.allows when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.treats a throwing checkpoint reader as direct mode without raising
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.direct mode.allows the first three distinct production paths and denies the 4th with no checkpoint
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.direct mode.denies the 4th distinct production path when the checkpoint route is small
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.direct mode.enforces direct mode for a terminal large-route checkpoint
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.direct mode.names the routing target, counted paths, requested path, and observed route
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.direct mode.omits every prohibited remedy phrase and the state-file path from the deny reason
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.entry point.emits a deny envelope without a state property for the 4th production path in direct mode
  F1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1|Codex enforce-powershell-batch-budget.ps1 large-path routing.removed cap overrides.loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
  F1 tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1|codex-pretooluse-file-mapping shared transport module.ConvertFrom-CodexPreToolUsePayload rejects un-processable input.throws when session_id is absent under -RequireSessionId
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits [block]
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 one registration returns an array of count one
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 zero registrations return an empty array that is not null
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects a null result
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects an empty array
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.DEV-2 wave barrier allows a benign payload for every admitted tool name when no local checkpoint text is supplied
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.fails closed with exit 2 for <Label> on every registered handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.leaves no Codex batch-budget state behind
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.parses at least three matcher groups and every registered handler from config.toml
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.reports enforce-completion-consistency in its own stderr rather than its neighbour
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract [block]
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a safe <ToolName> payload on every group handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a well-formed apply_patch payload whose tool_input maps to no file edit (<Label>)
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows an apply_patch update that touches only ungoverned files with a missing source
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from <ToolName>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for <HookName> on a forbidden <ToolName> payload
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a checkpoint write that does not assert completion
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a file path that is not the governed checkpoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows an unrelated mapped write through its own entrypoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows mapped tool_input that carries no file_path
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a checkpoint edit whose patch cannot be resolved
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a completion-asserting checkpoint write through its own entrypoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by <Label>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for <Label>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).reads issue-num and feature-folder from variables and reports ci_gate gaps
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string for a null checkpoint payload property lookup
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string when the checkpoint property value is null
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns null checkpoint content when the path is not a file
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns the file text when the checkpoint path resolves to a file
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).treats a null payload as asserting no completion
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 for <Label> on every group handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 when a batch-budget payload omits session_id
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.does not read the checkpoint when tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.treats a throwing checkpoint reader as direct mode without raising
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.allows the first three distinct production paths and denies the 4th with no checkpoint
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.blank route_id with path_selected large checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.empty checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.malformed checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.names the routing target, counted paths, requested path, and observed route
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.non-object checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.null route_id with path_selected large checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.omits every prohibited remedy phrase and the state-file path from the deny reason
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.route_id small checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.terminal next_step complete checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.terminal S12_complete checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.direct mode.unknown route checkpoint enforces direct mode for the 4th production path
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.entry point.emits a deny envelope without a state property for the 4th production path in direct mode
  F1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1|Codex enforce-python-batch-budget.ps1 large-path routing.removed cap overrides.loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-powershell-test-purity policy functions.denies an Edit whose new_string introduces a timing hack
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-powershell-test-purity policy functions.returns no decision when a PowerShell test edit carries no content
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-powershell-test-purity policy functions.returns no decision when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-python-test-purity policy functions.denies an Edit whose new_string introduces forbidden Python dependencies
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-python-test-purity policy functions.returns no decision when a Python test edit carries no content
  F1 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1|Codex test-purity PreToolUse hooks.check-python-test-purity policy functions.returns no decision when the mapped tool_input carries no file_path
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.accepts a matching reasoning effort supplied under either property name
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.falls back to reasoning_effort when model_reasoning_effort is absent
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.propagates every error the launch-receipt validator returns
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reads the reasoning effort from model_reasoning_effort when that property is present
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reports a changed deployment profile hash
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reports a payload agent type that disagrees with the launch receipt
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reports a payload model that disagrees with the launch receipt
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reports no error when the receipt, attestation, and hashes all match
  F1 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1|enforce-epic-child-worktree-binding.ps1 guard functions.Test-CodexChildGuardAttestation.reports the validator as unavailable when it cannot be resolved
  F1 tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1|Codex enforce-codex-model-routing coverage (issue #786).entry point.allows an unrouted agent with no attestation
  F1 tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1|Codex enforce-codex-model-routing coverage (issue #786).entry point.falls back to the agent-id attestation scan
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1|enforce-completion-consistency.ps1 Codex default reader against committed fixtures (issue #736).denies an Edit to complete on the non-empty fixture and names ci_gate
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1|enforce-completion-consistency.ps1 Codex edit semantics (issue #736).resolves 0 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1|enforce-completion-consistency.ps1 Codex edit semantics (issue #736).resolves 1 occurrence without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1|enforce-completion-consistency.ps1 Codex edit semantics (issue #736).resolves 2 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1|enforce-completion-consistency.ps1 Codex edit semantics (issue #736).returns False from Get-EditReplaceAllFlag when replace_all is absent
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1|Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.emits no mapped record for an apply_patch Update of the epic checkpoint
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1|Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint that lacks ci_gate
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1|Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
  F1 tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1|enforce-completion-consistency.ps1 Codex fail-closed checkpoint handling (issue #736).allows a tool_input with no file_path without invoking the reader
  F1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1|Codex enforce-epic-merge-gate standalone authorization (issue #670).decision matrix.decides deny for a payload carrying no session_id
  F1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1|Codex enforce-epic-merge-gate docs-only branch (issue #927).allows a docs-only merge when no checkpoint is present (codex, issue #927)
  F1 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1|Codex enforce-epic-merge-gate trigger scoping (issue #545).R-2.a wrapper-led segments stay in scope.R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument
  F1 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1|Codex enforce-epic-merge-gate trigger scoping (issue #545).scope filter separates a mention from an invocation.keeps a real gh pr merge --merge invocation in scope and denies it without a checkpoint
  F1 tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1|Codex enforce-epic-root-invocation coverage (issue #786).entry point.falls back to the agent-id attestation scan and denies missing provenance
  F1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1|Codex enforce-epic-worktree-removal-gate decision surface (issue #545).the decision router scope and operand branches.falls back to the current location when the payload carries no cwd
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).apply_patch manifest.allows an apply_patch Add File of the manifest with valid content
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).apply_patch manifest.denies an apply_patch Update, Delete, or Move of the manifest
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.allows git -C <consolidation root> commit -F when the staged index is non-empty and entirely allowlisted
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.denies git add in the consolidation worktree when any operand is outside the allowlist
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.denies the commit when the staged index holds a non-allowlisted path
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.denies the commit when the staged index is empty or the staged-index seam fails
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).consolidation git add and commit.identifies the consolidation worktree by porcelain branch documentationandmemories and not by path
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).paired denials outside the consolidation worktree.denies the apply_patch manifest Add against a non-consolidation worktree
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).paired denials outside the consolidation worktree.denies the git add against a non-consolidation worktree
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).paired denials outside the consolidation worktree.denies the git add against the session root
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).paired denials outside the consolidation worktree.denies the git commit against a non-consolidation worktree
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1|Codex preimplementation gate cleanup legs (issue #1026).paired denials outside the consolidation worktree.denies the git commit against the session root
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1|Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names features as the failed conjunct
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1|Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names items as the failed conjunct
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C10 denies Bash operands in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C12 denies an absolute git -C commit naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing names no worktree
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C18 admits git commit -m msg <abs file> against a ready item checkpoint, reading the item checkpoint
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C4 admits git -c k=v -C <wt> commit against a ready item checkpoint
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C5 reads the item checkpoint for git add with an absolute operand
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C6 reads the item checkpoint for a later-segment git -C selector
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C7 admits an apply_patch whose absolute marker path lies in a ready item worktree, reading the item checkpoint
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C9 reads the session-root checkpoint for a target outside every registered worktree, a relative operand, and no operand (none)
  F1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1|Codex gate target-worktree building blocks (issue #1010).C9 reads the session-root checkpoint for a target outside every registered worktree, a relative operand, and no operand (relative)
  F1 tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1|Codex epic-child launch attestation.accepts a session-bound launch receipt for epic_execution_child
  F1 tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1|Codex epic-child launch attestation.accepts a session-bound launch receipt for epic_preparation_child
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.keys the same generated profile independently for each exact worktree
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.rejects a partial execution wave but excludes terminal features
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.rejects a string-shaped issue number even when every binding repeats it
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.rejects duplicate checkpoint feature identities before exactly-once coverage
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.rejects non-active or placeholder feature-folder identities
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.requires conjunctive delegation and model receipt identity
  F1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1|Codex epic-child launcher hardening.requires lowercase artifact identifiers to prevent case-only filesystem collisions
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.accepts a feature, delegation, branch, worktree, model receipt, and profile that all match
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.extracts the exact Codex session id from JSONL for resume continuity
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.launches all planner preparations in one batch after final identity promotion
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.rejects a missing exact delegation receipt
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.rejects a prepared execution prompt without its plan path and atomic-execution resume text
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.rejects execution prompts missing required epic identity, branch, or PR-base markers
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.rejects model, reasoning, permission, and worktree branch drift
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.immutable launch specification validation.requires bounded parallelism to match the checkpoint and remain at most eight
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.PreToolUse worktree binding.allows a launch-authorized mutation in the exact worktree and branch
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.PreToolUse worktree binding.denies a mismatched working directory, branch, spec hash, or environment attestation
  F1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1|Codex epic-child worktree launcher and guard.PreToolUse worktree binding.requires explicit matching workspace_root on every drm-copilot MCP call
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates [block]
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.fails closed on malformed Codex stdin JSON
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows a verified epic child merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows the matching final epic PR after a successful CI gate
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.denies a mismatched final PR number
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows both registered MCP server spellings identically for <Operation>
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows explicit planning-artifact staging and an ordinary commit
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows feature planning document edits
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows only preparation lifecycle MCP operations
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies <Label> exactly without changing checkpoint bytes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies a preparation commit when staged paths include production code
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies commit pathspecs and broad push modes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies deletion or route mutation of the canonical preparation checkpoint
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies non-repository MCP tools during preparation
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies path traversal, move destinations, and security receipt writes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies PR creation and CI execution commands
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies production edits
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed for an attested preparation child before its checkpoint exists
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed when an attested preparation child changes its checkpoint route
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.requires explicit matching MCP workspace_root for an attested preparation child
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.allows a child after every dependency is merged
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.denies a child before an upstream merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.does not apply the execution barrier to preparation children
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.allows removal after merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.denies removal while the PR is open
  F1 tests/scripts/codex-hooks/epic-provenance.Tests.ps1|Codex epic provenance and routing attestation hooks.binds a planner child to its per-feature Codex routing receipt
  F1 tests/scripts/codex-hooks/epic-provenance.Tests.ps1|Codex epic provenance and routing attestation hooks.binds a routed child to the deployment profile model
  F1 tests/scripts/codex-hooks/epic-provenance.Tests.ps1|Codex epic provenance and routing attestation hooks.denies mutation after a model mismatch attestation
  F1 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1|Receipt-bound epic wave barrier.allows mutation after every dependency is durably merged
  F1 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1|Receipt-bound epic wave barrier.allows mutation after every dependency worktree is removed
  F1 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1|Receipt-bound epic wave barrier.blocks the first mutation before a local child checkpoint exists
  F1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1|feature-review coverage floor parity (issue #896).E4-PX1: comparator form reports line floor 70 on both surfaces
  F1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1|feature-review coverage floor parity (issue #896).E4-PX1: no figure reports line floor 85 on both surfaces
  F1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1|feature-review coverage floor parity (issue #896).E4-PX1: trailing form reports line floor 92 on both surfaces
  F1 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for empty input
  F1 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for null input
  F1 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1|hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for whitespace-only input
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts [block]
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation command <Expected>
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation path <Expected>
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
  F1 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1|Codex routed model profile attestation.persists the receipt and profile model-reasoning binding
  F1 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1|Codex routed model profile attestation.rehashes the current profile before allowing a routed mutation
  F1 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1|Codex routed model profile attestation.rejects a routing receipt whose reasoning differs from the profile
  F1 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1|Codex routed model profile attestation.requires the exact task-researcher C3 receipt before its first mutation
  F1 tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1|Single-use authority consumption preserves real authorization.authorizes once and rejects the serialized consumed receipt on reuse
  F1 tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1|Subagent attestation input and root-receipt rejection.records profile lookup failure as rejected attestation
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).entry point.exits 2 for a missing session id
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).entry point.requests a continuation for a routed agent without an attestation
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.allows a matching attestation
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.gates discovery specialist legacy-parity-analyst on a discovery-invocation start attestation (issue #980)
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.gates discovery specialist requirements-reconciler-c3-elevated on a discovery-invocation start attestation (issue #980)
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports a missing epic attestation
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports a missing routed attestation
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports a model change
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports an identity mismatch
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports invalid routing
  F1 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1|Codex validate-codex-subagent-routing coverage (issue #786).Invoke-CodexSubagentStopDecision.reports missing epic provenance
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.E4-TR7: with no CLAUDE.md figure an 80.5% line row fails against the 85% floor
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.E4-TR8: a CLAUDE.md line floor of 70 lets a 72% row pass
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 2 for a missing stop_hook_active
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 2 for a non-review payload
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 2 for empty stdin
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 2 for malformed stdin
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).entry point.requests a continuation when a changed language lacks a verdict
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow and continuation.accepts a FAIL verdict for low coverage
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow and continuation.reports a narrowing row
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow and continuation.reports a row without a verdict
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow and continuation.reports low coverage without FAIL
  F1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1|Codex validate-feature-review-coverage coverage (issue #786).Test-LanguageCoverageRow and continuation.reports no coverage row
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).module candidates.returns a non-zero exit from the deployment wrapper when no candidate exists
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses a missing required flag
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses a negative-number value
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses a non-integer count
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses a repeated append
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses a value with the last occurrence winning
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses an equals-sign value
  F1 tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1|codex-routing-cli-common.ps1 (issue #697).token parser.parses an integer value
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) [block]
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).includes each frozen discovery row in both wrapper populations
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for deployment case <id> through pwsh -File
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for topology case <id> through pwsh -File
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).resolves modules through the .claude/lib fallback inside drm-copilot
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case <id>
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.skips the project poetry install by request
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
  F1 tests/scripts/dev-tools/HostBootstrap.Tests.ps1|Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-WorkspaceRoot.returns the full form of an explicit path
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.derives the target path from the url in dry run
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.skips a project that is already present
  F1 tests/scripts/dev-tools/HostTooling.Tests.ps1|Read-HostToolsManifest.returns the parsed manifest object when the file exists
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.Get-NpmVersion (real reader).throws when the manifest has no version field
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.git/npm/gh seam failures.returns 1 and does not open a PR when 'git push -u origin <branch>' fails
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.release-branch derivation (pure function).derives release/full-<timestamp> from a fixed Now
  F1 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1|Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded.Get-NpmVersion (real reader) and Get-ReleaseBranchName.derives release/extension-<timestamp> from a fixed Now
  F1 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1|Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded.Get-NpmVersion (real reader) and Get-ReleaseBranchName.throws when the manifest has no version field
  F1 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1|Invoke-ReleaseTagPush.ps1 - Invoke-ReleaseTagPushGuarded.Get-NpmVersion (real reader).throws when the manifest has no version field
  F1 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1|new-claude-worktree-session.ps1 - Get-WorktreeGroupDirectory.Grouping directory derivation.returns <parent>/<repoName>-wt
  F1 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1|new-claude-worktree-session.ps1 - Invoke-GitWorktreeAdd.Git worktree add composition via injected scriptblock seam.composes 'worktree add <path> -b <branch>' through the InvokeGit seam
  F1 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1|new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
  F1 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1|new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
  F1 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1|post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.runs the npm compile script when package.json defines one
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1|Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
  F1 tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1|Install-PoshQCTool.keeps manifest dependency requirements empty to allow bootstrap installs
  F1 tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1|Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry
  F1 tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1|Invoke-PoshQCTest scan-folder support.overrides run paths and preserves configured coverage paths when scan folders are supplied
  F1 tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1|Invoke-PoshQCTest.preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths
  F1 tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1|Install-PoshQCTool.logs a warning when PSGallery trust cannot be set
```
