# Baseline CT2: Leak Control over REPRO, Repeat (P0-T16)

Timestamp: 2026-11-04T00-49
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-leak-control.txt repro-control-2.xml issue-1066-p0t16.log (new process; same 44-file control list as P0-T15; JUnit to RAW/repro-control-2.xml); comparison by SCRATCH/issue-1066-junit-sets.ps1 -ProfileMode -First RAW/repro-control-2.xml -Second RAW/repro-control-1.xml
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester totals: Total=1013 Passed=831 Failed=180 Skipped=2 NotRun=0 FailedBlocks=0 FailedContainers=0.
- Container profile table: 44 containers with numeric fields; sums tests=1013 failed=180 blocks=0 container=0.
- Containers whose profile differs from CT1: none (`DIFFERING: 0`).
- Failing keys (information only): 180 distinct keys over 1013 testcases.

## File order

```text
ORDER: Set=Repro Mode=Leak Seed=0 Count=44
   1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
   2 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
   3 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
   4 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
   5 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
   6 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
   7 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
   8 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
   9 tests/scripts/dev-tools/activate.Tests.ps1
  10 tests/scripts/dev-tools/agents-attribution.Tests.ps1
  11 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
  12 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
  13 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
  14 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
  15 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
  16 tests/scripts/dev-tools/HostTooling.Tests.ps1
  17 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
  18 tests/scripts/dev-tools/HostVerification.Tests.ps1
  19 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
  20 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
  21 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
  22 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
  23 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
  24 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
  25 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
  26 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
  27 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
  28 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
  29 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
  30 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
  31 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
  32 tests/scripts/dev-tools/link-parent-child.Tests.ps1
  33 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
  34 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
  35 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
  36 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
  37 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
  38 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
  39 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
  40 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
  41 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
  42 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
  43 tests/scripts/dev-tools/tree.Tests.ps1
  44 tests/scripts/dev-tools/verify-host.Tests.ps1
```

## Container profile table and differences from CT1

```text
PROFILE: Containers=44 Tests=1013 Failed=180 Blocks=0 Container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=3 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=4 blocks=0 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=2 blocks=0 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=3 blocks=0 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=74 blocks=0 container=0
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
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
DIFFERING: 0
```

## Failing keys (information only)

```text
FIRST: Total=1013 Failed=180
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.reports unresolved on every non-conforming-timestamp row of the shared table
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.derivation helpers.Get-ParallelDriftGateUnresolvedState surfaces LatestAt for the latest event of each item
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from apply_patch
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Edit
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Write
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows mapped tool_input that carries no file_path
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.denies a mismatched final PR number
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.requires explicit matching MCP workspace_root for an attested preparation child
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-c1-standalone
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-c3-epic-execution-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-ceiling-below-band
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-commit-steward
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-c3-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-c3-epic-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-ceiling-below-band
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-profile-is-not-logical-role
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-feature-review-alias-epic-preparation
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-forced-epic-planner
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-invalid-choice
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-missing-required
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-unsupported-agent
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-cross-cutting
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-adjudicate-unspecified-behavior
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-alias-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-characterize-runtime-behavior
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-cross-cutting
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-empty-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic_execution_child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic_preparation_child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic-root-refused
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-extract-feature-contract
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-generate-acceptance-scenarios
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-initialize-discovery-workspace
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-inventory-legacy-system
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-production-negative
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-production-positive
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-reconcile-parity-matrix
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-review-discovery-coverage
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-root-override
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-test-count
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-unknown-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-validate-discovery-artifacts
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-whitespace-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-empty-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-epic-execution-child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-epic-preparation-child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-explicit-ordinary-small
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-missing-required
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-non-ascii-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-non-integer-count
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-ordinary-skill-default
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-ordinary-skill-explicit
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-powershell-budget-exceeded
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-repeated-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-standalone-small
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).resolves modules through the .claude/lib fallback inside drm-copilot
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-commit-steward
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-invalid-choice
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-unsupported-agent
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case topo-empty-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case topo-standalone-small
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
```
