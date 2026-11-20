# Isolation - Seeded Shuffled File-Order Runs (Issue 1080, Cycle 2)

Timestamp: 2026-11-06T00-43
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r2-p2t6-<seed>.log <seed> tests/scripts/dev-tools (seeds 1080, 2026, 7; one fresh single-process PowerShell 7 run per seed)
EXIT_CODE: 0
Output Summary: All three seeds pass: TOTAL Tests=821 Passed=819 Failed=0 Skipped=2 in each run. Both change-set suites failed=0 in every run (Logic tests=67, script tests=32). No container failed in any run.

## Results per seed

| Seed | Exit | TOTAL | Logic suite | Script suite | Other containers with failures |
|---|---|---|---|---|---|
| 1080 | 0 | Tests=821 Passed=819 Failed=0 Skipped=2 | tests=67 failed=0 (order 1) | tests=32 failed=0 (order 18) | none |
| 2026 | 0 | Tests=821 Passed=819 Failed=0 Skipped=2 | tests=67 failed=0 (order 17) | tests=32 failed=0 (order 30) | none |
| 7 | 0 | Tests=821 Passed=819 Failed=0 Skipped=2 | tests=67 failed=0 (order 5) | tests=32 failed=0 (order 4) | none |

Seed 7 runs the script suite immediately before the Logic suite, and seed 1080 runs the Logic suite first, so both relative orders of the two change-set suites pass. The two skipped tests are pre-existing skips outside the change set.

## File orders (paths relative to tests/scripts/dev-tools/)

### Seed 1080

```
ORDER 1 Get-EpicProgressReport.Logic.Tests.ps1
ORDER 2 Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
ORDER 3 Invoke-ReleaseVerification.Tests.ps1
ORDER 4 agents-attribution.Tests.ps1
ORDER 5 Invoke-ReleaseReconciliation.Tests.ps1
ORDER 6 Enter-DrmCopilotShell.Tests.ps1
ORDER 7 run-actionlint.Tests.ps1
ORDER 8 activate.Tests.ps1
ORDER 9 Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 10 verify-host.Tests.ps1
ORDER 11 post-codex-worktree-session.Tests.ps1
ORDER 12 Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 13 HostVerification.Invoke.Tests.ps1
ORDER 14 HostVerification.Tests.ps1
ORDER 15 HostBootstrap.Tests.ps1
ORDER 16 SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 17 Invoke-FullReleaseFlow.Tests.ps1
ORDER 18 Get-EpicProgressReport.Tests.ps1
ORDER 19 new-claude-worktree-session.Tests.ps1
ORDER 20 publish-sideloaded-extension.Tests.ps1
ORDER 21 HostBootstrap.Invoke.Tests.ps1
ORDER 22 HostTooling.Tests.ps1
ORDER 23 Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 24 Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 25 Invoke-ReleaseTagPush.Tests.ps1
ORDER 26 SideloadedExtensionPublish.Tests.ps1
ORDER 27 link-feature-docs.Tests.ps1
ORDER 28 HostBootstrapWorkspace.Tests.ps1
ORDER 29 Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 30 run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 31 sync-agents-from-instructions.Tests.ps1
ORDER 32 Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 33 Invoke-MarketplacePublish.Tests.ps1
ORDER 34 HostBootstrap.Versions.Tests.ps1
ORDER 35 tree.Tests.ps1
ORDER 36 Invoke-FullRelease.Tests.ps1
ORDER 37 new-potential-entry.Tests.ps1
ORDER 38 bootstrap-host.Tests.ps1
ORDER 39 link-parent-child.Tests.ps1
ORDER 40 new-potential-entry.TemplateRoot.Tests.ps1
ORDER 41 Test-DiscoveryHostCapability.Tests.ps1
```

### Seed 2026

```
ORDER 1 Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 2 Invoke-ReleaseTagPush.Tests.ps1
ORDER 3 sync-agents-from-instructions.Tests.ps1
ORDER 4 Invoke-MarketplacePublish.Tests.ps1
ORDER 5 Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
ORDER 6 link-parent-child.Tests.ps1
ORDER 7 post-codex-worktree-session.Tests.ps1
ORDER 8 verify-host.Tests.ps1
ORDER 9 Invoke-FullRelease.Tests.ps1
ORDER 10 HostTooling.Tests.ps1
ORDER 11 agents-attribution.Tests.ps1
ORDER 12 link-feature-docs.Tests.ps1
ORDER 13 SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 14 run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 15 Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 16 HostBootstrapWorkspace.Tests.ps1
ORDER 17 Get-EpicProgressReport.Logic.Tests.ps1
ORDER 18 new-claude-worktree-session.Tests.ps1
ORDER 19 HostBootstrap.Tests.ps1
ORDER 20 Invoke-FullReleaseFlow.Tests.ps1
ORDER 21 activate.Tests.ps1
ORDER 22 Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 23 Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 24 Test-DiscoveryHostCapability.Tests.ps1
ORDER 25 HostVerification.Tests.ps1
ORDER 26 HostBootstrap.Versions.Tests.ps1
ORDER 27 Enter-DrmCopilotShell.Tests.ps1
ORDER 28 Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 29 publish-sideloaded-extension.Tests.ps1
ORDER 30 Get-EpicProgressReport.Tests.ps1
ORDER 31 new-potential-entry.TemplateRoot.Tests.ps1
ORDER 32 tree.Tests.ps1
ORDER 33 Invoke-ReleaseReconciliation.Tests.ps1
ORDER 34 new-potential-entry.Tests.ps1
ORDER 35 Invoke-ReleaseVerification.Tests.ps1
ORDER 36 bootstrap-host.Tests.ps1
ORDER 37 run-actionlint.Tests.ps1
ORDER 38 Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 39 SideloadedExtensionPublish.Tests.ps1
ORDER 40 HostVerification.Invoke.Tests.ps1
ORDER 41 HostBootstrap.Invoke.Tests.ps1
```

### Seed 7

```
ORDER 1 Invoke-FullReleaseFlow.Tests.ps1
ORDER 2 HostBootstrapWorkspace.Tests.ps1
ORDER 3 HostBootstrap.Tests.ps1
ORDER 4 Get-EpicProgressReport.Tests.ps1
ORDER 5 Get-EpicProgressReport.Logic.Tests.ps1
ORDER 6 new-potential-entry.TemplateRoot.Tests.ps1
ORDER 7 post-codex-worktree-session.Tests.ps1
ORDER 8 Test-DiscoveryHostCapability.Tests.ps1
ORDER 9 tree.Tests.ps1
ORDER 10 bootstrap-host.Tests.ps1
ORDER 11 Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 12 Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 13 Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 14 SideloadedExtensionPublish.Tests.ps1
ORDER 15 Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 16 Invoke-ReleaseTagPush.Tests.ps1
ORDER 17 HostBootstrap.Invoke.Tests.ps1
ORDER 18 link-parent-child.Tests.ps1
ORDER 19 new-potential-entry.Tests.ps1
ORDER 20 HostVerification.Invoke.Tests.ps1
ORDER 21 verify-host.Tests.ps1
ORDER 22 activate.Tests.ps1
ORDER 23 Invoke-MarketplacePublish.Tests.ps1
ORDER 24 HostBootstrap.Versions.Tests.ps1
ORDER 25 Invoke-ReleaseReconciliation.Tests.ps1
ORDER 26 HostTooling.Tests.ps1
ORDER 27 Invoke-ReleaseVerification.Tests.ps1
ORDER 28 Enter-DrmCopilotShell.Tests.ps1
ORDER 29 HostVerification.Tests.ps1
ORDER 30 publish-sideloaded-extension.Tests.ps1
ORDER 31 sync-agents-from-instructions.Tests.ps1
ORDER 32 run-actionlint.Tests.ps1
ORDER 33 new-claude-worktree-session.Tests.ps1
ORDER 34 run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 35 Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 36 Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 37 Invoke-FullRelease.Tests.ps1
ORDER 38 agents-attribution.Tests.ps1
ORDER 39 link-feature-docs.Tests.ps1
ORDER 40 SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 41 Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
```

