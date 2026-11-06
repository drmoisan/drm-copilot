# Baseline Probe Control: tests/scripts/dev-tools with Coverage (P0-T9)

Timestamp: 2026-11-04T00-36
Command: sh SCRATCH/issue-1066-launch-poshqc.sh tests/scripts/dev-tools baseline-devtools-cov.xml baseline-devtools-coverage.xml issue-1066-p0t9.log (pwsh -NoProfile -File SCRATCH/issue-1066-poshqc-run.ps1 -Root <worktree root> -ScanFolders tests/scripts/dev-tools -TestResultPath RAW/baseline-devtools-cov.xml -CoverageOutputPath RAW/baseline-devtools-coverage.xml); profile by SCRATCH/issue-1066-junit-sets.ps1 -ProfileMode; coverage by SCRATCH/issue-1066-coverage.ps1 -PerFile
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Total=692 Passed=596 Failed=94 Skipped=2 NotRun=0 FailedBlocks=0 FailedContainers=0 (pre-existing #1067 host failures).
- Container profile table: 37 containers; sums tests=692 failed=94 blocks=0 container=0. Stored as SCRATCH/issue-1066-P9_base.json for P1-T4.
- Coverage: 265 files in the population; overall 1809 of 23279 lines = 7.77%; `scripts/dev-tools/run-actionlint.ps1` 4 of 50 lines = 8.00%. Per-file covered and total line counts are listed below.

## Container profile table

```text
PROFILE: Containers=37 Tests=692 Failed=94 Blocks=0 Container=0
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
```

## Per-file line coverage

```text
COVERAGE: files=265 covered=1809 total=23279 line%=7.77
RUN-ACTIONLINT: covered=4 total=50 line%=8.00
  F .claude/hooks/check-powershell-test-purity.ps1 | covered=0 total=61
  F .claude/hooks/check-python-test-purity.ps1 | covered=0 total=66
  F .claude/hooks/discovery-capability-probe.ps1 | covered=24 total=33
  F .claude/hooks/enforce-batch-budget-route.ps1 | covered=0 total=34
  F .claude/hooks/enforce-checkpoint-monotonic.ps1 | covered=0 total=100
  F .claude/hooks/enforce-completion-consistency.ps1 | covered=0 total=150
  F .claude/hooks/enforce-completion-helpers.ps1 | covered=0 total=67
  F .claude/hooks/enforce-discovery-artifact-gate.ps1 | covered=14 total=33
  F .claude/hooks/enforce-discovery-planning-gate.ps1 | covered=0 total=27
  F .claude/hooks/enforce-epic-invocation-origin.ps1 | covered=0 total=73
  F .claude/hooks/enforce-epic-merge-gate-authorization.ps1 | covered=0 total=100
  F .claude/hooks/enforce-epic-merge-gate-command.ps1 | covered=0 total=54
  F .claude/hooks/enforce-epic-merge-gate-green-ci.ps1 | covered=0 total=57
  F .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | covered=0 total=46
  F .claude/hooks/enforce-epic-merge-gate.ps1 | covered=0 total=132
  F .claude/hooks/enforce-epic-wave-barrier.ps1 | covered=0 total=96
  F .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | covered=0 total=51
  F .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=0 total=114
  F .claude/hooks/enforce-evidence-locations.ps1 | covered=0 total=46
  F .claude/hooks/enforce-feature-folder-order.ps1 | covered=0 total=66
  F .claude/hooks/enforce-file-size-limit.ps1 | covered=0 total=71
  F .claude/hooks/enforce-mermaid-validation.ps1 | covered=0 total=85
  F .claude/hooks/enforce-model-routing-receipt.ps1 | covered=0 total=92
  F .claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1 | covered=0 total=155
  F .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | covered=0 total=115
  F .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | covered=0 total=159
  F .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | covered=0 total=137
  F .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | covered=0 total=166
  F .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=0 total=161
  F .claude/hooks/enforce-parallel-abandon-gate.ps1 | covered=0 total=84
  F .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | covered=0 total=77
  F .claude/hooks/enforce-parallel-cohort-barrier.ps1 | covered=0 total=82
  F .claude/hooks/enforce-parallel-drift-gate-helpers.ps1 | covered=0 total=66
  F .claude/hooks/enforce-parallel-drift-gate.ps1 | covered=0 total=117
  F .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | covered=0 total=112
  F .claude/hooks/enforce-powershell-batch-budget.ps1 | covered=0 total=152
  F .claude/hooks/enforce-pr-author-command-allowlist.ps1 | covered=0 total=87
  F .claude/hooks/enforce-pr-author-skill-helpers.ps1 | covered=0 total=132
  F .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 | covered=0 total=66
  F .claude/hooks/enforce-pr-author-skill.cleanup.ps1 | covered=0 total=64
  F .claude/hooks/enforce-pr-author-skill.current-branch.ps1 | covered=0 total=22
  F .claude/hooks/enforce-pr-author-skill.docs-only.ps1 | covered=0 total=55
  F .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | covered=0 total=31
  F .claude/hooks/enforce-pr-author-skill.ps1 | covered=0 total=57
  F .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | covered=0 total=59
  F .claude/hooks/enforce-prd-feature-before-planner.ps1 | covered=0 total=99
  F .claude/hooks/enforce-promotion-mcp-only.ps1 | covered=0 total=66
  F .claude/hooks/enforce-python-batch-budget.ps1 | covered=0 total=152
  F .claude/hooks/feature-folder-resolution.ps1 | covered=0 total=111
  F .claude/hooks/feature-review-coverage-thresholds.ps1 | covered=0 total=21
  F .claude/hooks/hook-cleanup-context.ps1 | covered=0 total=97
  F .claude/hooks/hook-command-heredoc.ps1 | covered=0 total=42
  F .claude/hooks/hook-command-invocation-operands.ps1 | covered=0 total=40
  F .claude/hooks/hook-command-invocation.ps1 | covered=0 total=147
  F .claude/hooks/hook-command-payload-powershell.ps1 | covered=0 total=71
  F .claude/hooks/hook-command-payload.ps1 | covered=0 total=186
  F .claude/hooks/hook-command-scanner.ps1 | covered=0 total=149
  F .claude/hooks/hook-dependency-guard.ps1 | covered=1 total=19
  F .claude/hooks/hook-docs-only-diff.ps1 | covered=0 total=127
  F .claude/hooks/persist-session-id.ps1 | covered=0 total=42
  F .claude/hooks/premortem-section.ps1 | covered=0 total=45
  F .claude/hooks/record-discovery-agent-start.ps1 | covered=0 total=38
  F .claude/hooks/subagentstop-envelope.ps1 | covered=0 total=60
  F .claude/hooks/validate-bash.ps1 | covered=0 total=99
  F .claude/hooks/validate-discovery-artifact-gate.ps1 | covered=0 total=32
  F .claude/hooks/validate-executor-output.ps1 | covered=0 total=168
  F .claude/hooks/validate-feature-review-coverage-metrics.ps1 | covered=0 total=72
  F .claude/hooks/validate-feature-review-coverage-rules.ps1 | covered=0 total=89
  F .claude/hooks/validate-feature-review-coverage.ps1 | covered=0 total=85
  F .claude/hooks/validate-orchestrator-output-feature-folder.ps1 | covered=0 total=27
  F .claude/hooks/validate-orchestrator-output-rejection.ps1 | covered=0 total=43
  F .claude/hooks/validate-orchestrator-output-resolution.ps1 | covered=0 total=94
  F .claude/hooks/validate-orchestrator-output-routing.ps1 | covered=0 total=28
  F .claude/hooks/validate-orchestrator-output.ps1 | covered=0 total=123
  F .claude/hooks/validate-planner-output.ps1 | covered=0 total=207
  F .claude/hooks/validate-pr-author-output.ps1 | covered=0 total=33
  F .claude/hooks/validate-prd-feature-output.ps1 | covered=0 total=66
  F .claude/hooks/validate-required-artifact-output.ps1 | covered=0 total=62
  F .claude/hooks/validate-task-researcher-output.ps1 | covered=0 total=109
  F .claude/lib/blast-radius/BlastRadius.psm1 | covered=0 total=109
  F .claude/lib/blast-radius/BlastRadiusAggregate.psm1 | covered=0 total=37
  F .claude/lib/blast-radius/BlastRadiusCombination.psm1 | covered=0 total=72
  F .claude/lib/blast-radius/BlastRadiusConfig.psm1 | covered=0 total=81
  F .claude/lib/blast-radius/BlastRadiusConflict.psm1 | covered=0 total=97
  F .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | covered=0 total=80
  F .claude/lib/blast-radius/BlastRadiusGlob.psm1 | covered=0 total=77
  F .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | covered=0 total=52
  F .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | covered=0 total=138
  F .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | covered=0 total=39
  F .claude/lib/blast-radius/BlastRadiusValidation.psm1 | covered=0 total=101
  F .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | covered=0 total=103
  F .claude/lib/ci-gate/Invoke-CiGateParser.ps1 | covered=0 total=46
  F .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | covered=37 total=48
  F .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | covered=0 total=111
  F .claude/lib/codex-routing/CodexDeployment.psm1 | covered=0 total=68
  F .claude/lib/codex-routing/CodexDiscoveryRouting.psm1 | covered=0 total=68
  F .claude/lib/codex-routing/CodexTopology.psm1 | covered=0 total=112
  F .claude/lib/discovery-validation/DiscoveryAuthority.psm1 | covered=61 total=147
  F .claude/lib/discovery-validation/DiscoveryAuthorization.psm1 | covered=18 total=185
  F .claude/lib/discovery-validation/DiscoveryCapability.psm1 | covered=76 total=184
  F .claude/lib/discovery-validation/DiscoveryEncoding.psm1 | covered=5 total=46
  F .claude/lib/discovery-validation/DiscoveryManifest.psm1 | covered=0 total=132
  F .claude/lib/discovery-validation/DiscoveryObservation.psm1 | covered=14 total=65
  F .claude/lib/discovery-validation/DiscoveryPayload.psm1 | covered=17 total=88
  F .claude/lib/discovery-validation/DiscoveryPlanning.psm1 | covered=0 total=130
  F .claude/lib/discovery-validation/DiscoveryRootGrant.psm1 | covered=10 total=49
  F .claude/lib/discovery-validation/DiscoveryStart.psm1 | covered=10 total=140
  F .claude/lib/discovery-validation/DiscoveryStartRecord.psm1 | covered=10 total=102
  F .claude/lib/discovery-validation/DiscoveryStop.psm1 | covered=0 total=135
  F .claude/lib/discovery-validation/DiscoveryToolRouting.psm1 | covered=31 total=71
  F .claude/lib/discovery-validation/DiscoveryValidation.psm1 | covered=0 total=78
  F .claude/lib/file-size-policy/FileSizePolicy.psm1 | covered=0 total=105
  F .claude/lib/hook-payload/HookPayload.psm1 | covered=15 total=104
  F .claude/lib/mermaid/MermaidGrammar.psm1 | covered=0 total=143
  F .claude/lib/mermaid/MermaidLineScanner.psm1 | covered=0 total=164
  F .claude/lib/mermaid/MermaidMarkdownFences.psm1 | covered=0 total=80
  F .claude/lib/mermaid/MermaidValidation.psm1 | covered=0 total=150
  F .claude/lib/model-routing/ModelRouting.psm1 | covered=0 total=47
  F .claude/lib/orchestrator-state/OrchestratorState.psm1 | covered=0 total=110
  F .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | covered=0 total=66
  F .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | covered=0 total=81
  F .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | covered=0 total=81
  F .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | covered=0 total=97
  F .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | covered=0 total=100
  F .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 | covered=0 total=108
  F .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | covered=0 total=38
  F .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | covered=0 total=119
  F .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | covered=0 total=91
  F .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | covered=0 total=117
  F .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | covered=0 total=100
  F .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | covered=0 total=111
  F .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | covered=0 total=74
  F .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | covered=0 total=29
  F .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 | covered=0 total=96
  F .claude/lib/parallel-drift/ParallelDrift.psm1 | covered=0 total=123
  F .claude/lib/parallel-drift/ParallelDriftHalt.psm1 | covered=0 total=67
  F .claude/lib/project-file-merge/ProjectFileMerge.psm1 | covered=0 total=124
  F .claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1 | covered=0 total=122
  F .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1 | covered=0 total=65
  F .claude/lib/requirements/GeneratedDocumentCounters.psm1 | covered=0 total=15
  F .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | covered=0 total=49
  F .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | covered=0 total=112
  F .claude/lib/worktree-resolution/HookTargetWorktree.psm1 | covered=0 total=152
  F .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | covered=0 total=136
  F .claude/lib/worktree-resolution/WorktreeResolution.psm1 | covered=0 total=144
  F .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 | covered=0 total=37
  F .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | covered=0 total=146
  F .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | covered=0 total=104
  F .codex/hooks/authorize-root-epic-invocation.ps1 | covered=0 total=100
  F .codex/hooks/check-powershell-test-purity.ps1 | covered=0 total=68
  F .codex/hooks/check-python-test-purity.ps1 | covered=0 total=73
  F .codex/hooks/codex-agent-profile-attestation.ps1 | covered=0 total=86
  F .codex/hooks/codex-authority-store.ps1 | covered=0 total=58
  F .codex/hooks/codex-epic-child-launch-attestation.ps1 | covered=0 total=66
  F .codex/hooks/codex-pretooluse-file-mapping.ps1 | covered=0 total=101
  F .codex/hooks/discovery-capability-probe.ps1 | covered=19 total=28
  F .codex/hooks/discovery-start-attestation.ps1 | covered=0 total=76
  F .codex/hooks/enforce-batch-budget-route.ps1 | covered=0 total=34
  F .codex/hooks/enforce-checkpoint-monotonic.ps1 | covered=0 total=110
  F .codex/hooks/enforce-codex-model-routing.ps1 | covered=0 total=78
  F .codex/hooks/enforce-completion-consistency.ps1 | covered=0 total=153
  F .codex/hooks/enforce-completion-helpers.ps1 | covered=0 total=67
  F .codex/hooks/enforce-discovery-artifact-gate.ps1 | covered=20 total=55
  F .codex/hooks/enforce-discovery-planning-gate.ps1 | covered=0 total=48
  F .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=0 total=166
  F .codex/hooks/enforce-epic-merge-gate-command.ps1 | covered=0 total=54
  F .codex/hooks/enforce-epic-merge-gate.ps1 | covered=0 total=153
  F .codex/hooks/enforce-epic-planning-only.ps1 | covered=0 total=169
  F .codex/hooks/enforce-epic-root-invocation.ps1 | covered=0 total=56
  F .codex/hooks/enforce-epic-wave-barrier.ps1 | covered=0 total=139
  F .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=0 total=78
  F .codex/hooks/enforce-evidence-locations.ps1 | covered=0 total=47
  F .codex/hooks/enforce-file-size-limit.ps1 | covered=0 total=83
  F .codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1 | covered=0 total=155
  F .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | covered=0 total=147
  F .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | covered=0 total=134
  F .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | covered=0 total=159
  F .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | covered=0 total=135
  F .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | covered=0 total=166
  F .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=0 total=171
  F .codex/hooks/enforce-powershell-batch-budget.ps1 | covered=0 total=119
  F .codex/hooks/enforce-promotion-mcp-only.ps1 | covered=0 total=71
  F .codex/hooks/enforce-python-batch-budget.ps1 | covered=0 total=119
  F .codex/hooks/feature-folder-resolution.ps1 | covered=0 total=111
  F .codex/hooks/feature-review-coverage-thresholds.ps1 | covered=0 total=21
  F .codex/hooks/file-size-policy.ps1 | covered=0 total=102
  F .codex/hooks/hook-cleanup-context.ps1 | covered=0 total=97
  F .codex/hooks/hook-command-heredoc.ps1 | covered=0 total=42
  F .codex/hooks/hook-command-invocation-operands.ps1 | covered=0 total=40
  F .codex/hooks/hook-command-invocation.ps1 | covered=0 total=147
  F .codex/hooks/hook-command-payload-powershell.ps1 | covered=0 total=71
  F .codex/hooks/hook-command-payload.ps1 | covered=0 total=186
  F .codex/hooks/hook-command-scanner.ps1 | covered=0 total=149
  F .codex/hooks/hook-dependency-guard.ps1 | covered=1 total=19
  F .codex/hooks/hook-docs-only-diff.ps1 | covered=0 total=127
  F .codex/hooks/hook-target-worktree.ps1 | covered=0 total=149
  F .codex/hooks/record-subagent-routing-attestation.ps1 | covered=0 total=209
  F .codex/hooks/validate-bash.ps1 | covered=0 total=81
  F .codex/hooks/validate-codex-subagent-routing.ps1 | covered=0 total=73
  F .codex/hooks/validate-discovery-agent-output.ps1 | covered=0 total=56
  F .codex/hooks/validate-feature-review-coverage.ps1 | covered=0 total=146
  F .codex/scripts/codex-routing-cli-common.ps1 | covered=0 total=113
  F .codex/scripts/epic-child-launch-contract.ps1 | covered=0 total=229
  F .codex/scripts/epic-child-launch-runtime.ps1 | covered=0 total=229
  F .codex/scripts/epic-child-persistence-runtime.ps1 | covered=0 total=51
  F .codex/scripts/epic-child-sandbox-preflight.ps1 | covered=0 total=34
  F .codex/scripts/launch-epic-child-wave.ps1 | covered=0 total=291
  F .codex/scripts/post-codex-worktree-session.ps1 | covered=0 total=85
  F .codex/scripts/Resolve-CodexDeployment.ps1 | covered=0 total=31
  F .codex/scripts/Resolve-CodexTopology.ps1 | covered=0 total=46
  F .codex/scripts/resume-epic-child.ps1 | covered=0 total=181
  F .github/hooks/discovery-agent-start.ps1 | covered=0 total=34
  F .github/hooks/discovery-agent-stop.ps1 | covered=0 total=39
  F .github/hooks/discovery-capability-probe.ps1 | covered=19 total=28
  F .github/hooks/discovery-planning.ps1 | covered=0 total=25
  F .github/hooks/discovery-pre-tool.ps1 | covered=6 total=30
  F scripts/ci/CiChangeScope.psm1 | covered=0 total=140
  F scripts/ci/FileSizeBaseline.psm1 | covered=0 total=54
  F scripts/ci/Invoke-CiChangeScope.ps1 | covered=0 total=113
  F scripts/ci/New-FileSizeBaseline.ps1 | covered=0 total=32
  F scripts/dev-tools/activate.ps1 | covered=36 total=53
  F scripts/dev-tools/bootstrap-host.ps1 | covered=7 total=7
  F scripts/dev-tools/DrmCopilotPromptSupport.ps1 | covered=25 total=38
  F scripts/dev-tools/Enter-DrmCopilotShell.ps1 | covered=0 total=6
  F scripts/dev-tools/format-powershell.ps1 | covered=0 total=5
  F scripts/dev-tools/HostBootstrap.psm1 | covered=146 total=155
  F scripts/dev-tools/HostBootstrapWorkspace.psm1 | covered=62 total=64
  F scripts/dev-tools/HostTooling.psm1 | covered=40 total=42
  F scripts/dev-tools/HostVerification.psm1 | covered=149 total=149
  F scripts/dev-tools/Invoke-FullRelease.ps1 | covered=92 total=104
  F scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1 | covered=30 total=30
  F scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 | covered=23 total=23
  F scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | covered=134 total=142
  F scripts/dev-tools/Invoke-MarketplacePublish.ps1 | covered=55 total=62
  F scripts/dev-tools/Invoke-ReleaseReconciliation.ps1 | covered=24 total=27
  F scripts/dev-tools/Invoke-ReleaseTagPush.ps1 | covered=74 total=77
  F scripts/dev-tools/Invoke-ReleaseVerification.ps1 | covered=56 total=65
  F scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1 | covered=29 total=29
  F scripts/dev-tools/link-feature-docs.ps1 | covered=37 total=45
  F scripts/dev-tools/link-parent-child.ps1 | covered=93 total=100
  F scripts/dev-tools/load-openai-key.ps1 | covered=0 total=16
  F scripts/dev-tools/new-claude-worktree-session.ps1 | covered=44 total=75
  F scripts/dev-tools/new-potential-entry.ps1 | covered=13 total=87
  F scripts/dev-tools/publish-sideloaded-extension.ps1 | covered=25 total=32
  F scripts/dev-tools/run-actionlint.ps1 | covered=4 total=50
  F scripts/dev-tools/run-pester.ps1 | covered=0 total=5
  F scripts/dev-tools/run-poshqc-suite.ps1 | covered=0 total=5
  F scripts/dev-tools/run-psscriptanalyzer.ps1 | covered=0 total=5
  F scripts/dev-tools/SideloadedExtensionPublish.psm1 | covered=86 total=139
  F scripts/dev-tools/sync-agents-from-instructions.ps1 | covered=75 total=129
  F scripts/dev-tools/Test-DiscoveryHostCapability.ps1 | covered=16 total=21
  F scripts/dev-tools/tree.ps1 | covered=11 total=19
  F scripts/dev-tools/verify-host.ps1 | covered=7 total=7
  F scripts/dev-tools/vscode-cli.helpers.ps1 | covered=8 total=27
  F scripts/powershell/Publish-DrmCopilotExtension.ps1 | covered=0 total=116
  F scripts/powershell/PoshQC/convert-poshqc-coverage.ps1 | covered=0 total=16
  F scripts/powershell/PoshQC/PoshQC.Analyzer.psm1 | covered=0 total=88
  F scripts/powershell/PoshQC/PoshQC.Coverage.psm1 | covered=0 total=109
  F scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 | covered=0 total=72
  F scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1 | covered=0 total=49
  F scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | covered=0 total=150
  F scripts/powershell/PoshQC/PoshQC.psm1 | covered=0 total=60
  F scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 | covered=0 total=46
  F scripts/powershell/PoshQC/PoshQC.Shard.psm1 | covered=0 total=138
  F scripts/powershell/PoshQC/PoshQC.Testing.psm1 | covered=0 total=205
```
