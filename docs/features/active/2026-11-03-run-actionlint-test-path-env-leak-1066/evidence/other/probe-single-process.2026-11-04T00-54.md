# Feasibility Probe S1: Leak Order over REPRO with GUARD (P1-T3)

Timestamp: 2026-11-04T00-54
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-probe-leak.txt probe-leak.xml issue-1066-p1t3.log (46-file Leak list from SCRATCH/issue-1066-order.ps1 -Mode Leak: GUARD, TARGET, VICTIMS, remaining DEVLIST; single process; JUnit to RAW/probe-leak.xml); comparisons by SCRATCH/issue-1066-junit-sets.ps1 -ProfileMode (-First RAW/probe-leak.xml -Base SCRATCH/issue-1066-PL_max.json, and -First SCRATCH/issue-1066-PL_min.json -Base RAW/probe-leak.xml)
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Total=1051 Passed=631 Failed=418 Skipped=2 FailedBlocks=7 FailedContainers=0. Profile sums: 46 containers, tests=1051 failed=418 blocks=7 container=0.
- GUARD profile: tests=3 failed=1 blocks=0 container=0 (control passed; environment testcase failed; LASTEXITCODE testcase passed).
- R1 (control testcase passes): holds.
- R2 (environment testcase fails naming exactly one differing key, PATH): holds. Message: `Expected $null or empty, because run-actionlint.Tests.ps1 must restore every environment variable it changes; differing keys: PATH, but got 'PATH'.`
- R3 (every non-GUARD container between PL_min and PL_max with tests equal; total = LK1 total + 3): holds. Probe within PL_max: `WITHIN-BASE: Shared=45 Outside=0`; PL_min within probe: `WITHIN-BASE: Shared=45 Outside=0`. Testcase total 1051 = 1048 + 3.
- Containers outside the PL_min to PL_max range: none.

## File order

```text
ORDER: Set=Repro Mode=Leak Seed=0 Count=46
   1 tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
   2 tests/scripts/dev-tools/run-actionlint.Tests.ps1
   3 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
   4 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
   5 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
   6 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
   7 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
   8 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
   9 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
  10 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
  11 tests/scripts/dev-tools/activate.Tests.ps1
  12 tests/scripts/dev-tools/agents-attribution.Tests.ps1
  13 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
  14 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
  15 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
  16 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
  17 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
  18 tests/scripts/dev-tools/HostTooling.Tests.ps1
  19 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
  20 tests/scripts/dev-tools/HostVerification.Tests.ps1
  21 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
  22 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
  23 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
  24 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
  25 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
  26 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
  27 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
  28 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
  29 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
  30 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
  31 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
  32 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
  33 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
  34 tests/scripts/dev-tools/link-parent-child.Tests.ps1
  35 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
  36 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
  37 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
  38 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
  39 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
  40 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
  41 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
  42 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
  43 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
  44 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
  45 tests/scripts/dev-tools/tree.Tests.ps1
  46 tests/scripts/dev-tools/verify-host.Tests.ps1
```

## Probe profile within PL_max

```text
PROFILE: Containers=46 Tests=1051 Failed=418 Blocks=7 Container=0
  P tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | tests=3 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/run-actionlint.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=4 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=3 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=11 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=51 blocks=1 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=50 blocks=1 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=43 blocks=1 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=160 blocks=1 container=0
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
WITHIN-BASE: Shared=45 Outside=0 OnlyRun=1 OnlyBase=0
  ONLY-RUN tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | tests=3 failed=1 blocks=0 container=0
```

## PL_min within probe

```text
PROFILE: Containers=45 Tests=1048 Failed=417 Blocks=7 Container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=4 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=3 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=11 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=51 blocks=1 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=50 blocks=1 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=43 blocks=1 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=160 blocks=1 container=0
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
WITHIN-BASE: Shared=45 Outside=0 OnlyRun=0 OnlyBase=1
  ONLY-BASE tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | tests=3 failed=1 blocks=0 container=0
```
