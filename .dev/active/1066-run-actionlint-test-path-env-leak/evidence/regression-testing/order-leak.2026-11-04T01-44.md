# Order Verification: Leak (pass-after for APPROVED P0-T13) (P3-T6)

Timestamp: 2026-11-04T01-44
Command: pwsh -NoProfile -File SCRATCH/issue-1066-order.ps1 -Mode Leak -Seed 0 -Set Repro; pwsh -NoProfile -File SCRATCH/issue-1066-run-list.ps1 -ListFile SCRATCH/issue-1066-list-order-leak.txt -OutFile artifacts/pester/issue-1066/order-leak.xml; pwsh -NoProfile -File SCRATCH/issue-1066-cr.ps1 -Run artifacts/pester/issue-1066/order-leak.xml -GuardTests 4
EXIT_CODE: 0
Output Summary:
- RCR verdict: HOLDS (G = 4).
- Pester run (single process, exit code reflects pre-existing #1067 host failures): RUN-LIST: Total=1052 Passed=870 Failed=180 Skipped=2 NotRun=0 FailedBlocks=0 FailedContainers=0; run-list EXIT_CODE=1.
- Order: Repro Leak, seed not applicable, 46 files (listed below).
- RUN: Containers=46 Tests=1052 Failed=180 Blocks=0 Container=0
- CR1 victim removal: holds (VS=8, outside PC=0)
- CR2 no new failure: holds (outside Base=0)
- CR3 guard: holds | tests=4 failed=0 blocks=0 container=0
- CR4 keys (information only; template names of failed blocks are not expanded, keys can repeat): failing=180 not-in-CT1/CT2/TARGET-LK1=0 in-V_key=0
- Containers outside their Base profile: none
- Control result: not required (RCR (1) and (2) hold without a control run)

## VS Containers (RCR 1)

- VS tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | R tests=26 failed=3 blocks=0 container=0 | PC tests=26 failed=3 blocks=0 container=0 | LK1 tests=26 failed=4 blocks=1 container=0
- VS tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | R tests=3 failed=0 blocks=0 container=0 | PC tests=3 failed=0 blocks=0 container=0 | LK1 tests=3 failed=3 blocks=1 container=0
- VS tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | R tests=12 failed=0 blocks=0 container=0 | PC tests=12 failed=0 blocks=0 container=0 | LK1 tests=12 failed=1 blocks=0 container=0
- VS tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | R tests=11 failed=0 blocks=0 container=0 | PC tests=11 failed=0 blocks=0 container=0 | LK1 tests=11 failed=11 blocks=1 container=0
- VS tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | R tests=51 failed=4 blocks=0 container=0 | PC tests=51 failed=4 blocks=0 container=0 | LK1 tests=51 failed=51 blocks=1 container=0
- VS tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | R tests=50 failed=2 blocks=0 container=0 | PC tests=50 failed=2 blocks=0 container=0 | LK1 tests=50 failed=50 blocks=1 container=0
- VS tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | R tests=43 failed=3 blocks=0 container=0 | PC tests=43 failed=3 blocks=0 container=0 | LK1 tests=43 failed=43 blocks=1 container=0
- VS tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | R tests=160 failed=74 blocks=0 container=0 | PC tests=160 failed=74 blocks=0 container=0 | LK1 tests=160 failed=160 blocks=1 container=0

## File Order

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
