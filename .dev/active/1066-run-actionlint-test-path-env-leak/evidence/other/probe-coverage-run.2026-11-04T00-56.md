# Feasibility Probe S2: Invoke-PoshQCTest over tests/scripts/dev-tools with Coverage (P1-T4)

Timestamp: 2026-11-04T00-56
Command: sh SCRATCH/issue-1066-launch-poshqc.sh tests/scripts/dev-tools probe-devtools-cov.xml probe-devtools-coverage.xml issue-1066-p1t4.log (pwsh -NoProfile -File SCRATCH/issue-1066-poshqc-run.ps1 -Root <worktree root> -ScanFolders tests/scripts/dev-tools -TestResultPath RAW/probe-devtools-cov.xml -CoverageOutputPath RAW/probe-devtools-coverage.xml); comparisons by SCRATCH/issue-1066-junit-sets.ps1 -ProfileMode -First RAW/probe-devtools-cov.xml -Second RAW/baseline-devtools-cov.xml and SCRATCH/issue-1066-coverage.ps1 -Coverage RAW/probe-devtools-coverage.xml -Compare RAW/baseline-devtools-coverage.xml
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Total=695 Passed=598 Failed=95 Skipped=2 FailedBlocks=0 FailedContainers=0. Profile sums: 38 containers, tests=695 failed=95 blocks=0 container=0.
- R1 (control testcase passes): holds.
- R2 (environment testcase fails naming exactly one differing key, PATH): holds. Message: `Expected $null or empty, because run-actionlint.Tests.ps1 must restore every environment variable it changes; differing keys: PATH, but got 'PATH'.`
- R3 (every non-GUARD container profile equals P0-T9; total = P0-T9 total + 3): holds. The only differing container is GUARD (absent in P0-T9); total 695 = 692 + 3.
- R4 (same coverage file set, same per-file line totals, no file with a lower covered count): holds. `COMPARE: same-file-set=True total-differs=0 covered-lower=0`; overall 1809 of 23279 lines (7.77%) in both runs; `scripts/dev-tools/run-actionlint.ps1` 4 of 50 in both.
- Differing container profiles: GUARD only (new). Differing coverage rows: none.

## Container profiles against P0-T9

```text
PROFILE: Containers=38 Tests=695 Failed=95 Blocks=0 Container=0
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
  P tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | tests=3 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/run-actionlint.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
DIFFERING: 1
  X tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | first tests=3 failed=1 blocks=0 container=0 | second absent
```

## Coverage comparison against P0-T9

```text
COVERAGE: files=265 covered=1809 total=23279 line%=7.77
RUN-ACTIONLINT: covered=4 total=50 line%=8.00
COMPARE-BASE: files=265 covered=1809 total=23279 line%=7.77
COMPARE: same-file-set=True total-differs=0 covered-lower=0
```
